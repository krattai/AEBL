/*
     This file is part of GNUnet.
     Copyright (C)

     GNUnet is free software; you can redistribute it and/or modify
     it under the terms of the GNU General Public License as published
     by the Free Software Foundation; either version 3, or (at your
     option) any later version.

     GNUnet is distributed in the hope that it will be useful, but
     WITHOUT ANY WARRANTY; without even the implied warranty of
     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
     General Public License for more details.

     You should have received a copy of the GNU General Public License
     along with GNUnet; see the file COPYING.  If not, write to the
     Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
     Boston, MA 02110-1301, USA.
*/

/**
 * @file rps/rps_api.c
 * @brief API for rps
 * @author Julius Bünger
 */
#include "platform.h"
#include "gnunet_util_lib.h"
#include "rps.h"
#include "gnunet_rps_service.h"

#include <inttypes.h>

#define LOG(kind,...) GNUNET_log_from (kind, "rps-api",__VA_ARGS__)

/**
 * Handler to handle requests from a client.
 */
struct GNUNET_RPS_Handle
{
  /**
   * The handle to the client configuration.
   */
  const struct GNUNET_CONFIGURATION_Handle *cfg;

  /**
   * The message queue to the client.
   */
  struct GNUNET_MQ_Handle *mq;

  /**
   * Array of Request_Handles.
   */
  struct GNUNET_CONTAINER_MultiHashMap32 *req_handlers;

  /**
   * The id of the last request.
   */
  uint32_t current_request_id;
};


/**
 * Handler to single requests from the client.
 */
struct GNUNET_RPS_Request_Handle
{
  /**
   * The client issuing the request.
   */
  struct GNUNET_RPS_Handle *rps_handle;

  /**
   * The id of the request.
   */
  uint32_t id;

  /**
   * The number of requested peers.
   */
  uint32_t num_peers;

  /**
   * The callback to be called when we receive an answer.
   */
  GNUNET_RPS_NotifyReadyCB ready_cb;

  /**
   * The closure for the callback.
   */
  void *ready_cb_cls;
};


/**
 * Struct used to pack the callback, its closure (provided by the caller)
 * and the connection handler to the service to pass it to a callback function.
 */
struct cb_cls_pack
{
  /**
   * Callback provided by the client
   */
  GNUNET_RPS_NotifyReadyCB cb;

  /**
   * Closure provided by the client
   */
  void *cls;

  /**
   * Handle to the service connection
   */
 struct GNUNET_CLIENT_Connection *service_conn;
};

/**
 * @brief Send a request to the service.
 *
 * @param h rps handle
 * @param id id of the request
 * @param num_req_peers number of peers
 */
void
send_request (const struct GNUNET_RPS_Handle *h,
              uint32_t id,
              uint32_t num_req_peers)
{
  struct GNUNET_MQ_Envelope *ev;
  struct GNUNET_RPS_CS_RequestMessage *msg;

  ev = GNUNET_MQ_msg (msg, GNUNET_MESSAGE_TYPE_RPS_CS_REQUEST);
  msg->num_peers = htonl (num_req_peers);
  msg->id = htonl (id);
  GNUNET_MQ_send (h->mq, ev);
}

/**
 * @brief Iterator function over pending requests
 *
 * Implements #GNUNET_CONTAINER_HashMapIterator32
 *
 * @param cls rps handle
 * @param key id of the request
 * @param value request handle
 *
 * @return GNUNET_YES to continue iteration
 */
int
resend_requests_iterator (void *cls, uint32_t key, void *value)
{
  const struct GNUNET_RPS_Handle *h = cls;
  const struct GNUNET_RPS_Request_Handle *req_handle = value;

  send_request (h, req_handle->id, req_handle->num_peers);
  return GNUNET_YES; /* continue iterating */
}

/**
 * @brief Resend all pending requests
 *
 * This is used to resend all pending requests after the client
 * reconnected to the service, because the service cancels all
 * pending requests after reconnection.
 *
 * @param h rps handle
 */
void
resend_requests (struct GNUNET_RPS_Handle *h)
{
  GNUNET_CONTAINER_multihashmap32_iterate (h->req_handlers,
                                           resend_requests_iterator,
                                           h);
}


/**
 * This function is called, when the service replies to our request.
 * It verifies that @a msg is well-formed.
 *
 * @param cls the closure
 * @param msg the message
 * @return #GNUNET_OK if @a msg is well-formed
 */
static int
check_reply (void *cls,
             const struct GNUNET_RPS_CS_ReplyMessage *msg)
{
  uint16_t msize = ntohs (msg->header.size);
  uint32_t num_peers = ntohl (msg->num_peers);

  msize -= sizeof (struct GNUNET_RPS_CS_ReplyMessage);
  if ( (msize / sizeof (struct GNUNET_PeerIdentity) != num_peers) ||
       (msize % sizeof (struct GNUNET_PeerIdentity) != 0) )
  {
    GNUNET_break (0);
    return GNUNET_SYSERR;
  }
  return GNUNET_OK;
}


/**
 * This function is called, when the service replies to our request.
 * It calls the callback the caller gave us with the provided closure
 * and disconnects afterwards.
 *
 * @param cls the closure
 * @param msg the message
 */
static void
handle_reply (void *cls,
              const struct GNUNET_RPS_CS_ReplyMessage *msg)
{
  struct GNUNET_RPS_Handle *h = cls;
  struct GNUNET_PeerIdentity *peers;
  struct GNUNET_RPS_Request_Handle *rh;
  uint32_t id;

  /* Give the peers back */
  id = ntohl (msg->id);
  LOG (GNUNET_ERROR_TYPE_DEBUG,
       "Service replied with %" PRIu32 " peers for id %" PRIu32 "\n",
       ntohl (msg->num_peers),
       id);

  peers = (struct GNUNET_PeerIdentity *) &msg[1];
  GNUNET_assert (GNUNET_YES ==
      GNUNET_CONTAINER_multihashmap32_contains (h->req_handlers, id));
  rh = GNUNET_CONTAINER_multihashmap32_get (h->req_handlers, id);
  GNUNET_assert (NULL != rh);
  GNUNET_assert (rh->num_peers == ntohl (msg->num_peers));
  GNUNET_CONTAINER_multihashmap32_remove_all (h->req_handlers, id);
  rh->ready_cb (rh->ready_cb_cls,
                ntohl (msg->num_peers),
                peers);
}


/**
 * Reconnect to the service
 */
static void
reconnect (struct GNUNET_RPS_Handle *h);


/**
 * Error handler for mq.
 *
 * This function is called whan mq encounters an error.
 * Until now mq doesn't provide useful error messages.
 *
 * @param cls the closure
 * @param error error code without specyfied meaning
 */
static void
mq_error_handler (void *cls,
                  enum GNUNET_MQ_Error error)
{
  struct GNUNET_RPS_Handle *h = cls;
  //TODO LOG
  LOG (GNUNET_ERROR_TYPE_WARNING, "Problem with message queue. error: %i\n\
       1: READ,\n\
       2: WRITE,\n\
       4: TIMEOUT\n",
       error);
  reconnect (h);
  /* Resend all pending request as the service destroyed its knowledge
   * about them */
  resend_requests (h);
}


/**
 * Reconnect to the service
 */
static void
reconnect (struct GNUNET_RPS_Handle *h)
{
  struct GNUNET_MQ_MessageHandler mq_handlers[] = {
    GNUNET_MQ_hd_var_size (reply,
                           GNUNET_MESSAGE_TYPE_RPS_CS_REPLY,
                           struct GNUNET_RPS_CS_ReplyMessage,
                           h),
    GNUNET_MQ_handler_end ()
  };

  if (NULL != h->mq)
    GNUNET_MQ_destroy (h->mq);
  h->mq = GNUNET_CLIENT_connect (h->cfg,
                                 "rps",
                                 mq_handlers,
                                 &mq_error_handler,
                                 h);
}


/**
 * Connect to the rps service
 *
 * @param cfg configuration to use
 * @return a handle to the service
 */
struct GNUNET_RPS_Handle *
GNUNET_RPS_connect (const struct GNUNET_CONFIGURATION_Handle *cfg)
{
  struct GNUNET_RPS_Handle *h;

  h = GNUNET_new (struct GNUNET_RPS_Handle);
  h->cfg = cfg;
  reconnect (h);
  if (NULL == h->mq)
  {
    GNUNET_free (h);
    return NULL;
  }
  h->req_handlers = GNUNET_CONTAINER_multihashmap32_create (4);
  return h;
}


/**
 * Request n random peers.
 *
 * @param rps_handle handle to the rps service
 * @param num_req_peers number of peers we want to receive
 * @param ready_cb the callback called when the peers are available
 * @param cls closure given to the callback
 * @return a handle to cancel this request
 */
struct GNUNET_RPS_Request_Handle *
GNUNET_RPS_request_peers (struct GNUNET_RPS_Handle *rps_handle,
                          uint32_t num_req_peers,
                          GNUNET_RPS_NotifyReadyCB ready_cb,
                          void *cls)
{
  struct GNUNET_RPS_Request_Handle *rh;

  rh = GNUNET_new (struct GNUNET_RPS_Request_Handle);
  rh->rps_handle = rps_handle;
  rh->id = rps_handle->current_request_id++;
  rh->num_peers = num_req_peers;
  rh->ready_cb = ready_cb;
  rh->ready_cb_cls = cls;

  LOG (GNUNET_ERROR_TYPE_DEBUG,
       "Requesting %" PRIu32 " peers with id %" PRIu32 "\n",
       num_req_peers,
       rh->id);

  GNUNET_CONTAINER_multihashmap32_put (rps_handle->req_handlers, rh->id, rh,
      GNUNET_CONTAINER_MULTIHASHMAPOPTION_UNIQUE_FAST);

  send_request (rps_handle, rh->id, num_req_peers);
  return rh;
}


/**
 * Seed rps service with peerIDs.
 *
 * @param h handle to the rps service
 * @param n number of peers to seed
 * @param ids the ids of the peers seeded
 */
void
GNUNET_RPS_seed_ids (struct GNUNET_RPS_Handle *h,
                     uint32_t n,
                     const struct GNUNET_PeerIdentity *ids)
{
  size_t size_needed;
  uint32_t num_peers_max;
  const struct GNUNET_PeerIdentity *tmp_peer_pointer;
  struct GNUNET_MQ_Envelope *ev;
  struct GNUNET_RPS_CS_SeedMessage *msg;

  unsigned int i;

  LOG (GNUNET_ERROR_TYPE_DEBUG,
       "Client wants to seed %" PRIu32 " peers:\n",
       n);
  for (i = 0 ; i < n ; i++)
    LOG (GNUNET_ERROR_TYPE_DEBUG,
         "%u. peer: %s\n",
         i,
         GNUNET_i2s (&ids[i]));

  /* The actual size the message occupies */
  size_needed = sizeof (struct GNUNET_RPS_CS_SeedMessage) +
    n * sizeof (struct GNUNET_PeerIdentity);
  /* The number of peers that fits in one message together with
   * the respective header */
  num_peers_max = (GNUNET_SERVER_MAX_MESSAGE_SIZE -
      sizeof (struct GNUNET_RPS_CS_SeedMessage)) /
    sizeof (struct GNUNET_PeerIdentity);
  tmp_peer_pointer = ids;

  while (GNUNET_SERVER_MAX_MESSAGE_SIZE < size_needed)
  {
    ev = GNUNET_MQ_msg_extra (msg, num_peers_max * sizeof (struct GNUNET_PeerIdentity),
        GNUNET_MESSAGE_TYPE_RPS_CS_SEED);
    msg->num_peers = htonl (num_peers_max);
    GNUNET_memcpy (&msg[1], tmp_peer_pointer, num_peers_max * sizeof (struct GNUNET_PeerIdentity));
    GNUNET_MQ_send (h->mq, ev);

    n -= num_peers_max;
    size_needed = sizeof (struct GNUNET_RPS_CS_SeedMessage) +
                  n * sizeof (struct GNUNET_PeerIdentity);
    /* Set pointer to beginning of next block of num_peers_max peers */
    tmp_peer_pointer = &ids[num_peers_max];
  }

  ev = GNUNET_MQ_msg_extra (msg, n * sizeof (struct GNUNET_PeerIdentity),
                            GNUNET_MESSAGE_TYPE_RPS_CS_SEED);
  msg->num_peers = htonl (n);
  GNUNET_memcpy (&msg[1], tmp_peer_pointer, n * sizeof (struct GNUNET_PeerIdentity));

  GNUNET_MQ_send (h->mq, ev);
}


#ifdef ENABLE_MALICIOUS
/**
 * Turn RPS service to act malicious.
 *
 * @param h handle to the rps service
 * @param type which type of malicious peer to turn to.
 *             0 Don't act malicious at all
 *             1 Try to maximise representation
 *             2 Try to partition the network
 *               (isolate one peer from the rest)
 * @param n number of @a ids
 * @param ids the ids of the malicious peers
 *            if @type is 2 the last id is the id of the
 *            peer to be isolated from the rest
 */
void
GNUNET_RPS_act_malicious (struct GNUNET_RPS_Handle *h,
                          uint32_t type,
                          uint32_t num_peers,
                          const struct GNUNET_PeerIdentity *peer_ids,
                          const struct GNUNET_PeerIdentity *target_peer)
{
  size_t size_needed;
  uint32_t num_peers_max;
  const struct GNUNET_PeerIdentity *tmp_peer_pointer;
  struct GNUNET_MQ_Envelope *ev;
  struct GNUNET_RPS_CS_ActMaliciousMessage *msg;

  unsigned int i;

  LOG (GNUNET_ERROR_TYPE_DEBUG,
       "Client turns malicious (type %" PRIu32 ") with %" PRIu32 " other peers:\n",
       type,
       num_peers);
  for (i = 0 ; i < num_peers ; i++)
    LOG (GNUNET_ERROR_TYPE_DEBUG,
         "%u. peer: %s\n",
         i,
         GNUNET_i2s (&peer_ids[i]));

  /* The actual size the message would occupy */
  size_needed = sizeof (struct GNUNET_RPS_CS_SeedMessage) +
    num_peers * sizeof (struct GNUNET_PeerIdentity);
  /* The number of peers that fit in one message together with
   * the respective header */
  num_peers_max = (GNUNET_SERVER_MAX_MESSAGE_SIZE -
      sizeof (struct GNUNET_RPS_CS_SeedMessage)) /
    sizeof (struct GNUNET_PeerIdentity);
  tmp_peer_pointer = peer_ids;

  while (GNUNET_SERVER_MAX_MESSAGE_SIZE < size_needed)
  {
    LOG (GNUNET_ERROR_TYPE_DEBUG,
         "Too many peers to send at once, sending %" PRIu32 " (all we can so far)\n",
         num_peers_max);
    ev = GNUNET_MQ_msg_extra (msg,
                              num_peers_max * sizeof (struct GNUNET_PeerIdentity),
                              GNUNET_MESSAGE_TYPE_RPS_ACT_MALICIOUS);
    msg->type = htonl (type);
    msg->num_peers = htonl (num_peers_max);
    if ( (2 == type) ||
         (3 == type) )
      msg->attacked_peer = peer_ids[num_peers];
    GNUNET_memcpy (&msg[1],
            tmp_peer_pointer,
            num_peers_max * sizeof (struct GNUNET_PeerIdentity));

    GNUNET_MQ_send (h->mq, ev);

    num_peers -= num_peers_max;
    size_needed = sizeof (struct GNUNET_RPS_CS_SeedMessage) +
                  num_peers * sizeof (struct GNUNET_PeerIdentity);
    /* Set pointer to beginning of next block of num_peers_max peers */
    tmp_peer_pointer = &peer_ids[num_peers_max];
  }

  ev = GNUNET_MQ_msg_extra (msg,
                            num_peers * sizeof (struct GNUNET_PeerIdentity),
                            GNUNET_MESSAGE_TYPE_RPS_ACT_MALICIOUS);
  msg->type = htonl (type);
  msg->num_peers = htonl (num_peers);
  if ( (2 == type) ||
       (3 == type) )
    msg->attacked_peer = *target_peer;
  GNUNET_memcpy (&msg[1], tmp_peer_pointer, num_peers * sizeof (struct GNUNET_PeerIdentity));

  GNUNET_MQ_send (h->mq, ev);
}
#endif /* ENABLE_MALICIOUS */


/**
 * Cancle an issued request.
 *
 * @param rh request handle of request to cancle
 */
void
GNUNET_RPS_request_cancel (struct GNUNET_RPS_Request_Handle *rh)
{
  struct GNUNET_RPS_Handle *h;
  struct GNUNET_MQ_Envelope *ev;
  struct GNUNET_RPS_CS_RequestCancelMessage*msg;

  LOG (GNUNET_ERROR_TYPE_DEBUG,
       "Cancelling request with id %" PRIu32 "\n",
       rh->id);

  h = rh->rps_handle;
  GNUNET_assert (GNUNET_CONTAINER_multihashmap32_contains (h->req_handlers,
        rh->id));
  GNUNET_CONTAINER_multihashmap32_remove_all (h->req_handlers, rh->id);
  ev = GNUNET_MQ_msg (msg, GNUNET_MESSAGE_TYPE_RPS_CS_REQUEST_CANCEL);
  msg->id = htonl (rh->id);
  GNUNET_MQ_send (rh->rps_handle->mq, ev);
}


/**
 * Disconnect from the rps service
 *
 * @param h the handle to the rps service
 */
void
GNUNET_RPS_disconnect (struct GNUNET_RPS_Handle *h)
{
  GNUNET_MQ_destroy (h->mq);
  if (0 < GNUNET_CONTAINER_multihashmap32_size (h->req_handlers))
    LOG (GNUNET_ERROR_TYPE_WARNING,
        "Still waiting for requests\n");
  GNUNET_CONTAINER_multihashmap32_destroy (h->req_handlers);
  GNUNET_free (h);
}


/* end of rps_api.c */

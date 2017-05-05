/*
 * Copyright (c) 2012-2013 by Jens V. Fischer, Zuse Institute Berlin
 *               
 *
 * Licensed under the BSD License, see LICENSE file for details.
 *
 */

package org.xtreemfs.common.benchmark;

import org.xtreemfs.common.libxtreemfs.AdminClient;
import org.xtreemfs.common.libxtreemfs.Client;
import org.xtreemfs.common.libxtreemfs.ClientFactory;
import org.xtreemfs.foundation.logging.Logging;

import java.util.LinkedList;

/**
 * Handles client creation, startup and deletion centrally.
 * <p/>
 * getNewClient() can be used to get an already started client. shutdownClients() is used to shutdown all clients
 * created so far.
 * 
 * @author jensvfischer
 */
class ClientManager {

    private LinkedList<AdminClient> clients;
    private BenchmarkConfig         config;

    ClientManager(BenchmarkConfig config) {
        this.clients = new LinkedList<AdminClient>();
        this.config = config; 
    }

    /* create and start an AdminClient. */
    AdminClient getNewClient() throws Exception {
        AdminClient client = ClientFactory.createAdminClient(config.getDirAddresses(), config.getUserCredentials(),
                config.getSslOptions(), config.getOptions());
        clients.add(client);
        client.start();
        return client;
    }

    /* shutdown all clients */
    void shutdownClients() {
        for (AdminClient client : clients) {
            tryShutdownOfClient(client);
        }
        Logging.logMessage(Logging.LEVEL_INFO, Logging.Category.tool, ClientManager.class,
                "Shutting down %s clients", clients.size());
    }


    private void tryShutdownOfClient(Client client) {
        try {
            client.shutdown();
        } catch (Throwable e) {
            Logging.logMessage(Logging.LEVEL_WARN, Logging.Category.tool, ClientManager.class,
                    "Error while shutting down clients");
            Logging.logError(Logging.LEVEL_WARN, ClientManager.class, e);
        }
    }

}

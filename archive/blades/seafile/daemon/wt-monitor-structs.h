#ifndef WT_MONITOR_STRUCTS_H
#define WT_MONITOR_STRUCTS_H

#include <glib.h>
#include <pthread.h>

enum {
    WT_EVENT_CREATE_OR_UPDATE = 0,
    WT_EVENT_DELETE,
    WT_EVENT_RENAME,
    WT_EVENT_ATTRIB,
    WT_EVENT_OVERFLOW,
};

typedef struct WTEvent {
    int ev_type;
    char *path;
    char *new_path;             /* only used by rename event */

    /* For CREATE_OR_UPDATE events, if a partial commit was created when
     * adding files recursively, the remaining files will be cached in
     * this queue so that we don't have to rescan the dir from beginning.
     */
    GQueue *remain_files;
} WTEvent;

WTEvent *wt_event_new (int type, const char *path, const char *new_path);

void wt_event_free (WTEvent *event);

typedef struct WTStatus {
    int         ref_count;

    char        repo_id[37];
    gint        last_check;
    gint        last_changed;

    /* If last_event is non-NULL, the last commit is partial.
     * We need to produce another commit from the remaining events.
     */
    WTEvent     *last_event;

    pthread_mutex_t q_lock;
    GQueue *event_q;
} WTStatus;

WTStatus *create_wt_status (const char *repo_id);

void wt_status_ref (WTStatus *status);

void wt_status_unref (WTStatus *status);

#endif

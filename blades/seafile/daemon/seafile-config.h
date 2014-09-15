/* -*- Mode: C; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*- */

#ifndef SEAFILE_CONFIG_H
#define SEAFILE_CONFIG_H

#include "seafile-session.h"
#include "db.h"

#define KEY_MONITOR_ID  "monitor_id"
#define KEY_CHECK_REPO_PERIOD "check_repo_period"
#define KEY_DB_HOST "db_host"
#define KEY_DB_USER "db_user"
#define KEY_DB_PASSWD "db_passwd"
#define KEY_DB_NAME "db_name"
#define KEY_UPLOAD_LIMIT "upload_limit"
#define KEY_DOWNLOAD_LIMIT "download_limit"
#define KEY_ALLOW_INVALID_WORKTREE "allow_invalid_worktree"
#define KEY_ALLOW_REPO_NOT_FOUND_ON_SERVER "allow_repo_not_found_on_server"

/*
 * Returns: config value in string. The string should be freed by caller. 
 */
char *
seafile_session_config_get_string (SeafileSession *session,
                                   const char *key);

/*
 * Returns:
 * If key exists, @exists will be set to TRUE and returns the value;
 * otherwise, @exists will be set to FALSE and returns -1.
 */
int
seafile_session_config_get_int (SeafileSession *session,
                                const char *key,
                                gboolean *exists);

int
seafile_session_config_set_string (SeafileSession *session,
                                   const char *key,
                                   const char *value);

int
seafile_session_config_set_int (SeafileSession *session,
                                const char *key,
                                int value);

int
seafile_session_config_set_allow_invalid_worktree(SeafileSession *session, gboolean val);

gboolean
seafile_session_config_get_allow_invalid_worktree(SeafileSession *session);

gboolean
seafile_session_config_get_allow_repo_not_found_on_server(SeafileSession *session);

sqlite3 *
seafile_session_config_open_db (const char *db_path);


#endif

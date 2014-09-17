<?php
/**
 * @package Airtime
 * @copyright 2010 Sourcefabric O.P.S.
 * @license http://www.gnu.org/licenses/gpl.txt
 */

require_once(dirname(__FILE__).'/AirtimeIni.php');
require_once(dirname(__FILE__).'/AirtimeInstall.php');
// Need to check that we are superuser before running this.
AirtimeInstall::ExitIfNotRoot();

if (!file_exists(AirtimeIni::CONF_FILE_AIRTIME)) {
    echo PHP_EOL."Airtime config file '".AirtimeIni::CONF_FILE_AIRTIME."' does not exist.".PHP_EOL;
    echo "Most likely this means that Airtime is not installed, so there is nothing to do.".PHP_EOL.PHP_EOL;
    exit();
}
require_once(__DIR__.'/airtime-constants.php');
require_once(AirtimeInstall::GetAirtimeSrcDir().'/application/configs/conf.php');
$CC_CONFIG = Config::getConfig();


require_once 'propel/runtime/lib/Propel.php';
Propel::init(AirtimeInstall::GetAirtimeSrcDir()."/application/configs/airtime-conf-production.php");

echo PHP_EOL;
echo "* Uninstalling Airtime ".AIRTIME_VERSION.PHP_EOL;

//------------------------------------------------------------------------
// Delete the database
// Note: Do not put a call to AirtimeInstall::DbConnect()
// before this function, it will create a connection to the database
// and you wont be able to delete it.
//------------------------------------------------------------------------

//close connection for any process id using airtime database since we are about to drop the database.
$sql = "SELECT pg_cancel_backend(procpid) FROM pg_stat_activity WHERE datname = 'airtime';";
$command = "echo \"$sql\" | su postgres -c psql";
@exec($command, $output);

$CC_CONFIG = Config::getConfig();
echo " * Dropping the database '".$CC_CONFIG["dsn"]["database"]."'...".PHP_EOL;

//dropdb returns 1 if other sessions are using the database, otherwise returns 0
$command = "su postgres -c \"dropdb ".$CC_CONFIG["dsn"]["database"]."\"";

@exec($command, $output, $dbDeleteFailed);

//------------------------------------------------------------------------
// Delete DB tables
// We do this if dropping the database fails above.
//------------------------------------------------------------------------
if ($dbDeleteFailed) {
    $connected = AirtimeInstall::DbConnect(false);

    if ($connected) {
        echo " * Couldn't delete the database, so deleting all the DB tables...".PHP_EOL;
        $con = Propel::getConnection();
        $sql = "select * from pg_tables where tableowner = 'airtime'";
        try {
            $rows = $con->query($sql)->fetchAll();
        } catch (Exception $e) {
            $rows = array();
        }

        foreach ($rows as $row) {
            $tablename = $row["tablename"];
            echo "   * Removing database table $tablename...";

            $sql = "DROP TABLE $tablename CASCADE";
            AirtimeInstall::InstallQuery($sql, false);
            AirtimeInstall::DropSequence($tablename."_id");
            echo "done.".PHP_EOL;
        }


        echo " * Deleting database sequences...".PHP_EOL;
        $sql = "SELECT c.relname FROM pg_class c WHERE c.relkind = 'S';";
        try {
            $rows = $con->query($sql)->fetchAll();
        } catch (Exception $e) {
            $rows = array();
        }

        foreach ($rows as $row) {
            $sequence = $row["relname"];
            echo "   * Removing database sequence $sequence...";

            $sql = "DROP SEQUENCE $sequence CASCADE";
            AirtimeInstall::InstallQuery($sql, false);
            echo "done.".PHP_EOL;
        }
    }
}

//------------------------------------------------------------------------
// Delete the user
//------------------------------------------------------------------------
echo " * Deleting database user '{$CC_CONFIG['dsn']['username']}'...".PHP_EOL;
$command = "echo \"DROP USER IF EXISTS {$CC_CONFIG['dsn']['username']}\" | su postgres -c psql >/dev/null 2>&1";
@exec($command, $output, $results);
if ($results == 0) {
    echo "   * User '{$CC_CONFIG['dsn']['username']}' deleted.".PHP_EOL;
} else {
    echo "   * Nothing to delete.".PHP_EOL;
}


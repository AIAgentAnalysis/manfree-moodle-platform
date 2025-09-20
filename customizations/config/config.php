<?php
unset($CFG);
global $CFG;
$CFG = new stdClass();

$CFG->dbtype    = 'mariadb';
$CFG->dblibrary = 'native';
$CFG->dbhost    = 'mariadb';
$CFG->dbname    = 'moodle';
$CFG->dbuser    = 'moodle';
$CFG->dbpass    = 'moodle123';
$CFG->prefix    = 'mdl_';
$CFG->dboptions = array (
  'dbpersist' => 0,
  'dbport' => '',
  'dbsocket' => '',
  'dbcollation' => 'utf8mb4_unicode_ci',
);

// Dynamic URL detection for tunnels
if (isset($_SERVER['HTTP_HOST']) && strpos($_SERVER['HTTP_HOST'], 'learning.manfreetechnologies.com') !== false) {
    $CFG->wwwroot = 'https://learning.manfreetechnologies.com';
    $CFG->sslproxy = true;
    $_SERVER['HTTPS'] = 'on';
    $_SERVER['SERVER_PORT'] = 443;
} elseif (isset($_SERVER['HTTP_HOST']) && strpos($_SERVER['HTTP_HOST'], 'ngrok') !== false) {
    $CFG->wwwroot = 'https://' . $_SERVER['HTTP_HOST'];
    $CFG->sslproxy = true;
    $_SERVER['HTTPS'] = 'on';
    $_SERVER['SERVER_PORT'] = 443;
} elseif (isset($_SERVER['HTTP_HOST']) && strpos($_SERVER['HTTP_HOST'], 'trycloudflare') !== false) {
    $CFG->wwwroot = 'https://' . $_SERVER['HTTP_HOST'];
    $CFG->sslproxy = true;
    $_SERVER['HTTPS'] = 'on';
    $_SERVER['SERVER_PORT'] = 443;
} elseif (isset($_SERVER['HTTP_HOST']) && strpos($_SERVER['HTTP_HOST'], 'bore.pub') !== false) {
    $CFG->wwwroot = 'https://' . $_SERVER['HTTP_HOST'];
    $CFG->sslproxy = true;
    $_SERVER['HTTPS'] = 'on';
    $_SERVER['SERVER_PORT'] = 443;
} elseif (isset($_SERVER['HTTP_HOST']) && strpos($_SERVER['HTTP_HOST'], 'pinggy.io') !== false) {
    $CFG->wwwroot = 'https://' . $_SERVER['HTTP_HOST'];
    $CFG->sslproxy = true;
    $_SERVER['HTTPS'] = 'on';
    $_SERVER['SERVER_PORT'] = 443;
} elseif (isset($_SERVER['HTTP_HOST']) && strpos($_SERVER['HTTP_HOST'], 'loca.lt') !== false) {
    $CFG->wwwroot = 'https://' . $_SERVER['HTTP_HOST'];
    $CFG->sslproxy = true;
    $_SERVER['HTTPS'] = 'on';
    $_SERVER['SERVER_PORT'] = 443;
} else {
    $CFG->wwwroot = 'http://localhost:8080';
}
$CFG->dataroot  = '/var/www/moodledata';
$CFG->admin     = 'admin';

$CFG->directorypermissions = 0777;

// File upload limits - 100MB
$CFG->maxbytes = 104857600; // 100MB in bytes

// Dynamic tunnel detection handles SSL automatically

require_once(__DIR__ . '/lib/setup.php');

// There is no php closing tag in this file,
// it is intentional because it prevents trailing whitespace problems!
<?php

/**
 * AUTHOR : Virink <virink@outlook.com>
 * LICENSE : MIT
 */

const HOST="127.0.0.1";
const USER="root";
const PASS="";
const NAME="mysql";
const CHARSET="utf8";

const RESET = "set global general_log=off;truncate table general_log;SET GLOBAL log_output='table';set global general_log=on;";
const GET_SQL = "SELECT event_time,argument FROM mysql.general_log WHERE (command_type = 'Query' OR command_type = 'Execute') AND unix_timestamp(event_time) > :event_time AND argument NOT LIKE '%general_log%' AND argument NOT LIKE '%select event_time,argument from%' AND argument NOT LIKE '%SHOW%' AND argument NOT LIKE '%SELECT STATE%' AND argument NOT LIKE '%SET NAMES%' AND argument NOT LIKE '%SET PROFILING%' AND argument NOT LIKE '%stime_virink%' AND argument NOT LIKE '%SELECT QUERY_ID%' order by event_time desc;";
const GET_TIME = "select unix_timestamp() as 'stime_virink' from dual;";

session_start();

$dbh = new PDO(sprintf("mysql:host=%s;dbname=%s", HOST, NAME), USER, PASS);
$dbh->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
$dbh->exec("set names ".CHARSET);

$action = isset($_REQUEST['a'])?$_REQUEST['a']:'';

function set_time()
{
    if (isset($_SESSION['time']) && $_SESSION['time']) {
        $_SESSION['event_time'] = time();
    } else {
        $stmt = $dbh->prepare(GET_TIME);
        $stmt->execute();
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$_SESSION['time'] && abs(time()-$row['stime_virink']) <= 5) {
            $_SESSION['time'] = 1;
            $_SESSION['event_time'] = time();
            return 0;
        }
        $_SESSION['event_time'] = $row['stime_virink'];
    }
}

function json_output($msg = "", $code = 0)
{
    header('Content-type: application/json');
    echo json_encode(["code"=>$code,"msg"=>$msg]);
    die();
}

switch ($action) {
    case 'reset':
        $stmt = $dbh->prepare(RESET);
        $stmt->execute();
        break;
    case 'settime':
        set_time();
        break;
    case 'getsql':
        $stmt = $dbh->prepare(GET_SQL);
        $stmt->execute([':event_time'=>$_SESSION['event_time']]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
        json_output($rows);
        set_time();
        break;
    case 'debug':
        echo "<pre>";
        print_r($_SESSION);
        break;
    default:
        exit(json_encode(["code"=>-1,"msg"=>"No Action!"]));
        break;
}

$dbh=null;

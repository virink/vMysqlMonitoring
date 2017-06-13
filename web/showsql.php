<?php

$sn = $_SERVER['SCRIPT_NAME'];

if(!isset($_COOKIE['conn'])){
    header("Location: {$sn}?m=config");exit;
}

$m = isset($_GET['m'])?$_GET['m']:'config';

?>

<html>
    <head>
        <title>vMysqlMonitoring</title>
        <style>
            nav {
                font-size: 32px;
            }
        </style>
    </head>
    <body>
        <nav>
            <span><a href="?m=config">Config</a></span>
            <span><a href="?m=show">Show</a></span>
            <span><a href="?m=help">Help</a></span>
        </nav>
        <hr/>
        <div>
<?php
if($m == 'config'){
    if(isset($_POST['host']) && isset($_POST['user']) && isset($_POST['pass'])){
        $data = array(
            "host"=>$_POST['host'],
            "user"=>$_POST['user'],
            "pass"=>$_POST['pass']
        );
        setcookie("conn",json_encode($data));
        header("Location: {$sn}?m=show");exit;
    }
?>
        <form action="" method=post >
            <input type="text" name="host" value="127.0.0.1:3306"><br/>
            <input type="text" name="user" value="root"><br/>
            <input type="text" name="pass" value="root"><br/>
            <input type="submit" name="submit" value="Set"><br/>
        </form>
<?php
}elseif($m=='help'){
?>
    Your should SET time_zone = '+8:00';
<?php
}else{

    $conf = json_decode($_COOKIE['conn'],true);

    $conn = mysql_connect($conf['host'],$conf['user'],$conf['pass']);
    if (!$conn)
    {
        header("Location: {$sn}?m=config&error=".mysql_error());exit;
    }

    if(isset($_POST['filter']) and $_POST['filter'] != ""){
        // var_dump($_POST['filter']);
        $f = explode('|',$_POST['filter']);
        $filter = "";
        foreach ($f as $v) {
            $filter .= " and argument not like '%{$v}%'";
        }
    }else{
        $filter = "";
    }

    mysql_select_db("mysql", $conn);

    mysql_query("SET GLOBAL general_log=on;") or die("<h1>Could not connect: " . mysql_error()."</h1>");
    mysql_query("SET GLOBAL log_output='table';") or die("<h1>Could not connect: " . mysql_error()."</h1>");
    // mysql_query("SET time_zone = '+8:00';") or die("<h1>Could not connect: " . mysql_error()."</h1>");


    $time = time();
    $last = $_COOKIE['last'];

    $sql = "select unix_timestamp(event_time) as time ,argument from mysql.general_log where command_type='Query' and unix_timestamp(event_time)>{$last} and unix_timestamp(event_time)<{$time}{$filter};";

    $res = mysql_query($sql);

    setcookie("last",time()+1);

    ?>
    <form action="" method="post">
        <input type="text" name="filter" placeholder="filter|filter" value="<?=$_POST['filter']?>">
        <input type="submit" name="view" value="view">
    </form>
    <?php

    echo "<table border=1>";
    echo "<tr><th>Time</th><th>Sql</th></tr>";

    while($row = mysql_fetch_array($res))
    {
        echo "<tr><td>". date("h:i:s",$row['time']) . "</td><td>" . $row['argument']."</td></tr>";
    }

    mysql_close($conn);
    echo "</table>";
}

?>
        </div>
    </body>
</html>

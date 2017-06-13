# vMysqlMonitoring

## List

- Windows (c-sharp)
- OSX (swift)
- Web (php)

## kernel

**Open log**

    SET GLOBAL general_log=on;

**Set log output**

    SET GLOBAL log_output='table';

**Select log**

    SELECT unix_timestamp(event_time) as time ,argument FROM mysql.general_log WHERE command_type='Query' and unix_timestamp(event_time)>{last_time} and unix_timestamp(event_time)<{now_time} and argument not like '%{filter}%';
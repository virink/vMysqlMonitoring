//
//  DBManager.m
//  vMysqlMonitoring
//
//  Created by Virink on 2018-17-02.
//  Copyright © 2018 Virink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DBManager.h"
#import "mysql.h"

@interface DBManager() {
    MYSQL *_myconnect;
    NSString *_time;
}
@end

@implementation DBManager

+(DBManager *)sharedManager
{
    static DBManager *sharedSingleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^(void) {
        sharedSingleton = [[self alloc] init];
    });
    return sharedSingleton;
}

//- (instancetype)init:(NSString*)host user:(NSString*)user pass:(NSString*)pass name:(NSString*)name port:(unsigned int)port {
- (instancetype)init {
    if (self = [super init]) {
        _time = @"";
    }
    return self;
}

- (BOOL)connect:(NSString *)host connectUser:(NSString *)user connectPassword:(NSString *)pass connectName:(NSString *)name connectPort:(unsigned int)port
{
    _myconnect = mysql_init(_myconnect);
    _myconnect = mysql_real_connect(_myconnect,[host UTF8String],[user UTF8String],[pass UTF8String],[name UTF8String],port,NULL,CLIENT_MULTI_STATEMENTS);
    if (_myconnect != NULL) {
        mysql_set_character_set(_myconnect, "utf8");
        VLog(@"连接成功");
        return true;
    } else {
        VLog(@"连接失败 %s", mysql_error(_myconnect));
        return false;
    }
}

- (BOOL)disconnect
{
    mysql_close(_myconnect);
    VLog(@"Close From Mysql");
    return true;
}

- (NSMutableArray *)getAllSqls {
    NSMutableArray *false_data = [[NSMutableArray alloc] initWithObjects:[[NSMutableArray alloc] init], nil];
    if (_myconnect == NULL ) {
        VLog(@"getAllSqls ： 连接数据库失败 %s", mysql_error(_myconnect));
        return false_data;
    }
    if ( [_time  isEqual: @""]) {
        VLog(@"getAllSqls ： 没设置时间节点 %s", mysql_error(_myconnect));
        return false_data;
    }
    NSString *sql = [NSString stringWithFormat:@"SELECT event_time,argument FROM mysql.general_log WHERE (command_type = 'Query' OR command_type = 'Execute') AND unix_timestamp(event_time) > %@ AND argument NOT LIKE '%%general_log%%' AND argument NOT LIKE '%%select event_time,argument from%%' AND argument NOT LIKE '%%SHOW%%' AND argument NOT LIKE '%%SELECT STATE%%' AND argument NOT LIKE '%%SET NAMES%%' AND argument NOT LIKE '%%SET PROFILING%%' AND argument NOT LIKE '%%stime_virink%%' AND argument NOT LIKE '%%SELECT QUERY_ID%%' order by event_time desc;",_time];
    int status = mysql_query(_myconnect, [sql UTF8String]);
    if (status != 0) {
        VLog(@"查询数据失败 %s", mysql_error(_myconnect));
        return false_data;
    }
    MYSQL_RES *result = mysql_store_result(_myconnect);
    long long rows =result->row_count;
    NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:rows];
    unsigned int fieldCount = mysql_field_count(_myconnect);
    MYSQL_ROW row;
    for (int j = 0; j < rows; j++) {
        NSMutableArray *rowArray = [[NSMutableArray alloc] init];
        if((row = mysql_fetch_row(result))){
            for(int i = 0; i < fieldCount; i++){
                [rowArray addObject:[[NSString alloc] initWithUTF8String:row[i]]];
            }
        }
        [resultArray addObject:rowArray];
    }
    mysql_free_result(result);
    row = NULL;
    return resultArray;
}

- (BOOL)getTime {
    if (_myconnect == NULL) {
        VLog(@"getTime ： 连接数据库失败 %s", mysql_error(_myconnect));
        _time = @"";
        return false;
    }
    NSString *sql = @"select unix_timestamp() as 'stime_virink' from dual;";
    int status = mysql_query(_myconnect, [sql UTF8String]);
    if (status != 0) {
        VLog(@"获取时间失败 %s", mysql_error(_myconnect));
        _time = @"";
        return false;
    }
    MYSQL_RES *result = mysql_store_result(_myconnect);
    MYSQL_ROW col = mysql_fetch_row(result);
    _time = [NSString stringWithUTF8String:col[0]];
    mysql_free_result(result);
    return true;
}

- (BOOL)clearLog {
    if (_myconnect == NULL) {
        VLog(@"clearLog ： 连接数据库失败 %s", mysql_error(_myconnect));
        return false;
    }
    NSString *sql = @"set global general_log=off;truncate table general_log;SET GLOBAL log_output='table';set global general_log=on;";
    mysql_set_server_option(_myconnect,MYSQL_OPTION_MULTI_STATEMENTS_ON);
    int status = mysql_query(_myconnect, [sql UTF8String]);
    mysql_set_server_option(_myconnect,MYSQL_OPTION_MULTI_STATEMENTS_OFF);
    if (status == 0) {
        VLog(@"重置日志成功");
        return true;
    } else {
        VLog(@"重置日志失败 %s", mysql_error(_myconnect));
        return false;
    }
}
@end

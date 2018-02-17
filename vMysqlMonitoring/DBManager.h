//
//  Mysql.h
//  vMysqlMonitoring
//
//  Created by Virink on 2018-01-01.
//  Copyright © 2018 Virink. All rights reserved.
//

#ifndef Mysql_h
#define Mysql_h

#import <Foundation/Foundation.h>

#ifdef DEBUG
#   define VLog(FORMAT, ...) fprintf(stderr,"[%s:%d]%s\n%s\n-------------------------------------------------------\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, __FUNCTION__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#   define VLog(FORMAT, ...) nil
#endif

@class MysqlLog;

@interface DBManager : NSObject

+ (DBManager *)sharedManager;

- (BOOL)connect:(NSString *)host connectUser:(NSString *)user connectPassword:(NSString *)pass connectName:(NSString *)name connectPort:(unsigned int)port;
- (BOOL)disconnect;
- (NSMutableArray *)getAllSqls;
- (BOOL)getTime;
- (BOOL)clearLog;

@end

#endif /* Mysql_h */

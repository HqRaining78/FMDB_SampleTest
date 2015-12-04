//
//  NNFMDBTool.m
//  NN_FMDBSampleDemo
//
//  Created by IOF－IOS2 on 15/12/2.
//  Copyright © 2015年 NN_逝去. All rights reserved.
//

#import "NNFMDBTool.h"

@interface NNFMDBTool ()

@property (nonatomic, strong) FMDatabase *db;

@end

@implementation NNFMDBTool


+ (instancetype)sharedInstance
{
    static NNFMDBTool *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}


+ (NSString *)dbPathWithDirectoryName:(NSString *)directoryName DataBaseName:(NSString *)dbname
{
    NSString *docsPath = [NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSFileManager *filemanage = [NSFileManager defaultManager];
    if (directoryName == nil || directoryName.length == 0) {
        docsPath = [docsPath stringByAppendingPathComponent:@"tmp"];
    } else {
        docsPath = [docsPath stringByAppendingPathComponent:directoryName];
    }
    BOOL isDir;
    BOOL exit =[filemanage fileExistsAtPath:docsPath isDirectory:&isDir];
    if (!exit || !isDir) {
        [filemanage createDirectoryAtPath:docsPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *dbpath = [docsPath stringByAppendingPathComponent:dbname];
    NSLog(@"---------%@", dbpath);
    return dbpath;
}

- (void)execSqlInFmdb:(NSString *)fileName dbFileName:(NSString *)dbName dbHandler:(NNDBBlock)block
{
    NSString *dbPath = [[self class]dbPathWithDirectoryName:fileName DataBaseName:dbName];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if ([db open]) {
        @try {
            block(db);
        }
        @catch (NSException *exception) {
            //处理异常，也可以直接抛出，这样调用者就能捕获到异常信息
            NSLog(@"TWFmdbUtil exec sql exception: %@", exception);
        }
        @finally {
            [db close]; //如果[db open]就要保证能关闭
        }
    } else {
        NSLog(@"db open failed, path:%@, errorMsg:%@", dbPath, [db lastError]);
    }
    db = nil;
}



@end

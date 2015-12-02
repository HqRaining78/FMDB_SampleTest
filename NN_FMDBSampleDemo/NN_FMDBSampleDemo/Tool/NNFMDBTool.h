//
//  NNFMDBTool.h
//  NN_FMDBSampleDemo
//
//  Created by IOF－IOS2 on 15/12/2.
//  Copyright © 2015年 NN_逝去. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

typedef void(^NNDBBlock)(FMDatabase *nn_db);

@interface NNFMDBTool : NSObject

+ (instancetype)sharedInstance;

- (void)execSqlInFmdb:(NSString *)fileName dbFileName:(NSString *)dbName dbHandler:(NNDBBlock)block;

@end

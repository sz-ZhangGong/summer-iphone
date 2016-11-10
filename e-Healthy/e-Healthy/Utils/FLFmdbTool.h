//
//  FLFmdbTool.h
//  e-Healthy
//
//  Created by FangLin on 16/11/9.
//  Copyright © 2016年 FangLin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@class FLPhoneLoginModel;
@interface FLFmdbTool : NSObject
/* 本地数据库路径 */
@property (nonatomic,strong)NSString *dbPath;
@property (nonatomic)sqlite3_stmt *statement;

//管理类单例
+ (FLFmdbTool *)sharedInstance;

/**
 * 打开数据库
 */
-(void)openDatabase;

/**
 * 创建表文件
 */
-(void)createTable;

// 插入模型数据
- (BOOL)insertModal:(FLPhoneLoginModel *)modal;

/** 查询数据,如果 传空 默认会查询表中所有数据 */
- (NSArray *)queryData:(NSString *)querySql;

/**
 * 删除表中所有数据
 */
//- (BOOL)deleteAllData;

/** 删除数据,如果 传空 默认会删除表中所有数据 */
- (BOOL)deleteData:(NSString *)deleteSql;

/** 修改数据 */
- (BOOL)modifyData:(NSString *)modifySql;

@end

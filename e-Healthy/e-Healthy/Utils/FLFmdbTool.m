//
//  FLFmdbTool.m
//  e-Healthy
//
//  Created by FangLin on 16/11/9.
//  Copyright © 2016年 FangLin. All rights reserved.
//

#import "FLFmdbTool.h"
#import "FLPhoneLoginModel.h"

#define FLSQLITE_NAME @"Ehealthy.sqlite"

@implementation FLFmdbTool

@synthesize dbPath;
@synthesize statement;
static FMDatabase *_fmdb = nil;

//管理类单例
+ (FLFmdbTool *)sharedInstance
{
    static FLFmdbTool *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

/**
 * 打开数据库
 */
-(void)openDatabase
{
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:FLSQLITE_NAME];
    _fmdb = [FMDatabase databaseWithPath:filePath];
    [_fmdb open];
}

/**
 * 创建表文件
 */
-(void)createTable
{
    [_fmdb executeUpdate:@"CREATE TABLE IF NOT EXISTS t_phoneLogin(id INTEGER PRIMARY KEY,color TEXT NOT NULL,image TEXT NOT NULL,text TEXT NOT NULL);"];
}

// 插入模型数据
- (BOOL)insertModal:(FLPhoneLoginModel *)modal
{
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO t_phoneLogin(color,image,text) VALUES('%@','%@','%@');",modal.color,modal.image,modal.text];
    return [_fmdb executeUpdate:insertSql];
}

/** 查询数据,如果 传空 默认会查询表中所有数据 */
- (NSArray *)queryData:(NSString *)querySql
{
    if (querySql == nil) {
        querySql = @"SELECT *FROM t_phoneLogin;";
    }
    NSMutableArray *arrM = [NSMutableArray array];
    FMResultSet *set = [_fmdb executeQuery:querySql];
    while ([set next]) {
        FLPhoneLoginModel *model = [[FLPhoneLoginModel alloc] init];
        NSString *color = [set stringForColumn:@"color"];
        NSString *image = [set stringForColumn:@"image"];
        NSString *text = [set stringForColumn:@"text"];
        model.color = color;
        model.image = image;
        model.text = text;
        [arrM addObject:model];
    }
    return arrM;
}

/** 删除数据,如果 传空 默认会删除表中所有数据 */
- (BOOL)deleteData:(NSString *)deleteSql
{
    if (deleteSql == nil) {
        deleteSql = @"DELETE FROM t_phoneLogin";
    }
    return [_fmdb executeUpdate:deleteSql];
}

/** 修改数据 */
- (BOOL)modifyData:(NSString *)modifySql
{
    if (modifySql == nil) {
        modifySql = @"UPDATE t_phoneLogin SET text = '密码登录' WHERE color = '#ffffff'";
    }
    return [_fmdb executeUpdate:modifySql];
}



@end

//
//  PhoneLoginUtils.m
//  e-Healthy
//
//  Created by FangLin on 16/11/9.
//  Copyright © 2016年 FangLin. All rights reserved.
//

#import "PhoneLoginUtils.h"
#import "FLFmdbTool.h"
#import "FLPhoneLoginModel.h"

@implementation PhoneLoginUtils

+(void)phoneLoginData:(NSDictionary *)dict
{
    FLFmdbTool *fmdbHelper = [FLFmdbTool sharedInstance];
    [fmdbHelper openDatabase];
    [fmdbHelper createTable];
    FLPhoneLoginModel *phoneLoginModel = [[FLPhoneLoginModel alloc] init];
    phoneLoginModel.color = [dict objectForKey:@"color"];
    phoneLoginModel.image = [dict objectForKey:@"image"];
    phoneLoginModel.text = [dict objectForKey:@"text"];
    BOOL isInsert = [fmdbHelper insertModal:phoneLoginModel];
    if (isInsert) {
        NSLog(@"插入数据成功");
    }else{
        NSLog(@"插入数据失败");
    }
}

@end

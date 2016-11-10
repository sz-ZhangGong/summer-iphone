//
//  MessageViewController.m
//  e-Healthy
//
//  Created by FangLin on 16/11/2.
//  Copyright © 2016年 FangLin. All rights reserved.
//

#import "MessageViewController.h"
#import "PhoneLoginUtils.h"
#import "FLFmdbTool.h"

@interface MessageViewController ()

@end

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self queryData];
}

#pragma mark - 插入数据
-(void)insertData
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"#fff234" forKey:@"color"];
    [dict setObject:@"image.png" forKey:@"image"];
    [dict setObject:@"验证码登录" forKey:@"text"];
    [PhoneLoginUtils phoneLoginData:dict];
}

//查询数据
-(void)queryData
{
    FLFmdbTool *fmdbHelper = [FLFmdbTool sharedInstance];
    [fmdbHelper openDatabase];
    [fmdbHelper createTable];
    NSArray *arr = [fmdbHelper queryData:nil];
    if (arr.count == 0) {
        [self insertData];
    }else{
        NSLog(@"arr = %@",arr);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

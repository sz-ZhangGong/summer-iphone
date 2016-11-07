//
//  RegisterViewController.m
//  e-Healthy
//
//  Created by FangLin on 16/11/4.
//  Copyright © 2016年 FangLin. All rights reserved.
//

#import "RegisterViewController.h"

@interface RegisterViewController ()

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];
    [self settingUI];
    [self createTap];
}

//设置UI
-(void)settingUI
{
    //设置back按钮的背景
    [self.backBtn addwidthWithCut:15.0f];
    //设置logo圆角
    [self.logoImageView addwidthWithCut:60.0f];
    //设置获取验证码
    [self.obtainVerBtn addwidthWithCut:13.5f];
    //设置登录注册按钮
    [self.registerBtn addwidthWithCut:17.5f];
}

#pragma mark - 创建手势
-(void)createTap
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
    self.view.userInteractionEnabled = YES;
    [self.view addGestureRecognizer:tap];
}

-(void)tapClick:(UIGestureRecognizer *)tap
{
    [self.view endEditing:YES];
}

#pragma mark - 点击事件
- (IBAction)backAction:(id)sender {//返回按钮
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)obtainVerAction:(id)sender {//获取验证码
    
}
- (IBAction)reisterAction:(id)sender {//注册
    
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

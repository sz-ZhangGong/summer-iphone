//
//  LoginViewController.m
//  e-Healthy
//
//  Created by FangLin on 16/11/3.
//  Copyright © 2016年 FangLin. All rights reserved.
//

#import "LoginViewController.h"
#import "VerificationLoginViewController.h"
#import "RegisterViewController.h"
#import "ForgetViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];
    [self settingUI];
    [self createTap];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

//设置UI
-(void)settingUI
{
    //设置back按钮的背景
    [self.backBtn addwidthWithCut:15.0f];
    //设置验证码登录按钮
    [self.verificationLoginBtn addwidthWithCorner:15.0f withborderWidth:1.0f withborderColor:RGBColor(45, 160, 173, 1.0)];
    //设置logo圆角
    [self.logoImageView addwidthWithCut:60.0f];
    //设置登录注册按钮
    [self.loginBtn addwidthWithCut:17.5f];
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
- (IBAction)backAction:(id)sender {//返回按钮事件
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)verificationLoginAction:(id)sender {//验证码登录事件
    VerificationLoginViewController *verifiVC = [[VerificationLoginViewController alloc] init];
    [self.navigationController pushViewController:verifiVC animated:YES];
}
- (IBAction)forgetAction:(id)sender {//忘记密码事件
    ForgetViewController *forgetVC = [[ForgetViewController alloc] init];
    [self.navigationController pushViewController:forgetVC animated:YES];
}
- (IBAction)loginAction:(id)sender {//登录事件
    
}
- (IBAction)registerAction:(id)sender {//注册事件
    RegisterViewController *registerVC = [[RegisterViewController alloc] init];
    [self.navigationController pushViewController:registerVC animated:YES];
}
- (IBAction)qqLoginAction:(id)sender {//qq登录事件
    
}
- (IBAction)wechatLoginAction:(id)sender {//微信登录事件
    
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

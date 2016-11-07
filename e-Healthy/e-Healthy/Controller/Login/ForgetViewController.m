//
//  ForgetViewController.m
//  e-Healthy
//
//  Created by FangLin on 16/11/7.
//  Copyright © 2016年 FangLin. All rights reserved.
//

#import "ForgetViewController.h"

@interface ForgetViewController ()

@end

@implementation ForgetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = RGBColor(248, 248, 248, 1.0);
    [self setNavTitle:@"忘记密码"];
    [self settingUI];
    [self createTap];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

//设置UI
-(void)settingUI
{
    [self.confirmBtn addwidthWithCut:5.0f];
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
- (IBAction)verificationAction:(id)sender {//获取验证码
    
}
- (IBAction)confirmAction:(id)sender {//确认
    
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

//
//  ForgetViewController.h
//  e-Healthy
//
//  Created by FangLin on 16/11/7.
//  Copyright © 2016年 FangLin. All rights reserved.
//

#import "BaseViewController.h"

@interface ForgetViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UITextField *phoneTF;
@property (weak, nonatomic) IBOutlet UITextField *verificationTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UIButton *verificationBtn;

@end

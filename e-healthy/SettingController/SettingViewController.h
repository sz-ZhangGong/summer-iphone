//
//  SettingViewController.h
//  e-healthy
//
//  Created by FangLin on 11/21/16.
//  Copyright © 2016 FangLin. All rights reserved.
//

#import "BaseViewController.h"

@protocol SettingViewController <NSObject>

-(void)perverseInfo:(float)scale;

@end

@interface SettingViewController : BaseViewController

@property (nonatomic,strong)id<SettingViewController> delegate;

@end

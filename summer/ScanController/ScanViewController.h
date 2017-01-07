//
//  lhScanQCodeViewController.h
//  lhScanQCodeTest
//
//  Created by bosheng on 15/10/20.
//  Copyright © 2015年 bosheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@protocol ScanViewController <NSObject>

-(void)scanCardReturn:(NSString *)urlStr;

-(void)backBar;

@end

@interface ScanViewController : BaseViewController

@property (nonatomic,strong)id<ScanViewController> delegate;

@end

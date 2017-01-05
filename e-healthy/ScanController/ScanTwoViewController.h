//
//  ScanTwoViewController.h
//  e-healthy
//
//  Created by FangLin on 1/3/17.
//  Copyright © 2017 FangLin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ScanViewController <NSObject>

-(void)scanCardReturn:(NSString *)urlStr;

@end

@interface ScanTwoViewController : UIViewController
@property (nonatomic,strong)id<ScanViewController> delegate;

@end

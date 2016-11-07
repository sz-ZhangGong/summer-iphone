//
//  MainFirstTableViewCell.h
//  e-Healthy
//
//  Created by FangLin on 16/11/4.
//  Copyright © 2016年 FangLin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  MainFirstTableViewCell <NSObject>

-(void)firstTapClick:(NSInteger)number;

@end

@interface MainFirstTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *oneView;
@property (weak, nonatomic) IBOutlet UIView *twoView;
@property (weak, nonatomic) IBOutlet UIView *threeView;
@property (weak, nonatomic) IBOutlet UIImageView *oneImageView;
@property (weak, nonatomic) IBOutlet UILabel *oneLabel;
@property (weak, nonatomic) IBOutlet UIImageView *twoImageView;
@property (weak, nonatomic) IBOutlet UILabel *twoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *threeImageView;
@property (weak, nonatomic) IBOutlet UILabel *threeLabel;

@property (nonatomic,strong)id<MainFirstTableViewCell> delegate;

@end

//
//  MainFirstTableViewCell.m
//  e-Healthy
//
//  Created by FangLin on 16/11/4.
//  Copyright © 2016年 FangLin. All rights reserved.
//

#import "MainFirstTableViewCell.h"

@implementation MainFirstTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    //添加view的点击事件
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapOneClick)];
    self.oneView.userInteractionEnabled = YES;
    [self.oneView addGestureRecognizer:tap1];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapTwoClick)];
    self.twoView.userInteractionEnabled = YES;
    [self.twoView addGestureRecognizer:tap2];
    
    UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapThreeClick)];
    self.threeView.userInteractionEnabled = YES;
    [self.threeView addGestureRecognizer:tap3];
}

-(void)viewTapOneClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(firstTapClick:)]) {
        [self.delegate firstTapClick:1];
    }
}

-(void)viewTapTwoClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(firstTapClick:)]) {
        [self.delegate firstTapClick:2];
    }
}

-(void)viewTapThreeClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(firstTapClick:)]) {
        [self.delegate firstTapClick:3];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end

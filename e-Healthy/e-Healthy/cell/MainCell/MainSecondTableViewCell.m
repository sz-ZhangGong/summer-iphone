//
//  MainSecondTableViewCell.m
//  e-Healthy
//
//  Created by FangLin on 16/11/4.
//  Copyright © 2016年 FangLin. All rights reserved.
//

#import "MainSecondTableViewCell.h"

@implementation MainSecondTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapOneClick)];
    self.oneView.userInteractionEnabled = YES;
    [self.oneView addGestureRecognizer:tap1];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapTwoClick)];
    self.twoView.userInteractionEnabled = YES;
    [self.twoView addGestureRecognizer:tap2];
}

-(void)viewTapOneClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(tapClick:)]) {
        [self.delegate tapClick:1];
    }
}

-(void)viewTapTwoClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(tapClick:)]) {
        [self.delegate tapClick:2];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

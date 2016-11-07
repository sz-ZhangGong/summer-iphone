//
//  UIView+WidthAndCut.m
//  e-Healthy
//
//  Created by FangLin on 16/11/4.
//  Copyright © 2016年 FangLin. All rights reserved.
//

#import "UIView+WidthAndCut.h"

@implementation UIView (WidthAndCut)

-(void)addwidthWithCut:(NSInteger)cornerRadius
{
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = YES;
}

-(void)addwidthWithCorner:(NSInteger)cornerRadius withborderWidth:(NSInteger)borderWidth withborderColor:(UIColor *)color
{
    self.layer.cornerRadius = cornerRadius;
    self.layer.borderWidth = borderWidth;
    self.layer.borderColor = color.CGColor;
    self.layer.masksToBounds = YES;
}

@end

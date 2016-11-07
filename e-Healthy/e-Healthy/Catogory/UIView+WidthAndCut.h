//
//  UIView+WidthAndCut.h
//  e-Healthy
//
//  Created by FangLin on 16/11/4.
//  Copyright © 2016年 FangLin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (WidthAndCut)

-(void)addwidthWithCut:(NSInteger)cornerRadius;

-(void)addwidthWithCorner:(NSInteger)cornerRadius withborderWidth:(NSInteger)borderWidth withborderColor:(UIColor *)color;

@end

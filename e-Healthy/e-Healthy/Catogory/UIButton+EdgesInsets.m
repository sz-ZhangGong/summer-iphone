//
//  UIButton+EdgesInsets.m
//  e-Healthy
//
//  Created by FangLin on 16/11/4.
//  Copyright © 2016年 FangLin. All rights reserved.
//

#import "UIButton+EdgesInsets.h"

@implementation UIButton (EdgesInsets)

-(void)imageWithTitleEdges
{
    self.titleEdgeInsets = UIEdgeInsetsMake(self.frame.size.height/2-10, 0, 0, self.frame.size.width/2-40);
    self.imageEdgeInsets = UIEdgeInsetsMake(0, self.frame.size.width/2-20, self.frame.size.height/2-10, 0);
}

@end

//
//  DisplayUtils.m
//  e-healthy
//
//  Created by FangLin on 16/11/11.
//  Copyright © 2016年 FangLin. All rights reserved.
//

#import "DisplayUtils.h"

@implementation DisplayUtils

//获取手机的UDID
+(NSString*)uuid {
    CFUUIDRef puuid = CFUUIDCreate( nil );
    CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
    NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
    CFRelease(puuid);
    CFRelease(uuidString);
    return result;
}

//画圆的方法（使用带颜色的背景作为图片）
+(UIImage*)createImageWithColor:(UIColor*) color andX:(NSInteger)x andY:(NSInteger)y
{
    //CGRect rect=CGRectMake(0.0f, 0.0f, 10.0f, 10.0f);
    UIGraphicsBeginImageContext(CGSizeMake(x, y));
    CGContextRef context = UIGraphicsGetCurrentContext();
    // CGContextMoveToPoint(context, 0, 0);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    
    CGContextAddArc(context, x/2, y/2, x/2, 0, M_PI*2, 0);
    CGContextFillPath(context);
    //CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}


@end

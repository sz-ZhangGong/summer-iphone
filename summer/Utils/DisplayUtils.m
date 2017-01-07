//
//  DisplayUtils.m
//  summer
//
//  Created by FangLin on 16/11/11.
//  Copyright © 2016年 FangLin. All rights reserved.
//

#import "DisplayUtils.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation DisplayUtils

//md5 encode
+(NSString *) md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (unsigned int)strlen(cStr), digest );
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02X", digest[i]];
    
    return output;
}

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

//拨打电话
+(void)dialphoneNumber:(NSString *)number
{
    NSString *allString = [NSString stringWithFormat:@"tel:%@",number];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:allString]];
}


@end

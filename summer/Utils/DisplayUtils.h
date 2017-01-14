//
//  DisplayUtils.h
//  summer
//
//  Created by FangLin on 16/11/11.
//  Copyright © 2016年 FangLin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DisplayUtils : NSObject

+(NSString *) md5:(NSString *)str;

+(NSString *)uuid;

+(UIImage*)createImageWithColor:(UIColor*) color andX:(NSInteger)x andY:(NSInteger)y;

+(void)dialphoneNumber:(NSString *)number;

+(CGSize)getImageSizeWithURL:(id)imageURL;

@end

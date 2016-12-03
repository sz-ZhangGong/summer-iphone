//
//  DisplayUtils.h
//  e-healthy
//
//  Created by FangLin on 16/11/11.
//  Copyright © 2016年 FangLin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DisplayUtils : NSObject

+(NSString *)uuid;

+(UIImage*)createImageWithColor:(UIColor*) color andX:(NSInteger)x andY:(NSInteger)y;

@end

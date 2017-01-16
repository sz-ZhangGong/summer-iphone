//
//  DisplayUtils.h
//  summer
//
//  Created by FangLin on 16/11/11.
//  Copyright © 2016年 FangLin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^confirmBlock)(void);

typedef void(^cancelBlock)(void);

@interface DisplayUtils : NSObject

@property (nonatomic,strong)confirmBlock confirmBlock;
@property (nonatomic,strong)cancelBlock cancelBlock;

+(NSString *) md5:(NSString *)str;

+(NSString *)uuid;

+(UIImage*)createImageWithColor:(UIColor*) color andX:(NSInteger)x andY:(NSInteger)y;

+(void)dialphoneNumber:(NSString *)number;

+(void)alertControllerDisplay:(NSString *)str withUIViewController:(UIViewController *)viewController withConfirmBlock:(confirmBlock)confirmBlock withCancelBlock:(cancelBlock)cancelBlock;

@end

//
//  AFNetworkManager.m
//  HuangJia
//
//  Created by cts on 16/5/31.
//  Copyright © 2016年 cts. All rights reserved.
//

#import "AFNetworkManager.h"


@implementation AFNetworkManager
+(void)POST:(NSString *)url parameters:(id)param success:(AFSucBlock)successBlock failure:(AFErrBlock)errorBlock
{
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 10.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
   [manager POST:url parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
       NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
       if ([dataDic[@"status"][@"succeed"] integerValue]==1) {
           if (dataDic[@"error_desc"]!=nil) {
              // [MBProgressHUD showError:dataDic[@"error_desc"]];
           }
           
       }
       successBlock(task,dataDic);
       
   } failure:^(NSURLSessionDataTask *task, NSError *error) {
       errorBlock(task,error);
   }];
    
}
+(void)POST:(NSString *)url parameters:(id)param formData:(AFFormDataBlock)dataBlock success:(AFSucBlock1)successBlock failure:(AFErrBlock1)errorBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 10.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    [manager POST:url parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        dataBlock(formData);
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if ([dataDic[@"error"] integerValue]!=0) {
            if (dataDic[@"error_desc"]!=nil) {
                //[MBProgressHUD showError:dataDic[@"error_desc"]];
            }
            
        }
        //[MBProgressHUD hideAllHUD];
        successBlock(operation,dataDic);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //[MBProgressHUD hideAllHUD];
        errorBlock(operation,error);
        
    }];
}

+(void)GET:(NSString *)url parameters:(id)param success:(AFSucBlock1)successBlock failure:(AFErrBlock1)errorBlock{
    
    //[MBProgressHUD showInView:nil message:@"处理中..."];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 10.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    [manager GET:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //[MBProgressHUD hideAllHUD];
        // NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        //[MBProgressHUD hideAllHUD];
        successBlock(operation,dataDic);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //[MBProgressHUD hideAllHUD];
        errorBlock(operation,error);
        
    }];
    
}
@end

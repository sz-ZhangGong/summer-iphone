//
//  AppDelegate.m
//  summer
//
//  Created by FangLin on 16/11/10.
//  Copyright © 2016年 FangLin. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "BaseNavViewController.h"
#import "AFNetworking.h"
#import "JPUSHService.h"
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
#import <AdSupport/AdSupport.h>
#import "UserDefaultsUtils.h"
#import "LaunchIntroductionView.h"
#import "AFNetworkManager.h"
#import "DisplayUtils.h"
#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"
#import "MessageViewController.h"
#import "WXApi.h"
#import "TYDownLoadDataManager.h"
#import "TYDownLoadUtility.h"
#import <UMSocialCore/UMSocialCore.h>

#define URLPATH_IMAGE [NSString stringWithFormat:@"%@/MobileConfig?device=iphone&deviceId=%@",URL_APP_ROOT,[DisplayUtils uuid]]

static NSString *const kAppVersion = @"appVersion";

@interface AppDelegate ()<WXApiDelegate,JPUSHRegisterDelegate,SDWebImageManagerDelegate,TYDownloadDelegate>

@property (nonatomic,assign)NSInteger addCount;
@property (nonatomic,assign)NSInteger welcomeCount;

@property (nonatomic,strong)NSMutableArray *addArr;
@property (nonatomic,strong)NSMutableArray *welcomeArr;

@property (nonatomic,strong) TYDownloadModel *downloadModel;

@end

@implementation AppDelegate

-(NSMutableArray *)addArr
{
    if (!_addArr) {
        _addArr = [[NSMutableArray alloc] init];
    }
    return _addArr;
}

-(NSMutableArray *)welcomeArr
{
    if (!_welcomeArr) {
        _welcomeArr = [[NSMutableArray alloc] init];
    }
    return _welcomeArr;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //清除角标
    application.applicationIconBadgeNumber = 0;
    [JPUSHService resetBadge];
    
    [TYDownLoadDataManager manager].delegate = self;
    
    [self getImageData];
    
    //沉睡1秒
    [NSThread sleepForTimeInterval:1.0f];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    MainViewController *mainVC = [[MainViewController alloc] init];
    BaseNavViewController *mainNav = [[BaseNavViewController alloc] initWithRootViewController:mainVC];
    self.window.rootViewController = mainNav;
    [self.window makeKeyAndVisible];
    
    /*
     * #pragma 欢迎页
     */
    for (NSInteger i = 0; i<[[UserDefaultsUtils valueWithKey:@"addCount"] integerValue]; i++) {
        SDWebImageManager *manager = [[SDWebImageManager alloc] init];
        UIImage *image1 = [manager.imageCache imageFromDiskCacheForKey:[NSString stringWithFormat:@"adImage%ld",i]];
        NSLog(@"image1=%@",image1);
        if (image1) {
            [self.addArr addObject:image1];
        }
    }
    if ([self isFirstLauch]) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i<WELCOME_IMAGES_COUNT; i++) {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"欢迎页%ld.jpg",i+1]];
            [array addObject:image];
        }
        [LaunchIntroductionView sharedWithImages:array buttonImage:@"login" buttonFrame:CGRectMake(screen_width-screen_width/4, 20, screen_width/4-10, 20) withisBanner:NO];
    }else{
        if (!self.addArr.count) {
            //状态栏颜色
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
            [UIApplication sharedApplication].statusBarHidden = NO;
        }else{
            [LaunchIntroductionView sharedWithImages:self.addArr buttonImage:@"login" buttonFrame:CGRectMake(screen_width-screen_width/4, 20, screen_width/4-10, 20) withisBanner:YES];
        }
    }
    
    //接收通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarHiddenNotfi:) name:ShowBanner object:nil];
    
    //判断网络
    [self monitorNetworkState];
    
    [UserDefaultsUtils saveValue:@"1.0" forKey:@"scale"];
    
    //推送通知
    [self registerPushNotfication:launchOptions];
    
    return YES;
}

-(void)statusBarHiddenNotfi:(NSNotification *)notfi
{
    //状态栏颜色
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [UIApplication sharedApplication].statusBarHidden = NO;
}

//判断是否是第一次
-(BOOL )isFirstLauch{
    //获取当前版本号
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *currentAppVersion = infoDic[@"CFBundleShortVersionString"];
    //获取上次启动应用保存的appVersion
    NSString *version = [[NSUserDefaults standardUserDefaults] objectForKey:kAppVersion];
    //版本升级或首次登录
    if (version == nil || ![version isEqualToString:currentAppVersion]) {
        [[NSUserDefaults standardUserDefaults] setObject:currentAppVersion forKey:kAppVersion];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    }else{
        return NO;
    }
}

//启动页
-(void)setStartImageView
{
    UIViewController *viewController = [[UIStoryboard storyboardWithName:@"LaunchScreen" bundle:nil] instantiateViewControllerWithIdentifier:@"LaunchScreen"];
    
    
    UIView *launchView = viewController.view;
    UIWindow *mainWindow = [UIApplication sharedApplication].keyWindow;
    launchView.frame = [UIApplication sharedApplication].keyWindow.frame;
    
    UIImageView *startImageView = [[UIImageView alloc] initWithFrame:launchView.frame];
    startImageView.image = [UIImage imageNamed:@"startImage.jpg"];
    [launchView addSubview:startImageView];
    [mainWindow addSubview:launchView];
    
    [UIView animateWithDuration:2.0f delay:0.5f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        launchView.alpha = 0.0f;
        launchView.layer.transform = CATransform3DScale(CATransform3DIdentity, 1.5f, 1.5f, 1.0f);
    } completion:^(BOOL finished) {
        [launchView removeFromSuperview];
    }];
}

//获取启动页，欢迎页等数据
-(void)getImageData
{
    [AFNetworkManager GET:URLPATH_IMAGE parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        if (responseObject) {
            NSLog(@"responseObject = %@",responseObject);
            [UserDefaultsUtils saveValue:responseObject[@"rootSite"] forKey:@"rootSite"];
            [UserDefaultsUtils saveValue:responseObject[@"msgManage"] forKey:@"msgManage"];
            [UserDefaultsUtils saveValue:responseObject[@"ChangeStr"] forKey:@"ChangeStr"];
            [UserDefaultsUtils saveValue:responseObject[@"MainUrlStr"] forKey:@"MainUrlStr"];
            [UserDefaultsUtils saveValue:responseObject[@"OutLogin"] forKey:@"OutLogin"];
            [self uploadAddImage:responseObject[@"adImages"]];
            //            [self downLoad:responseObject[@"cacheFiles"]];
            NSLog(@"%@",NSHomeDirectory());
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error = %@",error);
    }];
}

#pragma mark - 下载文件
-(void)downLoad:(NSArray *)array
{
    for (NSInteger i = 0; i<array.count; i++) {
        //        NSRange range = [array[i] rangeOfString:@"/" options:NSBackwardsSearch];
        //        NSString *str = [array[i] substringFromIndex:range.location+1];
        //        NSString *savedPath = [NSHomeDirectory() stringByAppendingString:[NSString stringWithFormat:@"/Documents/%@",str]];
        // manager里面是否有这个model是正在下载
        _downloadModel = [[TYDownLoadDataManager manager] downLoadingModelForURLString:[NSString stringWithFormat:@"%@/%@",[UserDefaultsUtils valueWithKey:@"rootSite"],array[i]]];
        if (_downloadModel) {
            [self startDownlaod];
            return;
        }
        
        // 没有正在下载的model 重新创建
        TYDownloadModel *model = [[TYDownloadModel alloc]initWithURLString:[NSString stringWithFormat:@"%@/%@",[UserDefaultsUtils valueWithKey:@"rootSite"],array[i]]];
        _downloadModel = model;
        [self startDownlaod];
    }
}
#pragma mark - 1
- (void)downloadModel:(TYDownloadModel *)downloadModel didUpdateProgress:(TYDownloadProgress *)progress
{
    NSLog(@"delegate progress %.3f",progress.progress);
}

- (void)downloadModel:(TYDownloadModel *)downloadModel didChangeState:(TYDownloadState)state filePath:(NSString *)filePath error:(NSError *)error
{
    NSLog(@"delegate state %ld error%@ filePath%@",state,error,filePath);
}

- (void)startDownlaod
{
    TYDownLoadDataManager *manager = [TYDownLoadDataManager manager];
    [manager startWithDownloadModel:_downloadModel progress:^(TYDownloadProgress *progress) {
        
    } state:^(TYDownloadState state, NSString *filePath, NSError *error) {
        if (state == TYDownloadStateCompleted) {
            
        }
    }];
}

#pragma mark - 下载图片
-(void)uploadAddImage:(NSArray *)imageArr
{
    [UserDefaultsUtils saveValue:@(imageArr.count) forKey:@"addCount"];
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager.imageCache removeImageForKey:@"adImage" fromDisk:YES];
    for (NSInteger i = 0; i < imageArr.count; i++) {
        
        NSString *imageUrl = imageArr[i];
        // 缓存图片
        manager.delegate = self;
        [manager.imageDownloader downloadImageWithURL:[NSURL URLWithString:imageUrl] options:SDWebImageDownloaderContinueInBackground progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            NSLog(@"---save image is %@",image);
            [manager.imageCache storeImage:image forKey:[NSString stringWithFormat:@"adImage%ld",i] toDisk:YES];
        }];
    }
}

#pragma mark - 判断网络
- (void)monitorNetworkState{
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager startMonitoring];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"没有网络");
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:KLoadDataBase object:nil userInfo:@{@"netType":@"NotReachable"}]];
                break;
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"未知");
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:KLoadDataBase object:nil userInfo:@{@"netType":@"Unknown"}]];
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"WiFi");
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:KLoadDataBase object:nil userInfo:@{@"netType":@"WiFi"}]];
                
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"3G|4G");
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:KLoadDataBase object:nil userInfo:@{@"netType":@"WWAN"}]];
                break;
            default:
                break;
        }
    }];
    
}

-(void)registerPushNotfication:(NSDictionary *)launchOptions
{
    //推送
    //Required
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
        entity.types = UNAuthorizationOptionAlert|UNAuthorizationOptionBadge|UNAuthorizationOptionSound;
        [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    }
    else if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                          UIUserNotificationTypeSound |
                                                          UIUserNotificationTypeAlert)
                                              categories:nil];
    }
    else {
        //categories 必须为nil
        [JPUSHService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                          UIRemoteNotificationTypeSound |
                                                          UIRemoteNotificationTypeAlert)
                                              categories:nil];
    }
    // Optional
    // 获取IDFA
    // 如需使用IDFA功能请添加此代码并在初始化方法的advertisingIdentifier参数中填写对应值
    NSString *advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    
    // Required
    // init Push
    // notice: 2.1.5版本的SDK新增的注册方法，改成可上报IDFA，如果没有使用IDFA直接传nil
    // 如需继续使用pushConfig.plist文件声明appKey等配置内容，请依旧使用[JPUSHService setupWithOption:launchOptions]方式初始化。
    [JPUSHService setupWithOption:launchOptions appKey:appKey
                          channel:nil
                 apsForProduction:isProduction
            advertisingIdentifier:advertisingId];
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Required - 注册 DeviceToken
    [JPUSHService registerDeviceToken:deviceToken];
}

#pragma mark - JPUSHRegisterDelegate
// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    NSLog(@"userInfo = %@",userInfo);
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler(UNNotificationPresentationOptionBadge);  // 系统要求执行这个方法
    //消息点击
    NSString *url = [NSString stringWithFormat:@"%@/%@.show?device=iphone&deviceid=%@&msgId=%ld",[UserDefaultsUtils valueWithKey:@"rootSite"],[UserDefaultsUtils valueWithKey:@"msgManage"],[DisplayUtils uuid],[userInfo[@"_j_msgid"] integerValue]];
    NSLog(@"url = %@",url);
    [self goToMssageViewControllerWith:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // Required, iOS 7 Support
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Required,For systems with less than or equal to iOS6
    [JPUSHService handleRemoteNotification:userInfo];
    NSDictionary *aps = [userInfo valueForKey:@"aps"];
    NSString *content = [aps valueForKey:@"alert"]; //推送显示的内容
    NSInteger badge = [[aps valueForKey:@"badge"] integerValue];
    NSString *sound = [aps valueForKey:@"sound"]; //播放的声音
    // 取得自定义字段内容，userInfo就是后台返回的JSON数据，是一个字典
    application.applicationIconBadgeNumber = 0;
    [JPUSHService resetBadge];
    
    [self goToMssageViewControllerWith:userInfo];
    
}

- (void)goToMssageViewControllerWith:(NSDictionary*)msgDic{
    //将字段存入本地，因为要在你要跳转的页面用它来判断,这里我只介绍跳转一个页面，
    [UserDefaultsUtils saveValue:@"push" forKey:@"push"];
    NSString * targetStr = [msgDic objectForKey:@"target"];
    if ([targetStr isEqualToString:@"notice"]) {
        MessageViewController *messageVC = [[MessageViewController alloc] init];
        UINavigationController * Nav = [[UINavigationController alloc]initWithRootViewController:messageVC];//这里加导航栏是因为我跳转的页面带导航栏，如果跳转的页面不带导航，那这句话请省去。
        [self.window.rootViewController presentViewController:Nav animated:YES completion:nil];
    }
}


#pragma mark - 支付方法
-(void)onResp:(BaseResp*)resp{
    if ([resp isKindOfClass:[PayResp class]]){
        PayResp *response=(PayResp *)resp;
        switch(response.errCode){
            case WXSuccess:
                //服务器端查询支付通知或查询API返回的结果再提示成功
                NSLog(@"支付成功");
                [[NSNotificationCenter defaultCenter] postNotificationName:PAY_SUCCEED object:nil userInfo:nil];
                break;
            default:
                NSLog(@"支付失败，retcode=%d",resp.errCode);
                break;
        }
    }
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    if (!result) {
        // 其他如支付等SDK的回调
        if ([url.host isEqualToString:@"safepay"]) {
            // 支付跳转支付宝钱包进行支付，处理支付结果
            
            return YES;
        }
        else
            return  [WXApi handleOpenURL:url delegate:self];
    }
    else
    {
        
        if ([url.host isEqualToString:@"pay"])
        {
            return [WXApi handleOpenURL:url delegate:self];
        }
        else
            return result;
    }
    
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    if (!result) {
        // 其他如支付等SDK的回调
        if ([url.host isEqualToString:@"safepay"]) {
            // 支付跳转支付宝钱包进行支付，处理支付结果
            
            return YES;
        }
        else
            return [WXApi handleOpenURL:url delegate:self];
    }
    else
    {
        
        if ([url.host isEqualToString:@"pay"])
        {
            return [WXApi handleOpenURL:url delegate:self];
        }
        else
            return result;
    }
}
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    if (!result) {
        // 其他如支付等SDK的回调
        if ([url.host isEqualToString:@"safepay"]) {
            // 支付跳转支付宝钱包进行支付，处理支付结果
            
            return YES;
        }
        else
            return [WXApi handleOpenURL:url delegate:self];
        
    }
    else
    {
        
        if ([url.host isEqualToString:@"pay"])
        {
            return [WXApi handleOpenURL:url delegate:self];
        }
        else
            return result;
    }
    
}

-(void)onReq:(BaseReq*)req
{
    NSLog(@"onReq");
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    application.applicationIconBadgeNumber = 0;
    [JPUSHService resetBadge];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end

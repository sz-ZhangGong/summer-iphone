//
//  AppDelegate.m
//  e-healthy
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

#define URLPATH_IMAGE [NSString stringWithFormat:@"http://ehealth.lucland.com/MobileConfig?device=phone&deviceId=%@",[DisplayUtils uuid]]

static NSString *const kAppVersion = @"appVersion";

@interface AppDelegate ()<JPUSHRegisterDelegate,SDWebImageManagerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //清除角标
    application.applicationIconBadgeNumber = 0;
    [JPUSHService resetBadge];
    
    //沉睡2秒
    [NSThread sleepForTimeInterval:1.0f];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    MainViewController *mainVC = [[MainViewController alloc] init];
    BaseNavViewController *mainNav = [[BaseNavViewController alloc] initWithRootViewController:mainVC];
    self.window.rootViewController = mainNav;
    [self.window makeKeyAndVisible];
    
    //启动页
//    [self setStartImageView];
    //判断网络
    [self monitorNetworkState];
    
    [self getImageData];
    /*
     * #pragma 欢迎页
     */
    if ([self isFirstLauch]) {
        [LaunchIntroductionView sharedWithImages:@[@"引导页1.jpg",@"引导页2.jpg",@"引导页3.jpg",@"引导页4.jpg"] buttonImage:@"login" buttonFrame:CGRectMake(screen_width-screen_width/4, 20, screen_width/4-10, 20) withisBanner:NO];
    }else{
        [LaunchIntroductionView sharedWithImages:@[@"Initpage"] buttonImage:@"login" buttonFrame:CGRectMake(screen_width-screen_width/4, 20, screen_width/4-10, 20) withisBanner:YES];
    }
    
    //接收通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarHiddenNotfi:) name:ShowBanner object:nil];
    
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
    startImageView.image = [UIImage imageNamed:@"启动页"];
    [launchView addSubview:startImageView];
    [mainWindow addSubview:launchView];
    
    [UIView animateWithDuration:2.0f delay:2.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
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
            [self uploadImage:responseObject[@"welcomeImages"] withtype:1];
            [self uploadImage:responseObject[@"adImages"] withtype:2];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error = %@",error);
    }];
}

//下载图片 type:0启动页 1欢迎页 2广告页
-(void)uploadImage:(NSArray *)imageArr withtype:(NSInteger)type;
{
    for (NSInteger i = 0; i < imageArr.count; i++) {
        NSString *imageUrl = imageArr[i];
        // 缓存图片
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        manager.delegate = self;
        [manager.imageDownloader downloadImageWithURL:[NSURL URLWithString:imageUrl] options:SDWebImageDownloaderContinueInBackground progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            NSLog(@"---save image is %@",image);
            if (type == 0) {
                
            }else if (type == 1){
                [manager.imageCache storeImage:image forKey:[NSString stringWithFormat:@"welcomeImage%ld",i] toDisk:YES];
            }else if (type == 2){
                [manager.imageCache storeImage:image forKey:[NSString stringWithFormat:@"adImage%ld",i] toDisk:YES];
            }
        }];
    }
    
    // 从缓存取图片并显示
    //SDWebImageManager *manager = [[SDWebImageManager alloc] init];
    //UIImage *image = [manager.imageCache imageFromMemoryCacheForKey:@"one"];
}

//判断网络
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
    /// Required - 注册 DeviceToken
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
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler(UNNotificationPresentationOptionBadge);  // 系统要求执行这个方法
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // Required, iOS 7 Support
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Required,For systems with less than or equal to iOS6
    [JPUSHService handleRemoteNotification:userInfo];
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

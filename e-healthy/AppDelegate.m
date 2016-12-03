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

@interface AppDelegate ()<JPUSHRegisterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //沉睡2秒
    [NSThread sleepForTimeInterval:1.0f];
    
    //状态栏颜色
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    MainViewController *mainVC = [[MainViewController alloc] init];
    BaseNavViewController *mainNav = [[BaseNavViewController alloc] initWithRootViewController:mainVC];
    self.window.rootViewController = mainNav;
    [self.window makeKeyAndVisible];
    
    //接收通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ShowBannerNotification:) name:ShowBanner object:nil];
    
    //启动页
//    [self setStartImageView];
    //判断网络
    [self monitorNetworkState];
    
    [self getImageData];
    /*
     * #pragma 欢迎页
     */
    [LaunchIntroductionView sharedWithImages:@[@"引导页1.jpg",@"引导页2.jpg",@"引导页3.jpg",@"引导页4.jpg"] buttonImage:@"login" buttonFrame:CGRectMake(screen_width/2 - 551/4, screen_height - 150, 551/2, 45) withisBanner:NO];
    
    [UserDefaultsUtils saveValue:@"1.0" forKey:@"scale"];
    
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

    
    return YES;
}

-(void)ShowBannerNotification:(NSNotification *)notfi
{
    [LaunchIntroductionView sharedWithImages:@[@"Initpage"] buttonImage:@"login" buttonFrame:CGRectMake(screen_width/2 - 551/4, screen_height - 150, 551/2, 45) withisBanner:YES];
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
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error = %@",error);
    }];
}

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
    completionHandler();  // 系统要求执行这个方法
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
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end

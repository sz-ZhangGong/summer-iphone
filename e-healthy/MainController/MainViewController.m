//
//  MainViewController.m
//  e-healthy
//
//  Created by FangLin on 16/11/10.
//  Copyright © 2016年 FangLin. All rights reserved.
//

#import "MainViewController.h"
#import <WebKit/WebKit.h>
#import "CustemNavItem.h"
#import "MenuView.h"
#import "WebViewJavascriptBridge.h"
#import "WKWebViewJavascriptBridge.h"
#import "WebViewJavascriptBridgeBase.h"
#import "NJKWebViewProgressView.h"
#import "NJKWebViewProgress.h"
#import "DisplayUtils.h"
#import "SettingViewController.h"
#import "UserDefaultsUtils.h"
#import "MJRefresh.h"
#import "YMWebCacheProtocol.h"
#import "MessageViewController.h"
#import "WXApi.h"

static NSString * const APIBaseURLString = @"";

static NSString *const changeStr = @"http://ehealth.lucland.com/forms/Login?device=iphone,http://ehealth.lucland.com/forms/FrmPhoneRegistered,http://ehealth.lucland.com/forms/VerificationLogin,http://ehealth.lucland.com/forms/Login,http://ehealth.lucland.com/forms/FrmLossPassword";

static NSString *const exitUrlStr = @"http://ehealth.lucland.com/forms/Login?device=iphone,http://ehealth.lucland.com/forms/FrmPhoneRegistered,http://ehealth.lucland.com/forms/VerificationLogin,http://ehealth.lucland.com/forms/Login,http://ehealth.lucland.com/forms/FrmIndex";

static NSString *const tabbarUrlStr = @"http://ehealth.lucland.com/forms/FrmMessages,http://ehealth.lucland.com/forms/FrmCardPage";

//http://ehealth.lucland.com/forms/Login?device=phone,
static NSString *const mainUrlStr = @"http://ehealth.lucland.com/forms/FrmIndex";

//192.168.1.111:8080
//192.168.1.152
//http://ehealth.lucland.com
//static NSString *const URL = @"http://ehealth.lucland.com/forms/Login?device=phone";//登录
static NSString *const URL = @"http://ehealth.lucland.com";//首页

#define ALL_URLPATH [NSString stringWithFormat:@"%@?device=iphone&deviceid=%@",URL,[DisplayUtils uuid]]

@interface MainViewController ()<WKNavigationDelegate,WKUIDelegate,UIScrollViewDelegate,WKScriptMessageHandler,CustemBBI,SettingViewController>

@property (nonatomic,strong)WKWebView *webView;

@property (nonatomic,assign)BOOL flag;

@property (nonatomic,strong)UIImageView *errorImageView;//出错视图

@property (nonatomic,strong) NJKWebViewProgressView *progressView;

@property (nonatomic,strong) NJKWebViewProgress *progressProxy;

@property (nonatomic,strong) WebViewJavascriptBridge *uiBridge;

@property (nonatomic,strong) WKWebViewJavascriptBridge *wkBridge;

@property (nonatomic,strong) WVJBHandler handler;

@property (nonatomic,assign)BOOL isMain;//是否是首页

@property (nonatomic,copy)NSString *urlPath;//接收每次加载网页的url

@end

@implementation MainViewController

#pragma mark - 懒加载
- (NJKWebViewProgressView*)progressView
{
    if (!_progressView) {
        NJKWebViewProgressView *progressView=[[NJKWebViewProgressView alloc] init];
        CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
        progressView.frame = CGRectMake(0, 64, navigationBarBounds.size.width, progressBarHeight);
        _progressView = progressView;
    }
    return _progressView;
}

- (NJKWebViewProgress*)progressProxy
{
    if (!_progressProxy) {
        NJKWebViewProgress *progressProxy=[[NJKWebViewProgress alloc] init];
        _progressProxy = progressProxy;
    }
    return _progressProxy;
}
- (WKWebViewJavascriptBridge *)wkBridge
{
    if (!_wkBridge) {
        [WKWebViewJavascriptBridge enableLogging];
        WKWebViewJavascriptBridge *wkBridge=[WKWebViewJavascriptBridge bridgeForWebView:self.webView];
        [wkBridge setWebViewDelegate:self];
        _wkBridge = wkBridge;
    }
    return _wkBridge;
}

-(WKWebView *)webView
{
    if (!_webView) {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        [config.userContentController addScriptMessageHandler:self name:@"webViewApp"];
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 64, screen_width, screen_height-64) configuration:config];
        [_webView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
        _webView.scrollView.delegate = self;
//        [_webView setAllowsBackForwardNavigationGestures:YES];
        [_webView addObserver:self forKeyPath:ObserveKeyPath options:NSKeyValueObservingOptionNew context:nil];
        //加载
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:ALL_URLPATH]]];
    }
    return _webView;
}

-(UIImageView *)errorImageView //错误视图
{
    if (!_errorImageView) {
        _errorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screen_width, screen_height-64)];
        _errorImageView.image = [UIImage imageNamed:@"error.jpg"];
        _errorImageView.hidden = YES;
    }
    return _errorImageView;
}

#pragma mark - 监听mk progress
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:ObserveKeyPath]) {
        [_progressView setProgress:self.webView.estimatedProgress animated:YES];
        self.progressView.hidden = self.webView.estimatedProgress == 1.0;
    }
}

#pragma mark - 视图生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    //出错页面
    [self.webView addSubview:self.errorImageView];
    _isMain = YES;
    
    //右边按钮下拉菜单
    [self settingMenu];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [YMWebCacheProtocol start];
    //网络监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getLoadDataBase:) name:KLoadDataBase object:nil];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.barTintColor = RGBColor(0, 0, 0, 1.0);

    [self.view addSubview:self.webView];
    [self addProgressView];
}

-(void)getLoadDataBase:(NSNotification *)text
{
    NSDictionary *dict = text.userInfo;
    if ([dict[@"netType"] isEqualToString:@"NotReachable"] || [dict[@"netType"] isEqualToString:@"Unknown"]) {
        [self setNavTitle:@"出错了"];
        self.errorImageView.hidden = NO;
    }
    /*
     * #pragma 重新加载页面
     * reloadFromOrigin: //该方法加载时会比较网络数据是否有变化，没有变化则使用缓存数据
     * reload: //直接加载
     */
    [self.webView reload];
}

#pragma mark - 下拉刷新
-(void)addRefreshView
{
    if (![changeStr containsString:self.webView.URL.absoluteString] && ![@"about:blank" isEqualToString:self.webView.URL.absoluteString]) {
        self.webView.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefresh)];
    }
}

-(void)headerRefresh
{
    [self.webView reload];
}

#pragma mark - 结束下拉刷新和上拉加载
- (void)endRefresh{
    //当请求数据成功或失败后，如果你导入的MJRefresh库是最新的库，就用下面的方法结束下拉刷新和上拉加载事件
    [self.webView.scrollView.mj_header endRefreshing];
}

#pragma mark - 添加progressView
- (void)addProgressView
{
    [self.view addSubview:self.progressView];
}
- (void)hideProgressView
{
    [self.progressView removeFromSuperview];
}

#pragma mark - 导航栏
-(void)BBIdidClickWithName:(NSString *)infoStr
{
    if ([infoStr isEqualToString:@"first"]) {
        if (_isMain == YES) {
            //退出app动画
//            UIApplication *app = (UIApplication *)[UIApplication sharedApplication].delegate;
//            UIWindow *window = app.keyWindow;
//            [UIView animateWithDuration:1.0f animations:^{
//                window.alpha = 0;
//                window.frame = CGRectMake(0, window.bounds.size.width, 0, 0);
//            } completion:^(BOOL finished) {
//                //exit(0);
//                abort();//退出
//            }];
        }else{
            if ([tabbarUrlStr containsString:_urlPath]) {
                [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:ALL_URLPATH]]];
            }else{
                if (self.webView.canGoBack) {
                    [self.webView goBack];
                }
            }
        }
    }else if ([infoStr isEqualToString:@"second"]){
        
    }else{
        if (self.flag) {
            [MenuView showMenuWithAnimation:self.flag];
            self.flag = NO;
        }else{
            [MenuView showMenuWithAnimation:self.flag];
            self.flag = YES;
        }
    }
}

#pragma mark - 创建下拉菜单
-(void)settingMenu
{
    /**
     *  rightBarButton的点击标记，每次点击更改flag值。
     *  如果您用普通的button就不需要设置flag，通过按钮的seleted属性来控制即可
     */
    self.flag = YES;

    /**
     *  这些数据是菜单显示的图片和文字：
     *
     */
    NSDictionary *dict1 = @{@"imageName" : @"iconfont-978weiduxinxi",
                            @"itemName" : @"未读消息"
                            };
//    NSDictionary *dict2 = @{@"imageName" : @"icon-suoyouxiaoxi",
//                            @"itemName" : @"所有消息"
//                            };
    NSDictionary *dict2 = @{@"imageName" : @"iconfont-xiaoxiguanli",
                            @"itemName" : @"消息管理"
                            };
    NSDictionary *dict3 = @{@"imageName" : @"iconfont-shezhi-3",
                            @"itemName" : @"设置"
                            };
    NSDictionary *dict4 = @{@"imageName" :@"iconfont-zhuye-2",
                            @"itemName" :@"返回首页"
                            };
    NSArray *dataArray = @[dict1,dict2,dict3,dict4];
    // 计算菜单frame
    CGFloat x = screen_width / 3 * 2-30;
    CGFloat y = 64;
    CGFloat width = screen_width * 0.3+30;
    CGFloat height = dataArray.count * 40;  // 40 -> tableView's RowHeight
    __weak __typeof(&*self)weakSelf = self;
    /**
     *  创建menu
     */
    [MenuView createMenuWithFrame:CGRectMake(x, y, width, height) target:self.navigationController dataArray:dataArray itemsClickBlock:^(NSString *str, NSInteger tag) {
        // do something
        [weakSelf doSomething:(NSString *)str tag:(NSInteger)tag];
        
    } backViewTap:^{
        // 点击背景遮罩view后的block，可自定义事件
        // 这里的目的是，让rightButton点击，可再次pop出menu
        weakSelf.flag = YES;
    }];
}

- (void)doSomething:(NSString *)str tag:(NSInteger)tag{
    NSString *msgUrl = [NSString stringWithFormat:@"%@/%@",[UserDefaultsUtils valueWithKey:@"rootSite"],[UserDefaultsUtils valueWithKey:@"msgManage"]];
    NSLog(@"点击了第%ld个菜单项",tag);
    if (tag == 1) {
        MessageViewController *messageVC = [[MessageViewController alloc] init];
        messageVC.url = [NSString stringWithFormat:@"%@.unread",msgUrl];
        [self.navigationController pushViewController:messageVC animated:YES];
    }else if (tag == 4){
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:ALL_URLPATH]]];
    }else if (tag == 3){
        SettingViewController *settingVC = [[SettingViewController alloc] init];
        settingVC.delegate = self;
        [self.navigationController pushViewController:settingVC animated:YES];
    }else if (tag == 2){
        MessageViewController *messageVC = [[MessageViewController alloc] init];
        messageVC.url = msgUrl;
        [self.navigationController pushViewController:messageVC animated:YES];
    }
    [MenuView hidden];  // 隐藏菜单
    self.flag = YES;
}

- (void)dealloc{
    [MenuView clearMenu];   // 移除菜单
    [[NSNotificationCenter defaultCenter] removeObserver:self];//移除通知
    [[self.webView configuration].userContentController removeScriptMessageHandlerForName:@"webViewApp"];
}

#pragma mark - UIWebViewDelegate代理方法
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    //加载完成结束刷新
    [self endRefresh];
    //设置下拉刷新
    [self addRefreshView];
    
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    NSHTTPCookie *cookie;
    for (id cook in cookies) {
        if ([cook isKindOfClass:[NSHTTPCookie class]]) {
            cookie = (NSHTTPCookie *)cook;
            NSLog(@"cookie ==== %@",cookie);
        }
    }
    self.errorImageView.hidden = YES;
    //获取每个页面的url
    NSLog(@"URL -- %@",webView.URL.absoluteString);
    _urlPath = webView.URL.absoluteString;
    //每次加载判断是否是首页
    if ([mainUrlStr containsString:webView.URL.absoluteString]) {
        self.navigationItem.leftBarButtonItem = nil;
        _isMain = YES;
    }else{
        self.navigationItem.leftBarButtonItem = [CustemNavItem initWithImage:[UIImage imageNamed:@"ic_nav_back"] andTarget:self andinfoStr:@"first"];
        _isMain = NO;
    }
    //设置标题
    [self setNavTitle:webView.title];

    //高度自适应
    if ([changeStr containsString:webView.URL.absoluteString]) {
        NSString *js_fit_code = [NSString stringWithFormat:@"var meta = document.createElement('meta');"
                                 "meta.name = 'viewport';"
                                 "meta.content = 'width=device-width, initial-scale=1.0,minimum-scale=0.1, maximum-scale=0.9, user-scalable=yes';"
                                 "document.getElementsByTagName('head')[0].appendChild(meta);"
                                 ];
        [webView evaluateJavaScript:js_fit_code completionHandler:^(id _Nullable item, NSError * _Nullable error) {
            
        }];
        self.navigationItem.rightBarButtonItem = nil;
    }else{
        //设置导航栏的按钮
        self.navigationItem.rightBarButtonItem = [CustemNavItem initWithImage:[UIImage imageNamed:@"ic_nav_classify"] andTarget:self andinfoStr:@"third"];
    }
}

-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"error = %@",error);
    //加载出错时，title
//    [self setNavTitle:@"出错了"];
//    self.errorImageView.hidden = NO;
//    [self.webView reload];
}

#pragma mark - WKScriptMessageHandler代理方法
-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    //向微信注册
    [WXApi registerApp:@"wx880d8fc48ac1e88e"];
    
    NSString *time_stamp, *nonce_str;
    //设置支付参数
    time_t now;
    time(&now);
    time_stamp  = [NSString stringWithFormat:@"%ld", now];
    nonce_str	= [DisplayUtils md5:time_stamp];
    
    PayReq *request   = [[PayReq alloc] init];
    request.nonceStr  = message.body[@"nonce_str"];
    request.package   = @"Sign=WXPay";
    request.partnerId = message.body[@"mch_id"];
    request.prepayId  = message.body[@"prepay_id"];
    request.timeStamp = [message.body[@"timestamp"] intValue];
    request.sign      = message.body[@"sign"];
    [WXApi sendReq:request];
}

#pragma mark --------wkwebview缩放的问题------------
-(void)perverseInfo:(float)scale
{
    NSString *js_fit_code = [NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.zoom= '%.2f'",scale
                             ];
    [self.webView evaluateJavaScript:js_fit_code completionHandler:^(id _Nullable item, NSError * _Nullable error) {
        
    }];
    
#if 0
    [self.webView evaluateJavaScript:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '50%'" completionHandler:^(id _Nullable item, NSError * _Nullable error) {
        
    }];
    
    [self.webView evaluateJavaScript:[NSString stringWithFormat:@"document.images.length"] completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        
        if (response != 0) {
            
            for (int i=0; i<[response intValue]; i++) {
                [self.webView evaluateJavaScript:[NSString stringWithFormat:@"document.images[%d].style.maxWidth='100%%'",i] completionHandler:^(id _Nullable response, NSError * _Nullable error) {
                    //                    NSLog(@"response1: %@ error: %@", response, error);
                }];
                [self.webView evaluateJavaScript:[NSString stringWithFormat:@"document.images[%d].style.height='100%%'",i] completionHandler:^(id _Nullable response, NSError * _Nullable error) {
                    //                    NSLog(@"response2: %@ error: %@", response, error);
                }];
            }
            
        }
        //        NSLog(@"response0: %@ error: %@", response, error);
    }];

    NSString *js_fit_code = [NSString stringWithFormat:@"var meta = document.createElement('meta');"
                "meta.name = 'viewport';"
                "meta.content = 'width=device-width,height=device-height, initial-scale=1.0,minimum-scale=0.1, maximum-scale=1.0, user-scalable=yes';"
                "document.getElementsByTagName('head')[0].appendChild(meta);"
                ];
    [self.webView evaluateJavaScript:js_fit_code completionHandler:^(id _Nullable item, NSError * _Nullable error) {
    
            }];
#endif
    
}

@end

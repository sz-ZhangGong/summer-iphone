//
//  MainViewController.m
//  summer
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
#import "MessageViewController.h"
#import "WXApi.h"
#import "lhScanQCodeViewController.h"
#import "ScanViewController.h"
#import "PingImageViewController.h"
#import "JPUSHService.h"


static NSString * const APIBaseURLString = @"";

static NSString *const changeStr = @"/forms/Default,/,/forms/Login?device=iphone,/forms/FrmPhoneRegistered,/forms/VerificationLogin,/forms/Login,/forms/FrmLossPassword";

static NSString *const mainUrlStr = @"/forms/FrmIndex,/forms/Login,/forms/VerificationLogin";

#define ALL_URLPATH [NSString stringWithFormat:@"%@?device=iphone&CLIENTID=%@",URL_APP_ROOT,[DisplayUtils uuid]]

#define OutLogin [NSString stringWithFormat:@"%@/forms/Login.exit",URL_APP_ROOT]

@interface MainViewController ()<WKNavigationDelegate,WKUIDelegate,UIScrollViewDelegate,WKScriptMessageHandler,CustemBBI,SettingViewController,lhScanQCodeViewController,ScanViewController>
{
    float _scale;
}
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
        _webView.scrollView.showsHorizontalScrollIndicator = NO;
        _webView.scrollView.showsVerticalScrollIndicator = NO;
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
    //webview
    [self.view addSubview:self.webView];
    //右边按钮下拉菜单
    [self settingMenu];
    //设置别名
    [JPUSHService setAlias:[DisplayUtils uuid] callbackSelector:nil object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //网络监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getLoadDataBase:) name:KLoadDataBase object:nil];
    //监听支付成功
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paySucceed:) name:PAY_SUCCEED object:nil];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.barTintColor = RGBColor(72, 178, 189, 1.0);

    [self addProgressView];
    
}
-(void)getLoadDataBase:(NSNotification *)text
{
    NSDictionary *dict = text.userInfo;
    if ([dict[@"netType"] isEqualToString:@"NotReachable"] || [dict[@"netType"] isEqualToString:@"Unknown"]) {
        
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
    NSString *isChangStr;
    if ([UserDefaultsUtils valueWithKey:@"ChangeStr"] == nil) {
        isChangStr = changeStr;
    }else{
        isChangStr = ChangeStr;
    }
    if (![isChangStr containsString:self.webView.URL.relativePath] && ![@"about:blank" isEqualToString:self.webView.URL.absoluteString]) {
        self.webView.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefresh)];
    }else{
        self.webView.scrollView.mj_header.hidden = YES;
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
        if (![self.webView.URL.absoluteString containsString:URL_APP_ROOT]) {
            if ([self.webView canGoBack]) {
                [self.webView goBack];
            }
        }else{
            [self.webView evaluateJavaScript:@"ReturnBtnClick()" completionHandler:^(id _Nullable item, NSError * _Nullable error) {
                
            }];
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
    NSDictionary *dict2 = @{@"imageName" : @"iconfont-xiaoxiguanli",
                            @"itemName" : @"消息管理"
                            };
    NSDictionary *dict3 = @{@"imageName" : @"iconfont-shezhi-3",
                            @"itemName" : @"设置"
                            };
    NSDictionary *dict4 = @{@"imageName" :@"iconfont-zhuye-2",
                            @"itemName" :@"返回首页"
                            };
    NSDictionary *dict5 = @{@"imageName" :@"退出",
                            @"itemName" :@"退出登录"
                            };
   
    NSArray *dataArray = @[dict1,dict2,dict3,dict4,dict5];
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
    NSLog(@"点击了第%ld个菜单项",tag);
    NSString *msgUrl = [NSString stringWithFormat:@"%@/%@",URL_APP_ROOT,[UserDefaultsUtils valueWithKey:@"msgManage"]];
    if (tag == 1) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@.unread",msgUrl]]]];
    }else if (tag == 4){
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:ALL_URLPATH]]];
    }else if (tag == 3){
        SettingViewController *settingVC = [[SettingViewController alloc] init];
        settingVC.delegate = self;
        [self.navigationController pushViewController:settingVC animated:YES];
    }else if (tag == 2){
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",msgUrl]]]];
    }else if (tag == 5){
        [UserDefaultsUtils saveValue:nil forKey:@"userName"];
        [UserDefaultsUtils saveValue:nil forKey:@"pwd"];
//        if ([UserDefaultsUtils valueWithKey:@"OutLogin"] == nil) {
//            NSLog(@"outLoginurl = %@",[UserDefaultsUtils valueWithKey:@"OutLogin"]);
//            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:OutLogin]]];
//        }else{
//            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[UserDefaultsUtils valueWithKey:@"OutLogin"]]]];
//        }
        [self.webView evaluateJavaScript:@"exit()" completionHandler:^(id _Nullable item, NSError * _Nullable error) {
            
        }];
    }
    [MenuView hidden];  // 隐藏菜单
    self.flag = YES;
}

- (void)dealloc{
    [MenuView clearMenu];   // 移除菜单
    [[NSNotificationCenter defaultCenter] removeObserver:self];//移除通知
    [[self.webView configuration].userContentController removeScriptMessageHandlerForName:@"webViewApp"];//移除js交互
}

#pragma mark - UIWebViewDelegate代理方法
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    NSString *userName = [UserDefaultsUtils valueWithKey:@"userName"];
    NSString *pwd = [UserDefaultsUtils valueWithKey:@"pwd"];
    if (userName != nil && pwd != nil) {
        [self.webView evaluateJavaScript:[NSString stringWithFormat:@"iosLogin(%@,%@)",userName,pwd] completionHandler:^(id _Nullable item, NSError * _Nullable error) {
            
        }];
    }
    //加载完成结束刷新
    [self endRefresh];
    //设置下拉刷新
    [self addRefreshView];

    //隐藏错误视图
    self.errorImageView.hidden = YES;
    //获取每个页面的url
    NSLog(@"URL -- %@ ----%@ ----%@",webView.URL.absoluteString,webView.URL.relativeString,webView.URL.relativePath);
    _urlPath = webView.URL.absoluteString;
    
    //每次加载判断是否是首页
    NSString *isMainStr;
    if ([UserDefaultsUtils valueWithKey:@"MainUrlStr"] == nil) {
        isMainStr = mainUrlStr;
    }else{
        isMainStr = MainUrlStr;
    }
    if ([isMainStr containsString:webView.URL.relativePath] && [webView.URL.absoluteString containsString:URL_APP_ROOT]) {
        self.navigationItem.leftBarButtonItem = nil;
    }else{
        self.navigationItem.leftBarButtonItem = [CustemNavItem initWithImage:[UIImage imageNamed:@"ic_nav_back"] andTarget:self andinfoStr:@"first"];
    }
    //设置标题
    [self setNavTitle:webView.title];
    
    //高度自适应
    NSString *isChangStr;
    if ([UserDefaultsUtils valueWithKey:@"ChangeStr"] == nil) {
        isChangStr = changeStr;
    }else{
        isChangStr = ChangeStr;
    }
    if ([isChangStr containsString:webView.URL.relativePath]) {
        NSString *js_fit_code = [NSString stringWithFormat:@"var meta = document.createElement('meta');"
                                 "meta.name = 'viewport';"
                                 "meta.content = 'width=device-width, initial-scale=1.0,minimum-scale=0.1, maximum-scale=1.0, user-scalable=yes';"
                                 "document.getElementsByTagName('head')[0].appendChild(meta);"
                                 ];
        [webView evaluateJavaScript:js_fit_code completionHandler:^(id _Nullable item, NSError * _Nullable error) {
            
        }];
        self.navigationItem.rightBarButtonItem = nil;
    }else{
        //设置导航栏的按钮
        self.navigationItem.rightBarButtonItem = [CustemNavItem initWithImage:[UIImage imageNamed:@"ic_nav_classify"] andTarget:self andinfoStr:@"third"];
        
        NSString *js_fit_code = [NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.zoom= '%.2f'",_scale];
        [webView evaluateJavaScript:js_fit_code completionHandler:^(id _Nullable item, NSError * _Nullable error) {
            
        }];
    }
}

//加载出错
-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"error = %@",error);
    //加载出错时，title
    [self setNavTitle:@"出错了"];
    self.errorImageView.hidden = NO;
    [DisplayUtils alertControllerDisplay:@"网络异常,请检查网络连接!" withUIViewController:self withConfirmBlock:^{
        NSLog(@"刷新");
        [self.webView reload];
    } withCancelBlock:^{
        NSLog(@"取消");
    }];
}
//出现白屏时刷新页面
-(void)webViewWebContentProcessDidTerminate:(WKWebView *)webView
{
    [self.webView reload];
}

#pragma mark - WKScriptMessageHandler代理方法（js交互）
-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    //获取type
    NSString *type = message.body[@"type"];
    
    if ([type isEqualToString:@"login"]) {//自动登录
        NSString *u = message.body[@"u"];
        NSString *p = message.body[@"p"];
        [UserDefaultsUtils saveValue:u forKey:@"userName"];
        [UserDefaultsUtils saveValue:p forKey:@"pwd"];
    }else if ([type isEqualToString:@"clearLogin"]){
        [UserDefaultsUtils saveValue:nil forKey:@"userName"];
        [UserDefaultsUtils saveValue:nil forKey:@"pwd"];
    }else if ([type isEqualToString:@"scanPay"]){//二维码扫描
        lhScanQCodeViewController * sqVC = [[lhScanQCodeViewController alloc]init];
        sqVC.delegate = self;
        UINavigationController * nVC = [[UINavigationController alloc]initWithRootViewController:sqVC];
        [self presentViewController:nVC animated:YES completion:^{
            
        }];
    }else if ([type isEqualToString:@"call"]){//拨打电话
        NSLog(@"%@",message.body);
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message.body[@"t"] message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *alertAction1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction *alertAction2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [DisplayUtils dialphoneNumber:message.body[@"t"]];
        }];
        [alertController addAction:alertAction1];
        [alertController addAction:alertAction2];
        [self presentViewController:alertController animated:YES completion:nil];
    }else if ([type isEqualToString:@"scan"]){//扫描卡号
        ScanViewController *scanVC = [[ScanViewController alloc] init];
        scanVC.delegate = self;
        [self.navigationController pushViewController:scanVC animated:YES];
    }else if ([type isEqualToString:@"showimage"]){
        NSString *imageUrl = message.body[@"url"];
        PingImageViewController *pinVC = [[PingImageViewController alloc] init];
        pinVC.imageStr = imageUrl;
        [self.navigationController pushViewController:pinVC animated:YES];
    }else{//微信支付
        //向微信注册
        [WXApi registerApp:message.body[@"appid"]];
        
        NSString *time_stamp, *nonce_str;
        //设置支付参数
        time_t now;
        time(&now);
        time_stamp  = [NSString stringWithFormat:@"%ld", now];
        nonce_str	= [DisplayUtils md5:time_stamp];
        
        PayReq *request   = [[PayReq alloc] init];
        request.openID    = message.body[@"appid"];
        request.nonceStr  = message.body[@"nonce_str"];
        request.package   = @"Sign=WXPay";
        request.partnerId = message.body[@"mch_id"];
        request.prepayId  = message.body[@"prepay_id"];
        request.timeStamp = [message.body[@"timestamp"] intValue];
        request.sign      = message.body[@"sign"];
        [WXApi sendReq:request];
    }
}

#pragma mark - 支付成功监听回调
-(void)paySucceed:(NSNotification *)notfi
{
    [self.webView evaluateJavaScript:@"ReturnBtnClick()" completionHandler:^(id _Nullable item, NSError * _Nullable error) {

    }];
}

#pragma mark - lhScanQCodeViewController代理方法
-(void)scanCodeReturn:(NSString *)urlStr
{
    NSString *js_fit_code = [NSString stringWithFormat:@"appRichScan('%@')",urlStr];
    [self.webView evaluateJavaScript:js_fit_code completionHandler:^(id _Nullable item, NSError * _Nullable error) {
        
    }];
}

#pragma mark - ScanViewController代理方法
-(void)scanCardReturn:(NSString *)urlStr
{
    NSString *strUrl = [urlStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSString *js_fit_code = [NSString stringWithFormat:@"scanCall('%@')",strUrl];
    [self.webView evaluateJavaScript:js_fit_code completionHandler:^(id _Nullable item, NSError * _Nullable error) {
        
    }];
}

-(void)backBar
{
    [self.webView reload];
}


#pragma mark --------wkwebview缩放的问题------------
-(void)perverseInfo:(float)scale
{
    _scale = scale;
    
    NSString *js_fit_code = [NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.zoom= '%.2f'",scale
                             ];
    [self.webView evaluateJavaScript:js_fit_code completionHandler:^(id _Nullable item, NSError * _Nullable error) {
        
    }];
}



@end

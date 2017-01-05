//
//  MessageViewController.m
//  e-healthy
//
//  Created by FangLin on 12/6/16.
//  Copyright © 2016 FangLin. All rights reserved.
//

#import "MessageViewController.h"
#import "CustemNavItem.h"
#import <WebKit/WebKit.h>
#import "WebViewJavascriptBridge.h"
#import "WKWebViewJavascriptBridge.h"
#import "WebViewJavascriptBridgeBase.h"
#import "NJKWebViewProgressView.h"
#import "NJKWebViewProgress.h"

@interface MessageViewController ()<CustemBBI,WKNavigationDelegate,WKUIDelegate,UIScrollViewDelegate>

@property (nonatomic,strong)WKWebView *webView;

@property (nonatomic,strong) NJKWebViewProgressView *progressView;

@property (nonatomic,strong) NJKWebViewProgress *progressProxy;

@property (nonatomic,strong) WebViewJavascriptBridge *uiBridge;

@property (nonatomic,strong) WKWebViewJavascriptBridge *wkBridge;

@property (nonatomic,strong) WVJBHandler handler;

@end

@implementation MessageViewController

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
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 64, screen_width, screen_height-64)];
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
        _webView.scrollView.delegate = self;
        [_webView addObserver:self forKeyPath:ObserveKeyPath options:NSKeyValueObservingOptionNew context:nil];
    }
    return _webView;
}

#pragma mark - 监听mk progress
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:ObserveKeyPath]) {
        [_progressView setProgress:self.webView.estimatedProgress animated:YES];
        self.progressView.hidden = self.webView.estimatedProgress == 1.0;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_url]]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = RGBColor(0, 0, 0, 1.0);
    self.navigationItem.leftBarButtonItem = [CustemNavItem initWithImage:[UIImage imageNamed:@"ic_nav_back"] andTarget:self andinfoStr:@"first"];
    [self addProgressView];
    [self.view addSubview:self.webView];
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

#pragma mark - UIWebViewDelegate代理方法
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    //设置标题
    [self setNavTitle:webView.title];
}

-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"error = %@",error);
    [self setNavTitle:@"出错了"];
}

#pragma mark - 导航栏
-(void)BBIdidClickWithName:(NSString *)infoStr
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

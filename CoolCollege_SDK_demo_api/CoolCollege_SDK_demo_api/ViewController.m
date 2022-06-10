//
//  ViewController.m
//  CoolCollege_SDK_demo_api
//
//  Created by 董帅文 on 2022/6/10.
//

#import "ViewController.h"
#import <dsBridge/DWKWebView.h>

// 主要是用于区分是否是 刘海屏
#define isXSeriesPhone \
({BOOL isLiuHaiPhone = NO;\
if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {\
    (isLiuHaiPhone);\
}\
CGSize size = [UIScreen mainScreen].bounds.size;\
NSInteger notchValue = size.width / size.height * 100;\
if (216 == notchValue || 46 == notchValue) {\
    isLiuHaiPhone = YES;\
}\
(isLiuHaiPhone);})

/*导航栏高度高度*/
#define kNavHeight (44)
/*状态栏高度(iPhoneX+状态栏高度为44)*/
#define kStatusBarHeight (CGFloat)(isXSeriesPhone?(44.0):(20.0))
/*状态栏高度+导航栏高度*/
#define kNavStatusHeight (kNavHeight+kStatusBarHeight)

#define CoolCollegeDemoH5 @"https://gsdn.coolcollege.cn/assets/h5-photo-camera/index.html"

@interface ViewController () <WKNavigationDelegate, WKUIDelegate>
@property (strong, nonatomic) DWKWebView *webView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createWebView];
}

- (void)createWebView {
    WKWebViewConfiguration* config = [[WKWebViewConfiguration alloc] init];
    config.applicationNameForUserAgent=@"iOS_App";
    config.allowsInlineMediaPlayback = YES;
    WKUserContentController* wkUserContentController = [[WKUserContentController alloc] init];
    config.userContentController = wkUserContentController;
    
    self.webView=[[DWKWebView alloc]initWithFrame:CGRectMake(0, kNavStatusHeight, self.view.bounds.size.width, self.view.bounds.size.height-kNavStatusHeight) configuration:config];
    self.webView.navigationDelegate=self;
    self.webView.allowsBackForwardNavigationGestures=NO;
    self.webView.DSUIDelegate = self;
    [self.webView addJavascriptObject:self namespace:@"local"];
    
    if(@available(iOS 11.0, *)) {
        self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.view addSubview:self.webView];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:CoolCollegeDemoH5]]];
    
    //TODO:kvo监听，获得页面title
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    [self.webView addObserver:self forKeyPath: @"canGoBack" options: NSKeyValueObservingOptionNew context: NULL];
}


// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *URL = navigationAction.request.URL;
    NSLog(@"=dsw= %@", URL);
    decisionHandler(WKNavigationActionPolicyAllow);
}

// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    NSLog(@"=dsw= %@", webView.URL);
    decisionHandler(WKNavigationResponsePolicyAllow);
}


- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"=dsw= didFailProvisionalNavigation : %@", error);
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"=dsw= didFailNavigation : %@", error);
}

//加载不受信任的https
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        NSURLCredential *card = [[NSURLCredential alloc]initWithTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential,card);
    }
}

#pragma mark KVO的监听代理
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"title"]) {
        if (object == self.webView) {
            self.title = self.webView.title;
        } else {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    } else if ([keyPath isEqualToString:@"canGoBack"]) {
        if (object == self.webView) {
//            self.leftBtn.hidden= !self.webView.canGoBack;
        } else {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    } else  {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end

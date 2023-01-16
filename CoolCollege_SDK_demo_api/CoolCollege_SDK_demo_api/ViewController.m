//
//  ViewController.m
//  CoolCollege_SDK_demo_api
//
//  Created by 董帅文 on 2022/6/10.
//

#import "ViewController.h"
// 交互webview
#import <dsbridge/DWKWebView.h>
// CoolCollegeApiSDK调用
#import <CoolCollegeApiSDK/CoolCollegeApiSDKHeader.h>

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

//#define CoolCollegeDemoH5 @"https://gsdn.coolcollege.cn/assets/h5-photo-camera/index.html" // 前端demo页
/*
 合富辉煌：token=zKpCwDQMivdtzA6VDdCWy0bdhwd7R0/HjTM63bzx3cBjyUwbws0l51sNrcFZwIkb       enterpriseId：1324923316665978965
 爱空间(熊师傅)：token=mkdT/mcuWn7J+IrhiJwSRLnru2pSHgntPKo3hO/OOaoIopPkupBBc8M+G3sF1ObrGWW/BpGLs8zp6jo2rkTRpw==    enterpriseId：1325057187583758354
 */
#define CoolCollegeDemoH5 @"https://app.coolcollege.cn?token=mkdT/mcuWn7J+IrhiJwSRLnru2pSHgntPKo3hO/OOaoIopPkupBBc8M+G3sF1ObrGWW/BpGLs8zp6jo2rkTRpw==" // 客户线上链接

@interface ViewController () <WKNavigationDelegate, WKUIDelegate>
@property (strong, nonatomic) DWKWebView *webView;
@property (nonatomic, strong) CoolCollegeApiManager* manager;
@property (nonatomic, copy) void(^activeChangeBlock)(NSString*);
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createWebView];
    
    self.manager = [[CoolCollegeApiManager alloc] init];
    [self initActivityChange];
}

-(void)initActivityChange{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hadEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hadEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

-(void)hadEnterBackground{
    if(self.activeChangeBlock){
        self.activeChangeBlock(@"background");
    }
}

-(void)hadEnterForeground{
    if(self.activeChangeBlock){
        self.activeChangeBlock(@"foreground");
    }
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
    [self.webView addJavascriptObject:self namespace:@"util"]; // 用于scan扫码交互
    [self.webView addJavascriptObject:self namespace:@"device"]; // 用于防切屏获取前、后台交互
    
    if(@available(iOS 11.0, *)) {
        self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.view addSubview:self.webView];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:CoolCollegeDemoH5]]];
    
    //TODO:kvo监听，获得页面title
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    [self.webView addObserver:self forKeyPath: @"canGoBack" options: NSKeyValueObservingOptionNew context: NULL];
}

// 前端交互方法nativeEvent
- (void)nativeEvent:(NSDictionary*)msgDict :(JSCallback)completionHandler {
    if (msgDict) {
        NSString* methodName = msgDict[@"methodName"];
        if (methodName) {
            NSString* methodData = msgDict[@"methodData"];
            NSData *data = [methodData dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
            NSDictionary* methodDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if (methodName && [methodName isEqualToString:@"chooseImage"]) {
                [self chooseImage:methodDict callback:completionHandler];
            } else if (methodName && [methodName isEqualToString:@"chooseVideo"]) {
                [self chooseVideo:methodDict callback:completionHandler];
            } else if (methodName && [methodName isEqualToString:@"uploadFile"]) {
                [self uploadFile:methodDict callback:completionHandler];
            } else if (methodName && [methodName isEqualToString:@"startAudioRecord"]) {
                [self startAudioRecord:methodDict callback:completionHandler];
            } else if (methodName && [methodName isEqualToString:@"startVideoRecord"]) {
                [self startVideoRecord:methodDict callback:completionHandler];
            } else if (methodName && [methodName isEqualToString:@"OSSUploadFile"]) {
                [self OSSUploadFile:methodDict callback:completionHandler];
            } else if (methodName && [methodName isEqualToString:@"shareMenu"]) {
                [self shareMenu:methodDict callback:completionHandler];
            } else if (methodName && [methodName isEqualToString:@"scan"]) {
                [self scan:methodDict callback:completionHandler];
            } else if (methodName && [methodName isEqualToString:@"getLocation"]) {
                [self getLocation:methodDict callback:completionHandler];
            } else if (methodName && [methodName isEqualToString:@"vibration"]) {
                [self vibration:methodDict];
            } else if (methodName && [methodName isEqualToString:@"sendMessage"]) {
                [self sendMessage:methodDict];
            } else if (methodName && [methodName isEqualToString:@"copyMessage"]) {
                [self copyMessage:methodDict];
            } else if (methodName && [methodName isEqualToString:@"saveImage"]) {
                [self saveImage:methodDict callback:completionHandler];
            } else {
                NSString* errorMsg = [NSString stringWithFormat:@"%@ unimplemented", methodName];
                [self onFail:completionHandler error:errorMsg];
            }
        }
    }
}

// 扫码交互
-(void)scan:(id) data :(JSCallback)completionHandler{
    [CoolCollegeApiManager scanWithController:self successCallback:^(NSString * _Nonnull result) {
        [self onSuccess:completionHandler result:result];
    } failCallback:^(NSString * _Nonnull message) {
        [self onFail:completionHandler error:message];
    }];
}

// 获取app前、后台状态
-(void)onActiveChange:(id) data :(JSCallback)responseCallback{
     __weak __typeof(self) weakSelf = self;
    self.activeChangeBlock = ^(NSString * data) {
        [weakSelf.webView callHandler:@"device.onActiveChange" arguments:@[data]];
    };
    [self onSuccess:responseCallback result:@"ok"];
}

// 获取手机系统信息
-(void)getSystemInfo:(id) data :(JSCallback)responseCallback{
    [self.manager getSystemInfoWithSuccessCallback:^(NSDictionary * _Nonnull info) {
        NSData* data=[NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:nil];
        NSString* jsonStr=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        [self onSuccess:responseCallback result:jsonStr];
    } failCallback:^(NSString * _Nonnull message) {
        [self onFail:responseCallback error:message];
    }];
}

// 选择图片(相册/相机)
- (void)chooseImage:(NSDictionary*)methodDict callback:(JSCallback)completionHandler {
    int compressed = [methodDict[@"compressed"] intValue];
    int count = [methodDict[@"count"] intValue];
    NSArray* sourceTypeArr = methodDict[@"sourceType"];
    if (sourceTypeArr) {
        if (sourceTypeArr.count == 1) {
            NSString* sourceType = sourceTypeArr[0];
            if ([sourceType isEqualToString:@"album"]) {
                [CoolCollegeApiManager getImageByAlbumCompressed:compressed count:count controller:self successCallback:^(NSArray * _Nonnull files) {
                    [self onSuccess:completionHandler result:files];
                } failCallback:^(NSString * _Nonnull message) {
                    [self onFail:completionHandler error:message];
                }];
            } else if ([sourceType isEqualToString:@"camera"]) {
                [CoolCollegeApiManager getImageByCameraCompressed:compressed controller:self successCallback:^(NSArray * _Nonnull files) {
                    [self onSuccess:completionHandler result:files];
                } failCallback:^(NSString * _Nonnull message) {
                    [self onFail:completionHandler error:message];
                }];
            } else {}
        } else if (sourceTypeArr.count == 2) {
            [ViewController presentActionSheetWithController:self title:nil message:nil
                                                    sheetOne:@"相册"
                                                    sheetTwo:@"相机"
                                                 sheetBottom:@"取消"
                                            sheetOneCallback:^{
                [CoolCollegeApiManager getImageByAlbumCompressed:compressed count:count controller:self successCallback:^(NSArray * _Nonnull files) {
                    [self onSuccess:completionHandler result:files];
                } failCallback:^(NSString * _Nonnull message) {
                    [self onFail:completionHandler error:message];
                }];
            } sheetTwoCallback:^{
                [CoolCollegeApiManager getImageByCameraCompressed:compressed controller:self successCallback:^(NSArray * _Nonnull files) {
                    [self onSuccess:completionHandler result:files];
                } failCallback:^(NSString * _Nonnull message) {
                    [self onFail:completionHandler error:message];
                }];
            }];
        } else {
            return;
        }
    }
}

// 选择视频(相册/相机)
- (void)chooseVideo:(NSDictionary*)methodDict callback:(JSCallback)completionHandler {
    int compressed = [methodDict[@"compressed"] intValue]?[methodDict[@"compressed"] intValue]:1;
    int count = [methodDict[@"count"] intValue]?[methodDict[@"count"] intValue]:1;
    int maxDuration = [methodDict[@"maxDuration"] intValue];
    NSArray* sourceTypeArr = methodDict[@"sourceType"];
    if (sourceTypeArr) {
        if (sourceTypeArr.count == 1) {
            NSString* sourceType = sourceTypeArr[0];
            if ([sourceType isEqualToString:@"album"]) {
                [CoolCollegeApiManager getVideoByAlbumCompressed:compressed count:count maxDuration:maxDuration controller:self successCallback:^(NSArray * _Nonnull files) {
                    [self onSuccess:completionHandler result:files];
                } failCallback:^(NSString * _Nonnull message) {
                    [self onFail:completionHandler error:message];
                }];
            } else if ([sourceType isEqualToString:@"camera"]) {
                [CoolCollegeApiManager getVideoByCameraCompressed:compressed maxDuration:maxDuration controller:self successCallback:^(NSArray * _Nonnull files) {
                    [self onSuccess:completionHandler result:files];
                } failCallback:^(NSString * _Nonnull message) {
                    [self onFail:completionHandler error:message];
                }];
            } else {}
        } else if (sourceTypeArr.count == 2) {
            [ViewController presentActionSheetWithController:self title:nil message:nil
                                                    sheetOne:@"相册"
                                                    sheetTwo:@"相机"
                                                 sheetBottom:@"取消"
                                            sheetOneCallback:^{
                [CoolCollegeApiManager getVideoByAlbumCompressed:compressed count:count maxDuration:maxDuration controller:self successCallback:^(NSArray * _Nonnull files) {
                    [self onSuccess:completionHandler result:files];
                } failCallback:^(NSString * _Nonnull message) {
                    [self onFail:completionHandler error:message];
                }];
            } sheetTwoCallback:^{
                [CoolCollegeApiManager getVideoByCameraCompressed:compressed maxDuration:maxDuration controller:self successCallback:^(NSArray * _Nonnull files) {
                    [self onSuccess:completionHandler result:files];
                } failCallback:^(NSString * _Nonnull message) {
                    [self onFail:completionHandler error:message];
                }];
            }];
        } else {
            return;
        }
    }
}

// 录制音频
- (void)startAudioRecord:(NSDictionary*)methodData callback:(JSCallback)completionHandler {
    int maxDuration = [(methodData[@"maxDuration"]?:@(60)) intValue];
    [CoolCollegeApiManager startAudioRecord:maxDuration controller:self successCallback:^(NSDictionary * _Nonnull files) {
        [self onSuccess:completionHandler result:files];
    } failCallback:^(NSString * _Nonnull message) {
        [self onFail:completionHandler error:message];
    }];
}

// 录制视频
- (void)startVideoRecord:(NSDictionary*)methodDict callback:(JSCallback)completionHandler {
    int maxDuration = [methodDict[@"maxDuration"] intValue];
    [CoolCollegeApiManager getVideoByCameraCompressed:1 maxDuration:maxDuration controller:self successCallback:^(NSArray * _Nonnull files) {
        [self onSuccess:completionHandler result:files];
    } failCallback:^(NSString * _Nonnull message) {
        [self onFail:completionHandler error:message];
    }];
}


// 通用文件上传
- (void)uploadFile:(NSDictionary*)methodDict callback:(JSCallback)completionHandler {
    NSDictionary* uploadInfo = @{@"filePath":methodDict[@"filePath"]?:@"",
                                 @"fileType":methodDict[@"fileType"]?:@"",
                                 @"formData":methodDict[@"formData"]?:@{},
                                 @"name":methodDict[@"name"]?:@"",
                                 @"url":methodDict[@"url"]?:@"",
                                 @"header":methodDict[@"header"]?:@{}};
    [CoolCollegeApiManager uploadFile:uploadInfo controller:self successCallback:^(NSDictionary * _Nonnull response) {
        NSError *error;
        NSData *data=[NSJSONSerialization dataWithJSONObject:response options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonStr=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        
        [self onSuccess:completionHandler result:jsonStr];
    } failCallback:^(NSString * _Nonnull message) {
        [self onFail:completionHandler error:message];
    }];
}

// OSS文件上传
- (void)OSSUploadFile:(NSDictionary*)methodDict callback:(JSCallback)completionHandler {
    // accessToken与enterpriseId由原生提供
    NSDictionary* uploadInfo = @{@"files":methodDict[@"files"],
                                 @"type":methodDict[@"type"],
                                 @"accessToken":methodDict[@"accessToken"],
                                 @"enterpriseId":@"1325057187583758354"}; // 客户集成方宿主app 持有企业id
    
    [CoolCollegeApiManager OSSUploadFile:uploadInfo controller:self successCallback:^(NSArray * _Nonnull files) {
        [self onSuccess:completionHandler result:files];
    } failCallback:^(NSDictionary * _Nonnull error) {
        [self onFail:completionHandler error:error];
    }];
}

// 唤起分享弹窗
- (void)shareMenu:(NSDictionary*)methodData callback:(JSCallback)completionHandler {
    NSDictionary* shareInfo = @{@"logo":methodData[@"logo"]?:@"",
                                @"title":methodData[@"title"]?:@"",
                                @"url":methodData[@"url"]?:@""};
    
    [CoolCollegeApiManager shareUniversal:shareInfo controller:self callback:^(NSString * _Nonnull type, BOOL completed) {
        NSString* shareState = completed?@"success":@"cancel";
        NSDictionary* paramDict = @{@"platformType":type, @"shareState":shareState};
        [self onSuccess:completionHandler result:paramDict];
    }];
}

// 扫描二维码
- (void)scan:(NSDictionary*)methodData callback:(JSCallback)completionHandler {
    [CoolCollegeApiManager scanWithController:self successCallback:^(NSString * _Nonnull result) {
        [self onSuccess:completionHandler result:result];
    } failCallback:^(NSString * _Nonnull message) {
        [self onFail:completionHandler error:message];
    }];
}

// 获取定位信息
- (void)getLocation:(NSDictionary*)methodData callback:(JSCallback)completionHandler {
    [self.manager getLocationWithController:self successCallback:^(NSDictionary * _Nonnull info) {
        NSError *error;
        NSData *locationData = [NSJSONSerialization dataWithJSONObject:info
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        NSString* locationJsonParam = [[NSString alloc] initWithData:locationData encoding:NSUTF8StringEncoding];
        [self onSuccess:completionHandler result:locationJsonParam];
    } failCallback:^(NSString * _Nonnull message) {
        [self onFail:completionHandler error:message];
    }];
}

- (void)vibration:(NSDictionary*)methodData {
    NSNumber* duration = methodData[@"duration"];
    float durationValue = [(duration?:@(200)) floatValue]/1000;
    [self.manager vibrateWithDuration:durationValue];
}

- (void)sendMessage:(NSDictionary*)methodData {
    [self.manager sendMessage:methodData[@"content"]?:@"" withController:self];
}

- (void)copyMessage:(NSDictionary*)methodData {
    [self.manager copyMessage:methodData[@"content"]?:@"" alert:methodData[@"alert"]?:@"" withController:self];
}

- (void)saveImage:(NSDictionary*)methodData callback:(JSCallback)completionHandler {
    [self.manager saveImage:methodData[@"url"]?:@""
             withController:self];
}

- (void)onSuccess:(JSCallback)callback result:(id)result {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:result forKey:@"result"];
    NSData *data=[NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonStr=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    callback(jsonStr,YES);
}

- (void)onFail:(JSCallback)callback error:(id)error {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[NSNumber numberWithBool:YES] forKey:@"isError"];
    [dictionary setValue:error forKey:@"error"];
    NSData *data=[NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonStr=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    callback(jsonStr,NO);
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

+ (void)presentActionSheetWithController:(UIViewController*)controller
                                   title:(nullable NSString*)title
                                 message:(nullable NSString*)message
                                sheetOne:(nullable NSString*)sheetOne
                                sheetTwo:(NSString*)sheetTwo
                             sheetBottom:(NSString*)sheetBottom
                        sheetOneCallback:(void(^)(void))oneCallback
                        sheetTwoCallback:(void(^)(void))twoCallback {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    if (sheetOne) {
        UIAlertAction* sheetOneAction = [UIAlertAction actionWithTitle:sheetOne style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            oneCallback();
        }];
        [alertController addAction:sheetOneAction];
    }
    
    UIAlertAction* sheetTwoAction = [UIAlertAction actionWithTitle:sheetTwo style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        twoCallback();
    }];
    [alertController addAction:sheetTwoAction];
    
    UIAlertAction* sheetBottomAction = [UIAlertAction actionWithTitle:sheetBottom style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
    [alertController addAction:sheetBottomAction];
    
    [controller presentViewController:alertController animated:YES completion:nil];
    return;
}


@end

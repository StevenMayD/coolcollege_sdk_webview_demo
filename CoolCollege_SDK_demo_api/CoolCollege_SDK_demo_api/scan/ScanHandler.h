//
//  ScanHandler.h
//  CoolCollege_SDK_demo_api
//
//  Created by 董帅文 on 2022/10/20.
//

#import <Foundation/Foundation.h>
#import <dsbridge/DWKWebView.h>

NS_ASSUME_NONNULL_BEGIN

@interface ScanHandler : NSObject
+ (instancetype)shareInstance;
- (void)initHandler:(DWKWebView*) webView vc:(UIViewController*)viewController;
@end

NS_ASSUME_NONNULL_END

//
//  ScanHandler.m
//  CoolCollege_SDK_demo_api
//
//  Created by 董帅文 on 2022/10/20.
//

#import "ScanHandler.h"
#import <objc/runtime.h>
#import <CoolCollegeApiSDK/CoolCollegeApiSDKHeader.h>

@interface ScanHandler ()
@property(nonatomic, weak) UIViewController * viewController;
@end

@implementation ScanHandler

+ (instancetype)shareInstance {
    id instance = objc_getAssociatedObject(self, @"instance");
    if (!instance) {
        instance = [[super allocWithZone:NULL] init];
        objc_setAssociatedObject(self, @"instance", instance, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self shareInstance] ;
}

- (id)copyWithZone:(struct _NSZone *)zone {
    Class selfClass = [self class];
    return [selfClass shareInstance] ;
}

- (void)initHandler:(DWKWebView *)webView vc:(UIViewController *)viewController{
    self.viewController = viewController;
    [webView addJavascriptObject:self namespace:@"util"];
}

-(void)scan:(id) data :(JSCallback)completionHandler{
    [CoolCollegeApiManager scanWithController:self.viewController successCallback:^(NSString * _Nonnull result) {
        [self onSuccess:completionHandler result:result];
    } failCallback:^(NSString * _Nonnull message) {
        [self onFail:completionHandler error:message];
    }];
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

@end

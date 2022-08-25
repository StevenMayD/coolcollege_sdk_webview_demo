//
//  CoolCollegeApiManager.h
//  CoolCollegeApiSDK
//
//  Created by 董帅文 on 2022/5/17.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CoolCollegeApiManager : NSObject

/// 获取图片从相机
/// @param compressed 是否压缩图片（1：压缩； 0：不压缩）
/// @param controller 调用方视图控制器
/// @param success 成功回调
/// @param fail 失败回调
+ (void)getImageByCameraCompressed:(int)compressed
                        controller:(UIViewController*)controller
                   successCallback:(void(^)(NSArray* files))success
                      failCallback:(void(^)(NSString* message))fail;

/// 获取图片从相册
/// @param compressed 是否压缩图片（1：压缩； 0：不压缩）
/// @param count 图片数量
/// @param controller 调用方视图控制器
/// @param success 成功回调
/// @param fail 失败回调
+ (void)getImageByAlbumCompressed:(int)compressed
                            count:(int)count
                       controller:(UIViewController*)controller
                  successCallback:(void(^)(NSArray* files))success
                     failCallback:(void(^)(NSString* message))fail;

/// 获取视频从相机
/// @param compressed 是否压缩图片（1：压缩； 0：不压缩）
/// @param duration 最大拍摄时时长
/// @param controller 调用方视图控制器
/// @param success 成功回调
/// @param fail 失败回调
+ (void)getVideoByCameraCompressed:(int)compressed
                       maxDuration:(int)duration
                        controller:(UIViewController*)controller
                   successCallback:(void(^)(NSArray* files))success
                      failCallback:(void(^)(NSString* message))fail;

/// 获取视频从相册
/// @param compressed 是否压缩图片（1：压缩； 0：不压缩）
/// @param count 视频数量
/// @param duration 相册视频最大时长
/// @param controller 调用方视图控制器
/// @param success 成功回调
/// @param fail 失败回调
+ (void)getVideoByAlbumCompressed:(int)compressed
                            count:(int)count
                      maxDuration:(int)duration
                       controller:(UIViewController*)controller
                  successCallback:(void(^)(NSArray* files))success
                     failCallback:(void(^)(NSString* message))fail;


/// 音频录制
/// @param maxDuration 最大录制时长
/// @param controller 调用方视图控制器
/// @param success 成功回调
/// @param fail 失败回调
+ (void)startAudioRecord:(int)maxDuration
              controller:(UIViewController*)controller
         successCallback:(void(^)(NSDictionary* files))success
            failCallback:(void(^)(NSString* message))fail;

/// 文件上传（上传成功后自动清除文件）
/// @param uploadInfo 上传信息
/*
    name        String      文件名称
    url         String      请求接口url
    filePath    String      文件路径
    header      NSDictionary    请求头
    formData    NSDictionary    form表单数据
    fileType    String          文件类型（图片：Image、视频：Video、音频：Audio）
 */
/// @param controller 调用方视图控制器
/// @param success 成功回调
/// @param fail 失败回调
+ (void)uploadFile:(NSDictionary*)uploadInfo
        controller:(UIViewController*)controller
   successCallback:(void(^)(NSDictionary* response))success
      failCallback:(void(^)(NSString* message))fail;

/// 文件上传至OSS（上传成功后自动清除文件）
/// @param uploadInfo 上传信息
/*
    files           NSArray[NSDictionary]   上传文件对象的数组，文件对象的属性如下: filePath：String - 待上传文件的路径；objectKey：String - 待上传文件的命名（不能含文件类型后缀）
    type            String                  上传文件的类型
    accessToken     String                  上传接口调用的token
    enterpriseId    String                  企业id
 */
/// @param controller 调用方视图控制器
/// @param success 成功回调 {@"path": , @"videoId": , @"name": , @"size":}
/// @param fail 失败回调 {@"code": , @"message":}
+ (void)OSSUploadFile:(NSDictionary*)uploadInfo
           controller:(UIViewController*)controller
      successCallback:(void(^)(NSArray* files))success
         failCallback:(void(^)(NSDictionary* error))fail;

/// 清除产生的所有资源文件（拍摄或选取，但没有上传的图片、视频，会积累在沙盒/tmp/media中，需要自主清除)
+ (void)deleteAllMediaFiles;

/// 系统分享
/// @param shareInfo 分享信息
/*
    title   String   分享主题
    logo    String   分享logo
    url     String   分享链接
 */
/// @param controller 调用方视图控制器
/// @param callback     分享回调 （ type：分享渠道， completed：分享结果）
+ (void)shareUniversal:(NSDictionary*)shareInfo
            controller:(UIViewController*)controller
              callback:(void(^)(NSString* type, BOOL completed))callback;

/// 扫描二维码
/// @param controller 调用方视图控制器
/// @param success 成功回调 扫描识别结果
/// @param fail 失败回调  失败信息
+ (void)scanWithController:(UIViewController*)controller
           successCallback:(void(^)(NSString* result))success
              failCallback:(void(^)(NSString* message))fail;

/// 获取定位信息
/// @param controller 调用方视图控制器
/// @param success 成功回调 扫描识别结果
/// @param fail 失败回调  失败信息
- (void)getLocationWithController:(UIViewController*)controller
                  successCallback:(void(^)(NSDictionary* info))success
                     failCallback:(void(^)(NSString* message))fail;

@end

NS_ASSUME_NONNULL_END

//
//  LXDRequest.h
//  Pods
//
//  Created by didi on 2017/8/24.
//
//

#import <Foundation/Foundation.h>




NS_ASSUME_NONNULL_BEGIN

extern NSString *const LXDLoseConnectNotification;

@class LXDBaseApi;
@class LXDUploadApi;
typedef void(^LXDRequestCancel)(LXDBaseApi *api);
typedef void(^LXDUploadProgress)(LXDBaseApi *api, CGFloat progress);
typedef void(^LXDRequestComplete)(__nullable id data, NSError * __nullable error);

/*!
 *  @class  LXDRequest
 *  请求对象
 */
@interface LXDRequest : NSObject

/*!
 *  @method requestApi:complete:
 *  传入一个API对象进行请求
 */
+ (void)requestApi: (LXDBaseApi *)api
            cancel: (__nullable LXDRequestCancel)cancel
          complete: (LXDRequestComplete)complete;

/*!
 *  @method uploadApi:cancel:complete:
 *  上传api文件
 */
+ (void)uploadApi: (LXDUploadApi *)api
           cancel: (__nullable LXDRequestCancel)cancel
         complete: (LXDRequestComplete)complete;

/*!
 *  @method uploadApi:cancel:complete:
 *  上传api文件，可以传入监听上传进度
 */
+ (void)uploadApi: (LXDUploadApi *)api
         progress: (__nullable LXDUploadProgress)progress
           cancel: (__nullable LXDRequestCancel)cancel
         complete: (LXDRequestComplete)complete;

/*!
 *  @method cancelApi:
 *  取消一个网络请求，只需要传入类名即可
 */
+ (void)cancelApi: (Class)apiCls;

@end

NS_ASSUME_NONNULL_END

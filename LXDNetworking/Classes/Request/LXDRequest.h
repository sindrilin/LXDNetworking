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
typedef void(^LXDRequestCancel)(LXDBaseApi *api);
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
 *  @method cancelApi:
 *  取消一个网络请求，只需要传入类名即可
 */
+ (void)cancelApi: (Class)apiCls;

@end

NS_ASSUME_NONNULL_END

//
//  LXDBatchRequest.h
//  Pods
//
//  Created by linxinda on 2017/8/30.
//
//

#import <Foundation/Foundation.h>

@class LXDBaseApi;
@class LXDBatchApi;
typedef void(^LXDRequestFailed)(LXDBaseApi *api);
typedef void(^LXDRequestSuccess)(LXDBaseApi *api);

/*!
 *  @class  LXDBatchRequest
 *  批量请求对象
 */
@interface LXDBatchRequest : NSObject

/*!
 *  @method requestApi:success:failed:complete:
 *  发起批量请求，请求完成后调用complete
 */
+ (void)requestApi: (LXDBatchApi *)api
           success: (LXDRequestSuccess)success
            failed: (LXDRequestFailed)failed
          complete: (dispatch_block_t)complete;

@end

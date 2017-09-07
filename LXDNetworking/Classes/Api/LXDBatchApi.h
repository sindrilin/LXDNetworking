//
//  LXDBatchApi.h
//  Pods
//
//  Created by linxinda on 2017/8/30.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class LXDBaseApi;
/*!
 *  @class  LXDBatchApi
 *  批量api
 */
@interface LXDBatchApi : NSObject

/*!
 *  @property   apis
 *  返回所有的请求api
 */
@property (nonatomic, readonly, copy) NSArray<__kindof LXDBaseApi *> *apis;

/*!
 *  @method batchApiWithApis:
 *  传入批量的网络请求
 */
+ (nullable instancetype)batchApiWithApis: (NSArray<__kindof LXDBaseApi *> *)apis;

@end


NS_ASSUME_NONNULL_END

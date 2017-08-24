//
//  LXDPageBaseApi.h
//  Pods
//
//  Created by didi on 2017/8/24.
//
//

#import "LXDBaseApi.h"

NS_ASSUME_NONNULL_BEGIN
/*!
 *  @class  LXDPageBaseApi
 *  分页请求API
 */
@interface LXDPageBaseApi : LXDBaseApi

/*!
 *  @property   page
 *  请求页数
 */
@property (nonatomic, assign) NSUInteger page;

/*!
 *  @property   pageCount
 *  请求每一页返回的数据数量
 */
@property (nonatomic, readonly) NSUInteger pageCount;

@end

NS_ASSUME_NONNULL_END

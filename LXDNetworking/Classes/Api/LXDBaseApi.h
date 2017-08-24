//
//  LXDBaseApi.h
//  Pods
//
//  Created by didi on 2017/8/24.
//
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, LXDRequestMethod)
{
    LXDRequestMethodGet,
    LXDRequestMethodPost,
};

typedef NS_ENUM(NSInteger, LXDResponseType)
{
    LXDResponseTypeHTTP = 1 << 0,
    LXDResponseTypeJSON = 1 << 1,
};

typedef NS_ENUM(NSInteger, LXDRequestType)
{
    LXDRequestTypeHTTP = 1 << 2,
    LXDRequestTypeJSON = 1 << 3,
};


NS_ASSUME_NONNULL_BEGIN

/*!
 *  @class  LXDBaseApi
 *  统一网络请求API对象
 */
@interface LXDBaseApi : NSObject

/*!
 *  @property   url
 *  请求地址
 */
@property (nonatomic, readonly) NSString *url;

/*!
 *  @property   params
 *  请求参数
 */
@property (nonatomic, readonly) NSDictionary *params;

/*!
 *  @property   requestType
 *  请求参数包装格式
 */
@property (nonatomic, readonly) LXDRequestType requestType;

/*!
 *  @property   responseType
 *  返回数据包装格式
 */
@property (nonatomic, readonly) LXDResponseType responseType;

/*!
 *  @property   requestMethod
 *  请求方法
 */
@property (nonatomic, readonly) LXDRequestMethod requestMethod;

@end

NS_ASSUME_NONNULL_END

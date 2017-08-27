//
//  LXDBaseApi.m
//  Pods
//
//  Created by didi on 2017/8/24.
//
//

#import "LXDBaseApi.h"

@implementation LXDBaseApi


- (NSString *)url {
    @throw [NSException exceptionWithName: NSInvalidArgumentException reason: [NSString stringWithFormat: @"Call [%@ url] is invalid", [self class]] userInfo: @{}];
}

- (NSDictionary *)params {
    return @{};
}

- (NSDictionary *)headers {
    return nil;
}

- (LXDRequestType)requestType {
    return LXDRequestTypeJSON;
}

- (LXDResponseType)responseType {
    return LXDResponseTypeJSON;
}

- (LXDRequestMethod)requestMethod {
    return LXDRequestMethodGet;
}

- (NSUInteger)hash {
    return [self.url hash];
}

- (BOOL)isEqual: (id)object {
    if (object == self) { return YES; }
    if ([object isKindOfClass: [self class]]) {
        LXDBaseApi *baseApi = object;
        return (baseApi.params.count == self.params.count && baseApi.requestMethod == self.requestMethod);
    }
    return NO;
}


@end

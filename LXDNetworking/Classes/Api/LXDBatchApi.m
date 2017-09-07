//
//  LXDBatchApi.m
//  Pods
//
//  Created by linxinda on 2017/8/30.
//
//

#import "LXDBatchApi.h"

@implementation LXDBatchApi


+ (instancetype)batchApiWithApis: (NSArray<__kindof LXDBaseApi *> *)apis {
    return [[self alloc] initWithApis: apis];
}

- (instancetype)initWithApis: (NSArray<__kindof LXDBaseApi *> *)apis {
    if (self = [super init]) {
        _apis = [NSArray arrayWithArray: apis];
    }
    return self;
}


@end

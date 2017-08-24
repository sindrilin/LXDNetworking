//
//  LXDPageBaseApi.m
//  Pods
//
//  Created by didi on 2017/8/24.
//
//

#import "LXDPageBaseApi.h"

@implementation LXDPageBaseApi


- (NSUInteger)hash {
    return [self.url hash] ^ (self.pageCount << 8);
}

- (BOOL)isEqual: (id)object {
    if (object == self) { return YES; }
    if ([object isKindOfClass: [self class]]) {
        LXDPageBaseApi *baseApi = object;
        return ([super isEqual: object] && baseApi.pageCount == self.pageCount);
    }
    return NO;
}


@end

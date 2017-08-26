//
//  LXDRequest.m
//  Pods
//
//  Created by didi on 2017/8/24.
//
//

#import "LXDRequest.h"
#import "LXDBaseApi.h"
#import <AFNetworking/AFNetworking.h>


NSString *const LXDLoseConnectNotification = @"LXDLoseConnectNotification";


#pragma mark - Queue & Lock & Manager
static inline NSMutableArray *__api_queue() {
    static NSMutableArray *__api_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __api_queue = [NSMutableArray array];
    });
    return __api_queue;
}

static inline dispatch_semaphore_t __queue_lock() {
    static dispatch_semaphore_t __queue_lock;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __queue_lock = dispatch_semaphore_create(1);
    });
    return __queue_lock;
}


#pragma mark - Queue task
@interface LXDRequestTask: NSObject

@property (nonatomic, assign) BOOL isCanceled;

@property (nonatomic, strong) LXDBaseApi *api;
@property (nonatomic, copy) LXDRequestCancel cancel;
@property (nonatomic, copy) LXDRequestComplete complete;

- (instancetype)initWithApi: (LXDBaseApi *)api
                     cancel: (LXDRequestCancel)cancel
                   complete: (LXDRequestComplete)complete;

- (void)cancelRequest;
- (void)completeWithData: (NSData *)data error: (NSError *)error;

@end

@implementation LXDRequestTask


static AFNetworkReachabilityStatus lxd_network_status = AFNetworkReachabilityStatusReachableViaWiFi;
+ (void)initialize {
    AFNetworkReachabilityManager * manager = [AFNetworkReachabilityManager sharedManager];
    lxd_network_status = manager.networkReachabilityStatus;
    [manager setReachabilityStatusChangeBlock: ^(AFNetworkReachabilityStatus status) {
        lxd_network_status = status;
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
            case AFNetworkReachabilityStatusNotReachable:
                [[NSNotificationCenter defaultCenter] postNotificationName: LXDLoseConnectNotification object: nil];
                break;
                
            default:
                break;
        }
    }];
    [manager startMonitoring];
}

- (instancetype)initWithApi: (LXDBaseApi *)api
                     cancel: (LXDRequestCancel)cancel
                   complete: (LXDRequestComplete)complete {
    if (self = [super init]) {
        self.api = api;
        self.cancel = cancel;
        self.complete = complete;
    }
    return self;
}

- (void)cancelRequest {
    self.isCanceled = YES;
    if (self.cancel) {
        self.cancel(self.api);
        self.cancel = nil;
    }
}

- (void)completeWithData: (NSData *)data error: (NSError *)error {
    if (self.complete && !self.isCanceled) {
        self.complete(data, error);
        self.complete = nil;
    }
}

- (NSUInteger)hash {
    return [_api hash];
}

- (BOOL)isEqual: (id)object {
    if (object == self) { return YES; }
    if ([object isKindOfClass: [self class]]) {
        LXDRequestTask *task = object;
        return [task.api isEqual: _api];
    }
    if ([object isKindOfClass: [LXDBaseApi class]]) {
        LXDBaseApi *api = object;
        return [api isEqual: _api];
    }
    return NO;
}


@end


#pragma mark - Request
@implementation LXDRequest


#pragma mark - Public
+ (void)requestApi: (LXDBaseApi *)api
            cancel: (LXDRequestCancel)cancel
          complete: (LXDRequestComplete)complete {
    if (lxd_network_status == AFNetworkReachabilityStatusUnknown ||
        lxd_network_status == AFNetworkReachabilityStatusNotReachable) {
        if (cancel) {  cancel(api); }
        return;
    }
    
    dispatch_semaphore_wait(__queue_lock(), DISPATCH_TIME_FOREVER);
    
    NSMutableArray *apiQueue = __api_queue();
    NSInteger idx = [apiQueue indexOfObject: api];
    [self _cancelTaskAtIndex: idx];
    
    LXDRequestTask *task = [[LXDRequestTask alloc] initWithApi: api
                                                        cancel: cancel
                                                      complete: complete];
    [self _sendRequestTaskToManager: task];
    
    dispatch_semaphore_signal(__queue_lock());
}

+ (void)cancelApi: (Class)apiCls {
    dispatch_semaphore_wait(__queue_lock(), DISPATCH_TIME_FOREVER);
    
    LXDBaseApi *api = [apiCls new];
    NSMutableArray *apiQueue = __api_queue();
    NSInteger idx = [apiQueue indexOfObject: api];
    [self _cancelTaskAtIndex: idx];
    
    dispatch_semaphore_signal(__queue_lock());
}


#pragma mark - Private
+ (void)_cancelTaskAtIndex: (NSInteger)idx {
    if (idx != NSNotFound) {
        LXDRequestTask *task = __api_queue()[idx];
        [task cancelRequest];
        [__api_queue() removeObjectAtIndex: idx];
    }
}

+ (AFHTTPSessionManager *)_commonRequestManager {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    AFSecurityPolicy * policy = [AFSecurityPolicy defaultPolicy];
    policy.allowInvalidCertificates = YES;
    policy.validatesDomainName = NO;
    manager.securityPolicy = policy;
    return manager;
}

+ (void)_sendRequestTaskToManager: (LXDRequestTask *)task {
    
    AFHTTPSessionManager *manager = [self _getRequestManagerInstanceWithApi: task.api];
    LXDRequestComplete complete = ^(id data, NSError *error) {
        dispatch_semaphore_wait(__queue_lock(), DISPATCH_TIME_FOREVER);
        [__api_queue() removeObject: task];
        dispatch_semaphore_signal(__queue_lock());
        [task completeWithData: data error: error];
    };
    
    switch (task.api.requestMethod) {
        case LXDRequestMethodGet: {
            [manager GET: task.api.url parameters: task.api.params progress: nil success: ^(NSURLSessionDataTask * _Nonnull dataTask, id  _Nullable responseObject) {
                complete(responseObject, nil);
            } failure: ^(NSURLSessionDataTask * _Nullable dataTask, NSError * _Nonnull error) {
                complete(nil, error);
            }];
        } break;
            
        case LXDRequestMethodPost: {
            [manager POST: task.api.url parameters: task.api.params progress: nil success: ^(NSURLSessionDataTask * _Nonnull dataTask, id  _Nullable responseObject) {
                complete(responseObject, nil);
            } failure: ^(NSURLSessionDataTask * _Nullable dataTask, NSError * _Nonnull error) {
                complete(nil, error);
            }];
        } break;
    }
}

+ (AFHTTPSessionManager *)_getRequestManagerInstanceWithApi: (LXDBaseApi *)api {
    typedef AFHTTPSessionManager *(^LXDManagerGenerator)(LXDBaseApi * api);
    
    NSInteger apiType = (api.requestType | api.responseType);
    
    if (apiType == (LXDRequestTypeJSON | LXDResponseTypeJSON)) {
        
        LXDManagerGenerator generator = ^AFHTTPSessionManager *(LXDBaseApi *api) {
            static AFHTTPSessionManager *manager;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                manager = [LXDRequest _commonRequestManager];
                manager.requestSerializer = [AFJSONRequestSerializer serializer];
                manager.responseSerializer = [AFJSONResponseSerializer serializer];
                manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects: @"application/json", @"text/html", @"multipart/form-data", @"image/png", nil];
                manager.requestSerializer.timeoutInterval = 30;
            });
            return manager;
        };
        return generator(api);
        
    } else if (apiType == (LXDRequestTypeJSON | LXDResponseTypeHTTP)) {
        
        LXDManagerGenerator generator = ^AFHTTPSessionManager *(LXDBaseApi *api) {
            static AFHTTPSessionManager *manager;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                manager = [LXDRequest _commonRequestManager];
                manager.requestSerializer = [AFJSONRequestSerializer serializer];
                manager.responseSerializer = [AFHTTPResponseSerializer serializer];
                manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects: @"application/json", @"text/html", @"multipart/form-data", @"image/png", nil];
                manager.requestSerializer.timeoutInterval = 30;
            });
            return manager;
        };
        return generator(api);
        
    }  else if (apiType == (LXDRequestTypeHTTP | LXDResponseTypeJSON)) {
        
        LXDManagerGenerator generator = ^AFHTTPSessionManager *(LXDBaseApi *api) {
            static AFHTTPSessionManager *manager;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                manager = [LXDRequest _commonRequestManager];
                manager.requestSerializer = [AFHTTPRequestSerializer serializer];
                manager.responseSerializer = [AFJSONResponseSerializer serializer];
                manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects: @"application/json", @"text/html", @"multipart/form-data", @"image/png", nil];
                manager.requestSerializer.timeoutInterval = 30;
            });
            return manager;
        };
        return generator(api);
        
    } else if (apiType == (LXDRequestTypeHTTP | LXDResponseTypeHTTP)) {
        
        LXDManagerGenerator generator = ^AFHTTPSessionManager *(LXDBaseApi *api) {
            static AFHTTPSessionManager *manager;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                manager = [LXDRequest _commonRequestManager];
                manager.requestSerializer = [AFHTTPRequestSerializer serializer];
                manager.responseSerializer = [AFHTTPResponseSerializer serializer];
                manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects: @"application/json", @"text/html", @"multipart/form-data", @"image/png", nil];
                manager.requestSerializer.timeoutInterval = 30;
            });
            return manager;
        };
        return generator(api);
        
    }else {
        return nil;
    }
}


@end

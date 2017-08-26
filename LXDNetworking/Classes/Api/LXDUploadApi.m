//
//  LXDUploadApi.m
//  Pods
//
//  Created by linxinda on 2017/8/26.
//
//

#import "LXDUploadApi.h"


@interface LXDUploadFile ()

@property (nonatomic, copy) NSData *file;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *mimeType;
@property (nonatomic, copy) NSString *paramName;

@end


@implementation LXDUploadFile


+ (instancetype)uploadFileWithFile: (NSData *)file
                          fileName: (NSString *)fileName
                          mimeType: (NSString *)mimeType
                         paramName: (NSString *)paramName {
    LXDUploadFile *uploadFile = [LXDUploadFile new];
    uploadFile.paramName = paramName;
    uploadFile.mimeType = mimeType;
    uploadFile.fileName = fileName;
    uploadFile.file = file;
    return uploadFile;
}


@end


@implementation LXDUploadApi

- (NSArray<LXDUploadFile *> *)uploadFiles {
    return nil;
}

@end

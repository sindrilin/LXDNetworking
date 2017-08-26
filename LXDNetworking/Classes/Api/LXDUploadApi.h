//
//  LXDUploadApi.h
//  Pods
//
//  Created by linxinda on 2017/8/26.
//
//

#import "LXDBaseApi.h"


/*!
 *  @class  LXDUploadFile
 *  上传的文件
 */
@interface LXDUploadFile : NSObject

@property (nonatomic, readonly) NSData *file;
@property (nonatomic, readonly) NSString *fileName;
@property (nonatomic, readonly) NSString *mimeType;
@property (nonatomic, readonly) NSString *paramName;

/*!
 *  @method uploadFileWithFile:fileName:paramName:
 *  创建一个上传文件
 */
+ (instancetype)uploadFileWithFile: (NSData *)file
                          fileName: (NSString *)fileName
                          mimeType: (NSString *)mimeType
                         paramName: (NSString *)paramName;

@end


/*!
 *  @class  LXDUploadApi
 *  上传文件api
 */
@interface LXDUploadApi : LXDBaseApi

- (NSArray<LXDUploadFile *> *)uploadFiles;

@end

//
//  HttpClientFileModel.h
//  Collector
//
//  Created by pactera on 15/4/21.
//  Copyright (c) 2015年 panderman. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HttpClientFileProtocol

@required
+ (instancetype)fileModelWithFilePath:(NSString *)localFilePath;

+ (instancetype)fileModelWithFilePath:(NSString *)localFilePath requestFileName:(NSString *)requestFileName;

+ (instancetype)fileModelWithFileData:(NSData *)data fileName:(NSString *)fileName mimeType:(NSString *)mimeType;

+ (instancetype)fileModelWithFileData:(NSData *)data requestFileName:(NSString *)requestFileName fileName:(NSString *)fileName mimeType:(NSString *)mimeType;

@end

@interface HttpClientFileModel : NSObject <HttpClientFileProtocol>

@property (nonatomic,strong) NSData *fileData;
///请求服务器的参数，默认和fileName一致
@property (nonatomic,strong) NSString *requestFileName;
@property (nonatomic,strong) NSString *fileName;
@property (nonatomic,strong) NSString *mimeType;

@end

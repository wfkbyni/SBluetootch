//
//  HttpClientFileModel.m
//  Collector
//
//  Created by pactera on 15/4/21.
//  Copyright (c) 2015年 panderman. All rights reserved.
//

#import "HttpClientFileModel.h"
#import "NSStringExtension.h"

@implementation HttpClientFileModel

+ (instancetype)fileModelWithFilePath:(NSString *)localFilePath{
    return [self fileModelWithFilePath:localFilePath requestFileName:nil];
}

+ (instancetype)fileModelWithFilePath:(NSString *)localFilePath requestFileName:(NSString *)requestFileName{
    NSAssert([localFilePath length] != 0, @"请传入文件路径！");
    NSData *data = [NSData dataWithContentsOfFile:localFilePath];
    NSString *fileName = [localFilePath lastPathComponent];
    return [self fileModelWithFileData:data requestFileName:requestFileName fileName:fileName mimeType:[localFilePath mimeType]];
}

+ (instancetype)fileModelWithFileData:(NSData *)data fileName:(NSString *)fileName mimeType:(NSString *)mimeType{
    return [self fileModelWithFileData:data requestFileName:nil fileName:fileName mimeType:mimeType];
}

+ (instancetype)fileModelWithFileData:(NSData *)data requestFileName:(NSString *)requestFileName fileName:(NSString *)fileName mimeType:(NSString *)mimeType{
    NSAssert(data, @"文件内容不能为空！");
    NSAssert(fileName, @"文件名不能为空！");
    NSAssert(mimeType, @"mime type不能为空！");
    if(!requestFileName){
        requestFileName = fileName;
    }
    HttpClientFileModel *fileModel = [[HttpClientFileModel alloc] init];
    fileModel.fileData = data;
    fileModel.requestFileName = requestFileName;
    fileModel.fileName = fileName;
    fileModel.mimeType = mimeType;
    return fileModel;
}

@end

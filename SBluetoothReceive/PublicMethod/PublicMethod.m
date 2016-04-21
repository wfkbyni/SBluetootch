//
//  PublicMethod.m
//  SBluetoothReceive
//
//  Created by Mac on 15/12/3.
//  Copyright © 2015年 sych. All rights reserved.
//

#import "PublicMethod.h"

@implementation PublicMethod

+ (UserMessage *)getLoginUserMessage{
    
    NSString *userMessage = [[NSUserDefaults standardUserDefaults] valueForKey:LOGINUSERMESSAGE];
    
    if (userMessage != nil) {
        NSError *error;
        UserMessage *info = [[UserMessage alloc] initWithString:userMessage error:&error];
        
        return info;
    }
    
    return nil;
}

+ (BOOL)archiverData:(NSMutableArray *)archiverData withCacheName:(NSString *)name{
    
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    
    [archiver encodeObject:archiverData forKey:@"array"];
    
    [archiver finishEncoding];
    
    NSString *path = [FCFileManager pathForDocumentsDirectory];//[FCFileManager pathForDocumentsDirectoryWithPath:@"Data/"];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",path, name];
    
    BOOL success = [data writeToFile:filePath atomically:YES];
    
    if (success) {
        [SVProgressHUD showSuccessWithStatus:@"数据缓存成功!"];
    }
    
    return success;
}

// 解档数据
+ (NSArray *)unarchiverDataWithName:(NSString *)fileName{
    NSString *path = [FCFileManager pathForDocumentsDirectory];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",path, fileName];
    
    NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    
    NSArray *array = [unarchiver decodeObjectForKey:@"array"];
    
    return array;
}

/*
 * 缓存图片到本地
 */
+ (BOOL)saveImageToLocal:(UIImage *)uiImage withFileName:(NSString *)fileName{
    NSString *path = [FCFileManager pathForDocumentsDirectory];// [FCFileManager pathForDocumentsDirectoryWithPath:@"Data/"];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",path,fileName];
    
    // Write image to PNG
    BOOL isSuccess = [UIImagePNGRepresentation(uiImage) writeToFile:filePath atomically:YES];
    
    return isSuccess;
}

/**
 *  @brief 获取接收者用户
 *
 *  @return <#return value description#>
 */
+ (UserMessage *)getReceiveUserMessage{
    NSString *chatRecipientId = [[NSUserDefaults standardUserDefaults] valueForKey:ChatRecipientID];
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] valueForKey:ChatRecipient];
    
    NSString *value = [dic valueForKey:chatRecipientId];
    NSError *error = nil;
    UserMessage *message = [[UserMessage alloc] initWithString:value
                                                         error:&error];
    return message;
}

@end

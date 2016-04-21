//
//  PublicMethod.h
//  SBluetoothReceive
//
//  Created by Mac on 15/12/3.
//  Copyright © 2015年 sych. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UserMessage;
@interface PublicMethod : NSObject


/*
 * 缓存图片到本地
 */
+ (BOOL)saveImageToLocal:(UIImage *)uiImage withFileName:(NSString *)fileName;

// 归档数据
+ (BOOL)archiverData:(NSMutableArray *)archiverData withCacheName:(NSString *)name;

// 解档数据
+ (NSArray *)unarchiverDataWithName:(NSString *)fileName;

/**
 *  获取登录的用户信息
 *
 *  @return <#return value description#>
 */
+ (UserMessage *)getLoginUserMessage;


/**
 *  @brief 获取接收人的用户信息
 *
 *  @return <#return value description#>
 */
+ (UserMessage *)getReceiveUserMessage;

@end

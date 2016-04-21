//
//  NSDateExtension.h
//  短线精灵
//
//  Created by XIONGWANG on 15/6/29.
//  Copyright (c) 2015年 毛君. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (NSDateExtension)

///按照可行的格式返回时间字符串
- (NSString *)stringWithFormat:(NSString *)format;

@end

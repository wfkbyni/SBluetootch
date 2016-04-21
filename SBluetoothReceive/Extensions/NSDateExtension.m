//
//  NSDateExtension.m
//  短线精灵
//
//  Created by XIONGWANG on 15/6/29.
//  Copyright (c) 2015年 毛君. All rights reserved.
//

#import "NSDateExtension.h"

@implementation NSDate (NSDateExtension)

- (NSString *)stringWithFormat:(NSString *)format{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = format;
    return [formatter stringFromDate:self];
}

@end

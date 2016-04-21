//
//  NSArrayExtension.m
//  家师傅
//
//  Created by XIONGWANG on 15/6/23.
//  Copyright (c) 2015年 酬城网络. All rights reserved.
//

#import "NSArrayExtension.h"

@implementation NSArray (NSArrayExtension)

- (NSMutableArray *)filterUsingBlock:(BOOL (^)(id, NSUInteger))filterBlock{
    NSMutableArray *result = [NSMutableArray array];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (filterBlock(obj,idx)) {
            [result addObject:obj];
        }
    }];
    return result;
}

- (NSMutableArray *)createNewArrayUsingPropertyBlock:(id (^)(id, NSUInteger))createBlock{
    NSMutableArray *result = [NSMutableArray array];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id item = createBlock(obj,idx);
        if (item) {
            [result addObject:item];
        }
    }];
    return result;
}

- (NSMutableArray *)convertUsingBlock:(id (^)(id, NSUInteger))convertBlock{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id item = convertBlock(obj,idx);
        if (item == nil) {
            return;
        }
        [result addObject:item];
    }];
    return result;
}

@end

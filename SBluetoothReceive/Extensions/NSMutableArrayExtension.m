//
//  NSMutableArrayExtension.m
//  家师傅
//
//  Created by pactera on 15/6/8.
//  Copyright (c) 2015年 酬城网络. All rights reserved.
//

#import "NSMutableArrayExtension.h"

@implementation NSMutableArray (NSMutableArrayExtension)

- (void)removeLastWithCount:(NSUInteger)count{
    [self removeObjectsInRange:NSMakeRange(self.count - count, count)];
}

- (void)removeObjectUsingConditionBlock:(BOOL (^)(id item,NSUInteger idx))conditionBlock{
    __weak typeof(self) weakSelf = self;
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (conditionBlock(obj,idx)) {
            [weakSelf removeObject:obj];
        }
    }];
}

@end

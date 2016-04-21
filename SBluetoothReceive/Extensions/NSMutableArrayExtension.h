//
//  NSMutableArrayExtension.h
//  家师傅
//
//  Created by pactera on 15/6/8.
//  Copyright (c) 2015年 酬城网络. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (NSMutableArrayExtension)
///移除数组的最后几个项
- (void)removeLastWithCount:(NSUInteger)count;
///有条件的删除节点,如果block返回YES则删除节点
- (void)removeObjectUsingConditionBlock:(BOOL (^)(id item,NSUInteger idx))deleteConditionBlock;

@end

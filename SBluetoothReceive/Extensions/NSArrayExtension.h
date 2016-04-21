//
//  NSArrayExtension.h
//  家师傅
//
//  Created by XIONGWANG on 15/6/23.
//  Copyright (c) 2015年 酬城网络. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (NSArrayExtension)
///数组元素过滤
- (NSMutableArray *)filterUsingBlock:(BOOL (^)(id item,NSUInteger idx))filterBlock;
///从当前数组里派生一个由当前数组内节点的其他属性生成的新数组
- (NSMutableArray *)createNewArrayUsingPropertyBlock:(id (^)(id item,NSUInteger idx))createBlock;
///从一种数据类型的数组转换为另一种数据类型的数组
- (NSMutableArray *)convertUsingBlock:(id (^)(id item,NSUInteger idx))convertBlock;
@end

//
//  NSObjectExtension.h
//  智慧课堂
//
//  Created by XIONGWANG on 15/10/2.
//  Copyright © 2015年 熊猫人. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (NSObjectExtension)
/**
 *  获取当前类型的所有子类
 *
 *  @return 子类集合
 */
+ (NSArray<Class> *)allSubclasses;

@end

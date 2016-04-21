//
//  NSManagedObjectExtension.h
//  家师傅
//
//  Created by XIONGWANG on 15/6/23.
//  Copyright (c) 2015年 酬城网络. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (NSManagedObjectExtension)
///将当前对象转换为自定义对象
- (id)convertToCustomObject:(Class)objClass;

@end

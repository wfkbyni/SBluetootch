//
//  NSManagedObjectExtension.m
//  家师傅
//
//  Created by XIONGWANG on 15/6/23.
//  Copyright (c) 2015年 酬城网络. All rights reserved.
//

#import "NSManagedObjectExtension.h"
#import <objc/runtime.h>

@implementation NSManagedObject (NSManagedObjectExtension)

- (id)convertToCustomObject:(Class)objClass{
    id result = [objClass new];
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList(objClass, &count);
    for (NSUInteger i = 0; i < count; i++) {
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(properties[i])];
        id propertyValue = [self valueForKey:propertyName];
        if (propertyValue == nil) {
            continue;
        }
        [result setValue:propertyValue forKey:propertyName];
    }
    free(properties);
    return result;
}

@end

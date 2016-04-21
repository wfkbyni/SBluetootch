//
//  NSObjectExtension.m
//  智慧课堂
//
//  Created by XIONGWANG on 15/10/2.
//  Copyright © 2015年 熊猫人. All rights reserved.
//

#import "NSObjectExtension.h"

@implementation NSObject (NSObjectExtension)

+ (NSArray<Class> *)allSubclasses{
    Class *buffer = NULL;
    int count, size;
    do{
        count = objc_getClassList(NULL, 0);
        buffer = (Class *)realloc(buffer, count * sizeof(*buffer));
        size = objc_getClassList(buffer, count);
    } while(size != count);
    NSMutableArray<Class> *array = [NSMutableArray<Class> array];
    for(int i = 0; i < count; i++){
        Class candidate = buffer[i];
        Class superclass = candidate;
        while(superclass){
            if(superclass == self){
                [array addObject: candidate];
                break;
            }
            superclass = class_getSuperclass(superclass);
        }
    }
    free(buffer);
    return array;
}

@end

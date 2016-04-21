//
//  UIResponderExtension.m
//  家师傅
//
//  Created by pactera on 15/6/9.
//  Copyright (c) 2015年 酬城网络. All rights reserved.
//

#import "UIResponderExtension.h"

static __weak id currentFirstResponder;
@implementation UIResponder (UIResponderExtension)

+ (id)currentFirstResponder{
    currentFirstResponder = nil;
    [[UIApplication sharedApplication] sendAction:@selector(findFirstResponder:) to:nil from:nil forEvent:nil];
    return currentFirstResponder;
}

- (void)findFirstResponder:(id)sender{
    currentFirstResponder = self;
}

@end

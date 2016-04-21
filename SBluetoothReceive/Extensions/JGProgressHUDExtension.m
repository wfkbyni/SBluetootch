//
//  JGProgressHUDExtension.m
//  短线精灵
//
//  Created by XIONGWANG on 15/6/28.
//  Copyright (c) 2015年 毛君. All rights reserved.
//

#import "JGProgressHUDExtension.h"

@implementation JGProgressHUD (JGProgressHUDExtension)

- (void)show{
    UIView *view = [UIApplication sharedApplication].windows.firstObject;
    [self showInView:view];
}

@end

//
//  UIViewControllerExtension.h
//  家师傅
//
//  Created by pactera on 15/5/11.
//  Copyright (c) 2015年 酬城网络. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIViewController (UIViewControllerExtension)
- (void)hiddenNavBar:(BOOL)hidden;

- (void)afterViewDidLoad;

- (void)hiddenLeftButton;

- (void)hiddenRightButton;
///返回
- (void)popBack;

- (void)setStatusBarStyle:(UIStatusBarStyle)style;

@end

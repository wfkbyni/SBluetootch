//
//  UIAlertViewExtension.h
//  家师傅
//
//  Created by pactera on 15/5/21.
//  Copyright (c) 2015年 酬城网络. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^AlertViewClickBlock)(UIAlertView* alertView,NSInteger clickIndex);

@interface UIAlertView (UIAlertViewExtension)<UIAlertViewDelegate>

@property (nonatomic,copy) AlertViewClickBlock alertViewClickBlock;

+ (void)alertWithMessage:(NSString *)message clickBlock:(AlertViewClickBlock)clickBlock;

+ (void)alertWithTitle:(NSString *)title message:(NSString *)message clickBlock:(AlertViewClickBlock)clickBlock cancelButtonTitle:(NSString *)cancelButtonTitle;

+ (void)alertWithTitles:(NSString *)title message:(NSString *)message clickBlock:(AlertViewClickBlock)clickBlock cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

@end

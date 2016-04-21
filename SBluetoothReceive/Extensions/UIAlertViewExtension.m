//
//  UIAlertViewExtension.m
//  家师傅
//
//  Created by pactera on 15/5/21.
//  Copyright (c) 2015年 酬城网络. All rights reserved.
//

#import "UIAlertViewExtension.h"
#import <objc/runtime.h>
static const char * kAlertViewClickBlockKey;
@implementation UIAlertView (UIAlertViewExtension)

@dynamic alertViewClickBlock;

+ (void)load{
    Method old = class_getInstanceMethod([self class], NSSelectorFromString(@"dealloc")),
    new = class_getInstanceMethod([self class], @selector(deallocCustom));
    method_exchangeImplementations(old, new);
}

- (void)deallocCustom{
    self.alertViewClickBlock = nil;
    //DebugLog(@"alerview: %@ 已销毁",self);
    [self deallocCustom];
}

+ (void)alertWithMessage:(NSString *)message clickBlock:(AlertViewClickBlock)clickBlock{
    [self alertWithTitle:@"提示" message:message clickBlock:clickBlock cancelButtonTitle:@"确定"];
}

+ (void)alertWithTitle:(NSString *)title message:(NSString *)message clickBlock:(AlertViewClickBlock)clickBlock cancelButtonTitle:(NSString *)cancelButtonTitle{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles: nil];
    alert.delegate = alert;
    if (clickBlock) {
        alert.alertViewClickBlock = clickBlock;
    }
    [alert show];
}

+ (void)alertWithTitles:(NSString *)title message:(NSString *)message clickBlock:(AlertViewClickBlock)clickBlock cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles: nil];
    alert.delegate = alert;
    if (otherButtonTitles != nil) {
        [alert addButtonWithTitle:otherButtonTitles];
        va_list args;
        va_start(args, otherButtonTitles);
        NSString * title = nil;
        while((title = va_arg(args,NSString*))) {
            [alert addButtonWithTitle:title];
        }
        va_end(args);
    }
    
    if (clickBlock) {
        alert.alertViewClickBlock = clickBlock;
    }
    [alert show];
}

- (void)setAlertViewClickBlock:(AlertViewClickBlock)alertViewClickBlock{
    objc_setAssociatedObject(self, &kAlertViewClickBlockKey, alertViewClickBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (AlertViewClickBlock)alertViewClickBlock{
    return objc_getAssociatedObject(self, &kAlertViewClickBlockKey);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (!self.alertViewClickBlock) {
        return;
    }
    self.alertViewClickBlock(alertView,buttonIndex);
}

@end

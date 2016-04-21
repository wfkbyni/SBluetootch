//
//  UIActionSheetExtension.m
//  家师傅
//
//  Created by pactera on 15/5/21.
//  Copyright (c) 2015年 酬城网络. All rights reserved.
//

#import "UIActionSheetExtension.h"
#import <objc/runtime.h>

const static char *kActionSheetClickBlockKey;

@implementation UIActionSheet (UIActionSheetExtension)
@dynamic actionSheetClickBlock;

+ (void)actionSheetWithTitles:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle clickBlock:(ActionSheetClickBlock)clickBlock otherButtonTitles:(NSString *)otherButtonTitles, ...{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:title delegate:nil cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:nil];
    sheet.delegate = sheet;
    if (clickBlock) {
        sheet.actionSheetClickBlock = clickBlock;
    }
    if (otherButtonTitles != nil) {
        [sheet addButtonWithTitle:otherButtonTitles];
        va_list args;
        va_start(args, otherButtonTitles);
        NSString * title = nil;
        while((title = va_arg(args,NSString*))) {
            [sheet addButtonWithTitle:title];
        }
        va_end(args);
    }
    [sheet showInView:[UIApplication sharedApplication].keyWindow.subviews.lastObject];
}

+(void)load{
    Method old = class_getInstanceMethod([self class], NSSelectorFromString(@"dealloc")),
    new = class_getInstanceMethod([self class], @selector(deallocCustom));
    method_exchangeImplementations(old, new);
}

- (void)deallocCustom{
    self.actionSheetClickBlock = nil;
    [self deallocCustom];
}

- (void)setActionSheetClickBlock:(ActionSheetClickBlock)actionSheetClickBlock{
    objc_setAssociatedObject(self, &kActionSheetClickBlockKey, actionSheetClickBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (ActionSheetClickBlock)actionSheetClickBlock{
    return objc_getAssociatedObject(self, &kActionSheetClickBlockKey);
}

#pragma mark - delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (self.actionSheetClickBlock) {
        self.actionSheetClickBlock(actionSheet,buttonIndex);
    }
}

@end

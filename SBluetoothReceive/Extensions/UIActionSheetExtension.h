//
//  UIActionSheetExtension.h
//  家师傅
//
//  Created by pactera on 15/5/21.
//  Copyright (c) 2015年 酬城网络. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ActionSheetClickBlock)(UIActionSheet *actionSheet,NSInteger buttonIndex);

@interface UIActionSheet (UIActionSheetExtension)<UIActionSheetDelegate>

@property (nonatomic,copy) ActionSheetClickBlock actionSheetClickBlock;

+ (void)actionSheetWithTitles:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle
            clickBlock:(ActionSheetClickBlock)clickBlock
            otherButtonTitles:(NSString *)otherButtonTitles, ...;

@end

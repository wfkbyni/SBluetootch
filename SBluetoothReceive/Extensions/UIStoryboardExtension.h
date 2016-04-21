//
//  UIStoryboardExtension.h
//  家师傅
//
//  Created by pactera on 15/5/24.
//  Copyright (c) 2015年 酬城网络. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIStoryboard (UIStoryboardExtension)

+ (UIViewController *)initControllerWithStoryboardId:(NSString *)storyboardId storyboardName:(NSString *)storyboardName;

@end

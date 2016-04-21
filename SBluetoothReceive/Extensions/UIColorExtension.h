//
//  UIColorExtension.h
//  家师傅
//
//  Created by pactera on 15/5/11.
//  Copyright (c) 2015年 酬城网络. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (UIColorExtension)


// 类似 "#00FF00" (#RRGGBB).
+ (UIColor *)colorWithHexString:(NSString *)hexString;

+ (UIColor *)colorWithImage:(NSString *)imageNamed;

@end

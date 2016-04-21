//
//  UIColorExtension.m
//  家师傅
//
//  Created by pactera on 15/5/11.
//  Copyright (c) 2015年 酬城网络. All rights reserved.
//

#import "UIColorExtension.h"
#import "UIImageExtension.h"

@implementation UIColor (UIColorExtension)

+ (UIColor *)colorWithHexString:(NSString *)hexString {
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#" withString: @""] uppercaseString];
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:colorString];
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+ (UIColor *)colorWithImage:(NSString *)imageNamed{
    return [UIColor colorWithPatternImage:[UIImage imageWithName:imageNamed]];
}

@end

//
//  UIButtonExtension.m
//  家师傅
//
//  Created by pactera on 15/5/17.
//  Copyright (c) 2015年 酬城网络. All rights reserved.
//

#import "UIButtonExtension.h"

@implementation UIButton (UIButtonExtension)

- (void)setBackgroundColor:(UIColor *)color forState:(UIControlState)state radius:(CGFloat)radius{
    [self setBackgroundImage:[UIImage imageWithColor:color] forState:state];
    self.clipsToBounds = YES;
    
    self.layer.cornerRadius = radius;//half of the width
}

@end

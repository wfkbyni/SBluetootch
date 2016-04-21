//
//  UIButton+CornerRadiusBtn.m
//  SBluetoothReceive
//
//  Created by 舒永超 on 16/1/24.
//  Copyright © 2016年 sych. All rights reserved.
//

#import "UIButton+CornerRadiusBtn.h"

@implementation UIButton (CornerRadiusBtn)

- (void)setCornerRadius:(float)radius{
    
    UIImage *image = [UIImage imageWithColor:maincolor size:self.frame.size];
    [self setBackgroundImage:image forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.layer.cornerRadius = radius;
    self.layer.masksToBounds = YES;
}

- (void)setCornerRadius{
    [self setCornerRadius:10];
}

@end

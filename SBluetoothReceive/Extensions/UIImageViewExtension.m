//
//  UIImageViewExtension.m
//  家师傅
//
//  Created by pactera on 15/5/11.
//  Copyright (c) 2015年 酬城网络. All rights reserved.
//

#import "UIImageViewExtension.h"
#import "UIImageExtension.h"

@implementation UIImageView (UIImageViewExtension)

+ (instancetype)imageNamed:(NSString *)imageName{
    UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageWithName:imageName]];
    img.contentMode = UIViewContentModeCenter;
    return img;
}

@end

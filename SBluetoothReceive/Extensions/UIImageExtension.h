//
//  UIImageExtension.h
//  家师傅
//
//  Created by pactera on 15/5/11.
//  Copyright (c) 2015年 酬城网络. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (UIImageExtension)

/// 颜色创建图
+ (UIImage *)imageWithColor:(UIColor *)color;
/// 无缓存获取图片
+ (UIImage *)imageWithName:(NSString *)name;
/// 等比创建缩略图
- (UIImage *)thumbnail:(CGSize)targetSize;

@end

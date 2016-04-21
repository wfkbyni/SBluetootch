//
//  UIViewExtension.h
//  家师傅
//
//  Created by pactera on 15/5/19.
//  Copyright (c) 2015年 酬城网络. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TargetObject : NSObject

+ (instancetype)targetWithTarget:(id)target action:(SEL)action;

//要执行的事件
@property (nonatomic) SEL action;
//执行事件的目标
@property (nonatomic,weak) id target;

@end

@interface UIView (UIViewExtension)
///事件链
@property (nonatomic,strong) NSMutableArray *targetObjects;
///为当前view添加点击事件
- (void)addCustomTarget:(id)target action:(SEL)action;
/**
 *  捕获当前view的截图
 *
 *  @return 截图
 */
- (UIImage *)captureViewByOutputImage;
/**
 *  移除所有layer
 */
- (void)removeAllLayers;
@end

//
//  UIViewExtension.m
//  家师傅
//
//  Created by pactera on 15/5/19.
//  Copyright (c) 2015年 酬城网络. All rights reserved.
//

#import "UIViewExtension.h"
#import <objc/runtime.h>

@implementation TargetObject
+ (instancetype)targetWithTarget:(id)target action:(SEL)action{
    TargetObject *result = [TargetObject new];
    result.target = target;
    result.action = action;
    return result;
}
@end

const char *kTargetObjectsKey;
@implementation UIView (UIViewExtension)
@dynamic targetObjects;

- (void)addCustomTarget:(id)target action:(SEL)action{
    if (!self.targetObjects) {
        self.targetObjects = [NSMutableArray array];
    }
    TargetObject *result = [TargetObject targetWithTarget:target action:action];
    [self.targetObjects addObject:result];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    if (!self.targetObjects) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    //执行事件列表
    [self.targetObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        TargetObject *targetObject = obj;
        [weakSelf invokeAction:targetObject];
    }];
}

- (void)invokeAction:(TargetObject *)targetObject{
    //获取方法的实现
    IMP imp = [targetObject.target methodForSelector:targetObject.action];
    //转换为对应的参数类型方法
    void (*func)(id,SEL,id) = (void*)imp;
    //执行
    func(targetObject.target,targetObject.action,self);
}

- (UIImage *)captureViewByOutputImage{
    // 1.开启上下文，第二个参数是是否不透明（opaque）NO为透明，这样可以防止占据额外空间（例如圆形图会出现方框），第三个为伸缩比例，0.0为不伸缩。
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0.0);
    // 2.将view的layer渲染到上下文
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    // 3.取出图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    // 4.结束上下文
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - getter and setter
- (void)setTargetObjects:(NSMutableArray *)targetObjects{
    objc_setAssociatedObject(self, &kTargetObjectsKey, targetObjects, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)targetObjects{
    return objc_getAssociatedObject(self, &kTargetObjectsKey);
}

//+(void)load{
//    Method old = class_getInstanceMethod([self class], @selector(touchesBegan:withEvent:)),
//    new = class_getInstanceMethod([self class], @selector(deallocCustom));
//    method_exchangeImplementations(old, new);
//}
//
//- (void)deallocCustom{
//    self.clickHelper = nil;
//    [self deallocCustom];
//}

- (void)removeAllLayers{
    for (CALayer *layer in [self.layer.sublayers copy]) {
        [layer removeFromSuperlayer];
    }
}

@end

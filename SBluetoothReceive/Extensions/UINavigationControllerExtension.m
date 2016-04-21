//
//  UINavigationControllerExtension.m
//  家师傅
//
//  Created by pactera on 15/6/6.
//  Copyright (c) 2015年 酬城网络. All rights reserved.
//

#import "UINavigationControllerExtension.h"
#import <objc/runtime.h>

const char *willPopViewControllerBlcokKey,*willPushViewControllerBlcokKey;
@implementation UINavigationController (UINavigationControllerExtension)
@dynamic willPopViewControllerBlcok;
@dynamic willPushViewControllerBlcok;

+ (void)load{
    [super load];
    //popViewControllerAnimated:
    Method old = class_getInstanceMethod([self class], @selector(popViewControllerAnimated:)),
    new = class_getInstanceMethod([self class], @selector(beforePopViewController:));
    method_exchangeImplementations(old, new);
    //setViewControllers:animated:
    old = class_getInstanceMethod([self class], @selector(setViewControllers:animated:));
    new = class_getInstanceMethod([self class], @selector(beforeSetViewControllers:animated:));
    method_exchangeImplementations(old, new);
    //beforePushViewController
    old = class_getInstanceMethod([self class], @selector(pushViewController:animated:));
    new = class_getInstanceMethod([self class], @selector(beforePushViewController:animated:));
    method_exchangeImplementations(old, new);
}

- (UIViewController *)beforePopViewController:(BOOL)animated{
    self.willPushViewControllerBlcok = nil;
    if (self.willPopViewControllerBlcok) {
        self.willPopViewControllerBlcok(self.childViewControllers.lastObject);
    }
    return [self beforePopViewController:animated];
}

- (void)beforeSetViewControllers:(NSArray *)viewControllers animated:(BOOL)animated{
    self.willPushViewControllerBlcok = nil;
    if (self.willPopViewControllerBlcok) {
        __weak typeof(self) weakSelf = self;
        NSMutableArray *childControllers = [self.childViewControllers mutableCopy];
        //筛选出减少的控制器
        [childControllers removeObjectsInArray:viewControllers];
        [childControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            weakSelf.willPopViewControllerBlcok(obj);
        }];
    }
    [self beforeSetViewControllers:viewControllers animated:animated];
}

- (void)beforePushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    self.willPopViewControllerBlcok = nil;
    if (self.willPushViewControllerBlcok) {
        self.willPushViewControllerBlcok(viewController);
    }
    [self beforePushViewController:viewController animated:YES];
}

#pragma mark - setter and getter

- (void)setWillPopViewControllerBlcok:(WillPopViewControllerBlcok)willPopViewControllerBlcok{
    objc_setAssociatedObject(self, &willPopViewControllerBlcokKey, willPopViewControllerBlcok, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (WillPopViewControllerBlcok)willPopViewControllerBlcok{
    return objc_getAssociatedObject(self, &willPopViewControllerBlcokKey);
}

- (void)setWillPushViewControllerBlcok:(WillPushViewControllerBlcok)willPushViewControllerBlcok{
    objc_setAssociatedObject(self, &willPushViewControllerBlcokKey, willPushViewControllerBlcok, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (WillPushViewControllerBlcok)willPushViewControllerBlcok{
    return objc_getAssociatedObject(self, &willPushViewControllerBlcokKey);
}
@end

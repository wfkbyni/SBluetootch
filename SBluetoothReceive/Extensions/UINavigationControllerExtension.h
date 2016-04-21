//
//  UINavigationControllerExtension.h
//  家师傅
//
//  Created by pactera on 15/6/6.
//  Copyright (c) 2015年 酬城网络. All rights reserved.
//

#import <UIKit/UIKit.h>
///当在执行pop之前的事件
typedef void(^WillPopViewControllerBlcok)(UIViewController *willPopController);
///当在执行push之前的事件
typedef void(^WillPushViewControllerBlcok)(UIViewController *willPushController);

@interface UINavigationController (UINavigationControllerExtension)

///在nav的pop事件之前执行的操作
@property (nonatomic,copy) WillPopViewControllerBlcok willPopViewControllerBlcok;

///在nav的push事件之前执行的操作
@property (nonatomic,copy) WillPushViewControllerBlcok willPushViewControllerBlcok;

@end

//
//  UIViewControllerExtension.m
//  家师傅
//
//  Created by pactera on 15/5/11.
//  Copyright (c) 2015年 酬城网络. All rights reserved.
//

#import "UIViewControllerExtension.h"

@implementation UIViewController (UIViewControllerExtension)

- (void)hiddenNavBar:(BOOL)hidden{
    if (self.navigationController) {
        self.navigationController.navigationBarHidden = hidden;
        [self.navigationController setNavigationBarHidden:hidden animated:YES];
    }
}
///状态栏颜色
- (void)setStatusBarStyle:(UIStatusBarStyle)style{
    [UIApplication sharedApplication].statusBarStyle = style;
}
///初始化一些参数
- (void)afterViewDidLoad{
    UITapGestureRecognizer *tapHideKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapHideKeyboard.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapHideKeyboard];
//    UINavigationController *navController = self.navigationController;
//    if (navController) {
//        navController.navigationBar.barTintColor = kBarRedColor;
//        navController.navigationBar.translucent = NO;
//        navController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
//    }
//    if (navController && navController.childViewControllers.count > 1) {
//        UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 13, 23)];
//        [backBtn setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:
//         UIControlStateNormal];
//        [backBtn addTarget:self action:@selector(popBack) forControlEvents:UIControlEventTouchUpInside];
//        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
//        self.navigationItem.leftBarButtonItem = backItem;
//    }
    [self hiddenNavBar:NO];
}
///隐藏左侧按钮
- (void)hiddenLeftButton{
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.hidesBackButton = YES;
    if (!self.parentViewController) {
        return;
    }
    self.parentViewController.navigationItem.leftBarButtonItem = nil;
    self.parentViewController.navigationItem.hidesBackButton = YES;
}
///隐藏右侧按钮
- (void)hiddenRightButton{
    self.navigationItem.rightBarButtonItem = nil;
    if (!self.parentViewController) {
        return;
    }
    self.parentViewController.navigationItem.rightBarButtonItem = nil;
}
///返回
- (void)popBack{
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
///隐藏键盘
- (void)hideKeyboard{
    [self.view endEditing:YES];
}

@end

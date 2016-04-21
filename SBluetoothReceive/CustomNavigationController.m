//
//  CustomNavigationController.m
//  SBluetoothReceive
//
//  Created by 舒永超 on 15/12/12.
//  Copyright © 2015年 sych. All rights reserved.
//

#import "CustomNavigationController.h"

@interface CustomNavigationController ()

@end

@implementation CustomNavigationController

-(instancetype)initWithRootViewController:(UIViewController *)rootViewController{
    
    [self customNavigationBar];
    
    return [super initWithRootViewController:rootViewController];
}


- (void)customNavigationBar{
    UINavigationBar *navigationBar = [UINavigationBar appearance];
    UIColor *color = maincolor;
    [navigationBar setBarTintColor:color];
    
    //UIImage* image = [UIImage imageNamed:@"bar_64.png"];
    //[navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
    NSDictionary *textAttributes = nil;
    
    UIColor* fontColor = [UIColor whiteColor];

    textAttributes = @{
                       NSFontAttributeName: [UIFont boldSystemFontOfSize:16],
                       NSForegroundColorAttributeName: fontColor,
                       };
    
    [navigationBar setTitleTextAttributes:textAttributes];
}

@end

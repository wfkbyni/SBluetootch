//
//  BaseController.m
//  SBluetoothReceive
//
//  Created by 舒永超 on 15/12/16.
//  Copyright © 2015年 sych. All rights reserved.
//

#import "BaseController.h"

@interface BaseController ()

@end

@implementation BaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor colorWithRed:227.0f / 255.0f green:233.0f / 255.0f blue:234.0f / 255.0f alpha:1]];
    
    // 定义nav的leftBarButtonItem
    UIImage* backImage = [UIImage imageNamed:@"back"];
    UIButton* backButton= [[UIButton alloc] init];
    [backButton setBackgroundImage:backImage forState:UIControlStateNormal];
    backButton.titleLabel.font=[UIFont systemFontOfSize:13];
    [backButton sizeToFit];
    [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
}

- (void)backAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

@end

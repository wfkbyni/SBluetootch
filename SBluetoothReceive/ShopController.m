//
//  ShowController.m
//  SBluetoothReceive
//
//  Created by 舒永超 on 16/1/24.
//  Copyright © 2016年 sych. All rights reserved.
//

#import "ShopController.h"

@interface ShopController ()

@end

@implementation ShopController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"妄想商城";
    
    NSInteger value1 = [[[NSUserDefaults standardUserDefaults] valueForKey:@"cache_value1"] intValue];
    NSInteger value2 = [[[NSUserDefaults standardUserDefaults] valueForKey:@"cache_value2"] intValue];
    self.valueTextField.text = [NSString stringWithFormat:@"%@",@(value1)];
    self.afterTimeTextField.text = [NSString stringWithFormat:@"%@",@(value2)];
    
    [[self.btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        NSInteger value1 = [self.valueTextField.text intValue];
        NSInteger value2 = [self.afterTimeTextField.text intValue];
        
        [[NSUserDefaults standardUserDefaults] setValue:@(value1) forKey:@"cache_value1"];
        [[NSUserDefaults standardUserDefaults] setValue:@(value2) forKey:@"cache_value2"];
        
        [self.valueTextField resignFirstResponder];
        [self.afterTimeTextField resignFirstResponder];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

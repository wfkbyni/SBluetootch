//
//  LoginController.h
//  SBluetoothReceive
//
//  Created by 舒永超 on 15/12/2.
//  Copyright © 2015年 sych. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginController : BaseController

@property (weak, nonatomic) IBOutlet UITextField *loginName;
@property (weak, nonatomic) IBOutlet UITextField *password;

@property (weak, nonatomic) IBOutlet UIButton *findPwdBtn;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *displayPwdBtn;



@end

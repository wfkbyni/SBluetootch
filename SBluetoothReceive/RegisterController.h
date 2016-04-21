//
//  RegisterController.h
//  SBluetoothReceive
//
//  Created by 舒永超 on 15/12/2.
//  Copyright © 2015年 sych. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterController : BaseController

@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;
@property (weak, nonatomic) IBOutlet UITextField *smsCodeTextField;

@property (weak, nonatomic) IBOutlet UIButton *smsBtn;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet UIButton *displayPwdBtn;

@end

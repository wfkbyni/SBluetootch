//
//  UpdatePwdController.h
//  SBluetoothReceive
//
//  Created by Mac on 15/12/11.
//  Copyright © 2015年 sych. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UpdatePwdController : BaseController

@property (weak, nonatomic) IBOutlet UITextField *oldPwd;
@property (weak, nonatomic) IBOutlet UITextField *pwd1;
@property (weak, nonatomic) IBOutlet UITextField *pwd2;
@property (weak, nonatomic) IBOutlet UITextField *smscode;
@property (weak, nonatomic) IBOutlet UIButton *displayPwd;


@property (weak, nonatomic) IBOutlet UIButton *smsBtn;
@property (weak, nonatomic) IBOutlet UIButton *updatePwdBtn;
@end

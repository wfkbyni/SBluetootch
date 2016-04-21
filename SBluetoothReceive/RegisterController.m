//
//  RegisterController.m
//  SBluetoothReceive
//
//  Created by Mac on 15/12/2.
//  Copyright © 2015年 sych. All rights reserved.
//

#import "RegisterController.h"

#import "UpdateInfoController.h"
#import "NSStringExtension.h"

@interface RegisterController ()
{
    int countTime;
    
    // 是否终止执行
    BOOL isStopExecute;
    
    // 请求方法名
    NSString *requestMethodName;
}

@end

@implementation RegisterController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self viewWithStyle];
    
    [self judgeMethod];
    
    @weakify(self)
    RACSignal *validUserNameSignal = [self.phoneTextField.rac_textSignal map:^id(NSString *value) {
        return @([value isPhone]);
    }];
    
    RACSignal *validPwdSignal = [self.pwdTextField.rac_textSignal map:^id(NSString *value) {
        return @(value.length >= 6);
    }];
    
    RACSignal *validSmsSignal = [self.smsCodeTextField.rac_textSignal map:^id(NSString *value) {
        return @(value.length == 6);
    }];
    
    RACSignal *loginSignal = [RACSignal combineLatest:@[validUserNameSignal, validPwdSignal, validSmsSignal]
                                               reduce:^id(NSNumber *loginValue,NSNumber *pwdValue, NSNumber *smsValue){
                                                   
        return @([loginValue boolValue] && [pwdValue boolValue] && [smsValue boolValue]);
    }];
    
    [loginSignal subscribeNext:^(NSNumber *loginStatus) {
        @strongify(self)
        self.registerBtn.enabled = [loginStatus boolValue];
    }];
    
    [[self.smsBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        NSString *phone = self.phoneTextField.text;
        if (![phone isPhone]) {
            [SVProgressHUD showErrorWithStatus:@"您输入的手机号码不正确！"];
            return;
        }
        
        @strongify(self)
        countTime = 60;
        self.smsBtn.enabled = NO;
        [self timeCount];
        
        [self getSmsCode];
    }];
    
    [[self.registerBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self)
        [self registerAction];
    }];
    
    [[self.displayPwdBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        self.pwdTextField.secureTextEntry = !self.pwdTextField.secureTextEntry;
        if (self.pwdTextField.secureTextEntry) {
            [self.displayPwdBtn setImage:[UIImage imageNamed:@"icon_blank"] forState:UIControlStateNormal];
        }else{
            [self.displayPwdBtn setImage:[UIImage imageNamed:@"icon_display"] forState:UIControlStateNormal];
        }
    }];
}

- (void)viewWithStyle{
    [self.smsBtn setCornerRadius:12];
    [self.registerBtn setCornerRadius:5];
}


- (void)judgeMethod{
    if ([self.title isEqualToString:@"注册"]) {
        requestMethodName = LoginWithRegiste;
    }else if([self.title isEqualToString:@"找回密码"]){
        requestMethodName = LoginWithFindBackPwd;
    }
    
    [self.registerBtn setTitle:self.title forState:UIControlStateNormal];
}

/**
 *  @brief 获取短信验证码倒计时
 */
- (void)timeCount{
    
    if (isStopExecute) {
        countTime = 60;
        [self settingCount:countTime];
        self.smsBtn.enabled = YES;
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self->countTime --;
        
        if (self->countTime > 0) {
            weakSelf.smsBtn.enabled = NO;
            [self timeCount];
            
        }else{
            self.smsBtn.enabled = YES;
            self->countTime = 0;
        }
        [weakSelf settingCount:self->countTime];
        
    });
}

- (void)settingCount:(int)count{
    if (count == 0) {
        [self.smsBtn setTitle:[NSString stringWithFormat:@"获取验证码"] forState:UIControlStateNormal];
    }else{
        [self.smsBtn setTitle:[NSString stringWithFormat:@"获取验证码(%d)",count] forState:UIControlStateNormal];
    }
}

/**
 *  @brief 注册功能
 */
- (void)registerAction{
    
    NSString *phone = self.phoneTextField.text;
    NSString *pwd = self.pwdTextField.text;
    NSString *smsCode = self.smsCodeTextField.text;
    
    NSDictionary *param = @{@"Phone":phone,
                            @"Pwd":pwd,
                            @"SmsCode":smsCode};

    
    __weak typeof(self) weakSelf = self;
    [[HttpClientHelper sharedInstance] post:requestMethodName resultType:[BaseResponseModel class] parameters:param success:^(id result) {
        
        BaseResponseModel *model = result;
        
        if (model.Success) {
            
            if ([self.title isEqualToString:@"找回密码"]) {
                [SVProgressHUD showSuccessWithStatus:@"密码成功找回"];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                });
            }else{
                UserMessage *userMessage = [[UserMessage alloc] init];
                userMessage.AccountId = model.Message;
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setValue:[userMessage toJSONString] forKey:LOGINUSERMESSAGE];
                [defaults synchronize];
                
                UpdateInfoController *controller = [[UpdateInfoController alloc] init];
                [weakSelf.navigationController pushViewController:controller animated:YES];
            }
            
        }else{
            [SVProgressHUD showErrorWithStatus:model.Message];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    } showLoading:YES];
}

/**
 *  @brief 获取短信验证码
 */
- (void)getSmsCode{
    
    NSString *phone = self.phoneTextField.text;
    
    NSDictionary *param = @{@"Phone":phone};
    
    [[HttpClientHelper sharedInstance] post:LoginWithSmsCode resultType:[BaseResponseModel class] parameters:param success:^(id result) {
        
        BaseResponseModel *model = result;
        if (model.Success) {
            [SVProgressHUD showSuccessWithStatus:@"验证码发送成功，请注意查看"];
        }else{
            self->isStopExecute = YES;
            [SVProgressHUD showErrorWithStatus:model.Message];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    } showLoading:YES];
}

@end

//
//  UpdatePwdController.m
//  SBluetoothReceive
//
//  Created by Mac on 15/12/11.
//  Copyright © 2015年 sych. All rights reserved.
//

#import "UpdatePwdController.h"

@interface UpdatePwdController ()
{
    int countTime;
    BOOL isStopExecute;
}
@end

@implementation UpdatePwdController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"修改密码";
    
    [self viewWithStyle];
    
    RACSignal *valid = [RACSignal combineLatest:@[self.oldPwd.rac_textSignal,self.pwd1.rac_textSignal,self.pwd2.rac_textSignal,self.smscode.rac_textSignal]
                                         reduce:^id(NSString *oldPwd,NSString *pwd1, NSString *pwd2, NSString *smsCode){
                                             return @(oldPwd.length >= 6 && [pwd1 isEqualToString:pwd2] && pwd1.length >= 6 && smsCode.length == 6);
    }];
    
    RAC(self.updatePwdBtn, enabled) = valid;
    
    @weakify(self)
    [[self.updatePwdBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self)
        [self updatePwdAction];
    }];
    
    [[self.smsBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
       @strongify(self)
        [self smsCodeAction];
    }];
    
    [[self.displayPwd rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        self.oldPwd.secureTextEntry = !self.oldPwd.secureTextEntry;
        self.pwd1.secureTextEntry = self.oldPwd.secureTextEntry;
        self.pwd2.secureTextEntry = self.oldPwd.secureTextEntry;
        if (self.oldPwd.secureTextEntry) {
            [self.displayPwd setImage:[UIImage imageNamed:@"icon_blank"] forState:UIControlStateNormal];
        }else{
            [self.displayPwd setImage:[UIImage imageNamed:@"icon_display"] forState:UIControlStateNormal];
        }
    }];
}

- (void)viewWithStyle{
    
    [self.smsBtn setCornerRadius:12];
    [self.updatePwdBtn setCornerRadius:5];
}

- (void)updatePwdAction{
    NSDictionary *param = @{@"AccountId":[PublicMethod getLoginUserMessage].AccountId,
                            @"OrignalPwd":self.oldPwd.text,
                            @"Pwd":self.pwd1.text,
                            @"SmsCode":self.smscode.text};
    
    @weakify(self)
    [[HttpClientHelper sharedInstance] post:LoginWithUpdatePwd resultType:[BaseResponseModel class] parameters:param success:^(BaseResponseModel *result) {
        
        @strongify(self)
        if (result.Success) {
            [SVProgressHUD showSuccessWithStatus:@"密码修改成功!"];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [SVProgressHUD showErrorWithStatus:result.Message];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    } showLoading:YES];
}

- (void)timeCount{
    
    if (isStopExecute) {
        countTime = 60;
        [self settingCount:countTime];
        self.smsBtn.enabled = YES;
        return;
    }
    
    @weakify(self)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self)
        countTime --;
        
        if (countTime > 0) {
            self.smsBtn.enabled = NO;
            [self timeCount];
            
        }else{
            self.smsBtn.enabled = YES;
            countTime = 10;
        }
        [self settingCount:countTime];
        
    });
}

- (void)settingCount:(int)count{
    [self.smsBtn setTitle:[NSString stringWithFormat:@"获取验证码(%d)",count] forState:UIControlStateNormal];
}

- (void)smsCodeAction{
    countTime = 60;
    self.smsBtn.enabled = NO;
    [self timeCount];
    
    [self getSmsCode];
}

- (void)getSmsCode{
    
    NSString *phone = [PublicMethod getLoginUserMessage].Phone;
    
    NSDictionary *param = @{@"Phone":phone};
    
    [[HttpClientHelper sharedInstance] post:LoginWithSmsCode resultType:[BaseResponseModel class] parameters:param success:^(id result) {
        BaseResponseModel *model = result;
        if (model.Success) {
            
        }else{
            isStopExecute = YES;
            [SVProgressHUD showErrorWithStatus:model.Message];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    } showLoading:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

//
//  LoginController.m
//  SBluetoothReceive
//
//  Created by 舒永超 on 15/12/2.
//  Copyright © 2015年 sych. All rights reserved.
//

#import "LoginController.h"

#import "AppDelegate.h"

#import "RegisterController.h"
#import "UpdateInfoController.h"

#import "NSStringExtension.h"
#import "MainViewController.h"

@interface LoginController ()

@end

@implementation LoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"登录";
    
    self.navigationItem.leftBarButtonItem = nil;
    [self viewWithStyle];
    
    UserMessage *userMessage = [PublicMethod getLoginUserMessage];
    
    if (userMessage != nil) {
        self.loginName.text = userMessage.Phone;
    }
    
    RACSignal *validUserNameSignal = [self.loginName.rac_textSignal map:^id(NSString *value) {
        return @([value isPhone]);
    }];
    
    RACSignal *validPwdSignal = [self.password.rac_textSignal map:^id(NSString *value) {
        return @(value.length >= 6);
    }];
    
    RACSignal *loginSignal = [RACSignal combineLatest:@[validUserNameSignal, validPwdSignal] reduce:^id(NSNumber *loginValue,NSNumber *pwdValue){
        return @([loginValue boolValue] && [pwdValue boolValue]);
    }];

    @weakify(self)
    [loginSignal subscribeNext:^(NSNumber *loginStatus) {
        @strongify(self)
        self.loginBtn.enabled = [loginStatus boolValue];
    }];
    
    [[self.loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self)
        [self loginAction];
    }];
    
    [[self.registerBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        UIViewController *controller = [[RegisterController alloc] init];
        controller.title = @"注册";
        [self.navigationController pushViewController:controller animated:YES];
    }];
    
    [[self.findPwdBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        UIViewController *controller = [[RegisterController alloc] init];
        controller.title = @"找回密码";
        [self.navigationController pushViewController:controller animated:YES];
    }];
    
    [[self.displayPwdBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        self.password.secureTextEntry = !self.password.secureTextEntry;
        if (self.password.secureTextEntry) {
            [self.displayPwdBtn setImage:[UIImage imageNamed:@"icon_blank"] forState:UIControlStateNormal];
        }else{
            [self.displayPwdBtn setImage:[UIImage imageNamed:@"icon_display"] forState:UIControlStateNormal];
        }
    }];
}

- (void)viewWithStyle{
    
    [self.findPwdBtn setTitleColor:maincolor forState:UIControlStateNormal];
    [self.registerBtn setTitleColor:maincolor forState:UIControlStateNormal];
    
    [self.loginBtn setCornerRadius:5];
}

/**
 *  @brief 登录功能
 */
- (void)loginAction{
    
    NSString *loginName = self.loginName.text;
    NSString *password = self.password.text;
    
    NSDictionary *param = @{@"Phone":loginName,@"Pwd":password};
    
    __weak typeof(self) weakSelf = self;
    [[HttpClientHelper sharedInstance] post:LoginWithLogin resultType:[UserMessage class] parameters:param success:^(id result) {
        
        UserMessage *userMessage = result;
        
        if (userMessage.Success) {
            
            [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:userMessage.Phone password:userMessage.AccountId completion:^(NSDictionary *loginInfo, EMError *error) {
                NSLog(@"%@",error);
                if (!error && loginInfo) {
                    NSLog(@"登陆成功");
                    NSLog(@"%@",loginInfo);
                    
                    //设置是否自动登录
                    [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:YES];
                    //发送自动登陆状态通知
                    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@YES];
                    
                    //获取数据库中数据
                    [[EaseMob sharedInstance].chatManager loadDataFromDatabase];
                    
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setValue:[userMessage toJSONString] forKey:LOGINUSERMESSAGE];
                    [defaults synchronize];
                    
                    if (userMessage.Sex == nil) {
                        UpdateInfoController *controller = [[UpdateInfoController alloc] init];
                        [weakSelf.navigationController pushViewController:controller animated:YES];
                    }else{
                        
                        MainViewController *controller = [[MainViewController alloc] init];
                        UIApplication *application = [UIApplication sharedApplication];
                        UIWindow *window = application.windows.firstObject;
                        
                        CustomNavigationController *nav = [[CustomNavigationController alloc] initWithRootViewController:controller];
                        
                        [window setRootViewController:nav];
                        
                        [window makeKeyAndVisible];
                    }
                }
            } onQueue:nil];
            
        }else{
            [SVProgressHUD showErrorWithStatus:userMessage.Message];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    } showLoading:YES];
}
@end

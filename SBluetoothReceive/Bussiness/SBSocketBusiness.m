//
//  SBSocketBusiness.m
//  SBluetoothReceive
//
//  Created by rrkd on 15/12/17.
//  Copyright © 2015年 sych. All rights reserved.
//

#import "SBSocketBusiness.h"

#import "MessageController.h"
#import "NSObjectExtension.h"
#import "NSArrayExtension.h"

@interface SBSocketBusiness ()

@property (nonatomic,strong,readonly) NSArray<SBSocketBusiness *> *allSubclasses;

@end

@implementation SBSocketBusiness

static NSMutableDictionary<NSString *,SBSocketBusiness *> *_businessModules;

- (void)addModuleWithCommand:(SocketCommandEnum)command mode:(SBSocketBusiness *)mode{
    NSString *key = [NSString stringWithFormat:@"%d",(int)command];
    _businessModules[key] = mode;
}

- (SBSocketBusiness *)getModuleWithCommand:(SocketCommandEnum)command{
    NSString *key = [NSString stringWithFormat:@"%d",(int)command];
    return [_businessModules objectForKey:key];
}

- (void)requestFriendInfo:(successResultBlock)successBlock{
    NSDictionary *param = @{@"FriendId":_model.sendUserId,
                            @"AccountId":[PublicMethod getLoginUserMessage].AccountId};
    [[HttpClientHelper sharedInstance] post:FriendsWithGetFriendInfo resultType:[UserMessage class] parameters:param success:successBlock failure:nil showLoading:NO];
}

- (void)requestFriendInfo:(NSString *)alertMsg
               alertBlock:(SocketCommandEnum (^)(UIAlertView *alertView, NSInteger clickIndex))alertBlock{
    [self requestFriendInfo:^(UserMessage *result) {
        if (!result.Success) {
            [SVProgressHUD showErrorWithStatus:result.Message];
            return;
        }
        NSString *message = [NSString stringWithFormat:alertMsg,result.NickName];
        [UIAlertView alertWithTitles:@"提示" message:message clickBlock:^(UIAlertView *alertView, NSInteger clickIndex) {
            
            SocketCommandEnum value = alertBlock(alertView,clickIndex);
            if (value == 0) {
                return;
            }
            [appDelegate connectionSocketAndSendData:value receiveUserId:_model.sendUserId data:@""];
            
        } cancelButtonTitle:@"拒绝" otherButtonTitles:@"同意", nil];
    }];
}

- (void)registerAllCommand{
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        _businessModules = [NSMutableDictionary<NSString *,SBSocketBusiness *> dictionary];
        NSArray<Class> *classes = [SBSocketBusiness allSubclasses];
        for (Class cls in classes) {
            SBSocketBusiness *bll = [cls new];
            [bll createCanExecuteCommand];
        }
    });
}

- (void)createCanExecuteCommand{
    
}

- (void)executeWithModel:(SocketPacketModel *)model{
    if (![model isValidData]) {
        DebugLog(@"----------------解析数据包错误---------------------");
        return;
    }
    DebugLog(@"收到消息：%@",model);
    //错误
    if (model.command == SocketCommandError) {
        SocketErrorCommandEnum error = model.data.integerValue;
        //...处理错误
        if (error == SocketCommandReceiveUserDisConnect) {
            [SVProgressHUD showErrorWithStatus:@"对方不在线，不能添加好友!"];
        }else if(error == SocketCommandReceiveUserMachineDisConnect){
            [SVProgressHUD showErrorWithStatus:@"当联机过程中任何一方设备断开时需发送此命令给另一方，并同时结束联机过程，然后调用HTTP文档【断开联机】接口"];
        }
        return;
    }
    SBSocketBusiness *bll = [self getModuleWithCommand:model.command];
    if (!bll) return;
    bll.model = model;
    [bll executeWithModel:model];
}

- (UINavigationController *)navigationController{
    return [AppDelegate findNavigationController];
}

- (void)pushController:(UIViewController *)controller{
    
    UINavigationController *nav = [AppDelegate findNavigationController];

    if (nav != nil) {
        [nav pushViewController:controller animated:YES];
    }
}

@end

//
//  SBUdpBusiness.m
//  SBluetoothReceive
//
//  Created by rrkd on 15/12/17.
//  Copyright © 2015年 sych. All rights reserved.
//

#import "SBUdpBusiness_bak.h"
#import "AppDelegate.h"

#import "MessageController.h"
#import "ChatViewController.h"

@interface SBUdpBusiness_bak (){
    SocketPacketModel *_model;
}

@end

@implementation SBUdpBusiness_bak

/**
 *  请求加好友
 */
- (void)requestFriend:(NSString *)alertMsg withUdpCommand:(SocketCommandEnum)command{
    NSDictionary *param = @{@"FriendId":_model.sendUserId,
                            @"AccountId":[PublicMethod getLoginUserMessage].AccountId};
    [[HttpClientHelper sharedInstance] post:FriendsWithGetFriendInfo resultType:[UserMessage class] parameters:param success:^(UserMessage *result) {
        if (!result.Success) {
            
            return;
        }
        
        NSString *message = [NSString stringWithFormat:alertMsg,result.NickName];
        
        [UIAlertView alertWithTitles:@"提示" message:message clickBlock:^(UIAlertView *alertView, NSInteger clickIndex) {
            
            SocketCommandEnum value;
            
            if (command == SocketCommandRequestFriend) {
                
                if (clickIndex == alertView.cancelButtonIndex) {
                    // 拒绝添加好友
                    value = SocketCommandRefuseFriend;
                }else{
                    // 同意添加好友
                    value = SocketCommandAgreeFriend;
                }
                
            }else if (command == SocketCommandRequstPlay){
                
                if (clickIndex == alertView.cancelButtonIndex) {
                    // 拒绝一起玩
                    value = SocketCommandRefausePlay;
                }else{
                    // 同意一起玩
                    value = SocketCommandAgreePlay;
                }

            }else if(command == SocketCommandMachineConnect){
                if (clickIndex == alertView.cancelButtonIndex) {
                    //
                    value = SocketCommandMachineDisConnect;
                }else {
                    value = SocketCommandMachineConnect;
                }
            }else if(command == SocketCommandRequestMachineConnect){
                if (clickIndex == alertView.cancelButtonIndex) {
                    // 拒绝联机
                    value = SocketCommandRefuseMachineConnect;
                }else {
                    // 同意联机
                    value = SocketCommandAgreeMachineConnect;
                }
            }else if(command == SocketCommandRequestStopMachineConnect){
                if (clickIndex == alertView.cancelButtonIndex) {
                    // 拒绝结束联机
                    value = SocketCommandRefuseStopMachineConnect;
                }else {
                    // 同意结束联机
                    value = SocketCommandAgreeStopMachineConnect;
                }
            }
            
            [appDelegate connectionSocketAndSendData:value receiveUserId:_model.sendUserId data:@""];
            
            if (value == SocketCommandAgreePlay) {
                MessageController *contrller = [[MessageController alloc] init];
                contrller.udpPacketModel = _model;
                
                [self pushController:contrller];
            }else if(value == SocketCommandAgreeMachineConnect){
                
                [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:IsConnectioning];
                
                UserMessage *reveiceUser = [PublicMethod getReceiveUserMessage];
                
                ChatViewController *chatController = [[ChatViewController alloc] initWithConversationChatter:reveiceUser.Phone conversationType:eConversationTypeGroupChat];
                chatController.title = reveiceUser.NickName;
                
                chatController.receiverUser = reveiceUser;
                
                [self pushController:chatController];
            }
            
        } cancelButtonTitle:@"拒绝" otherButtonTitles:@"同意", nil];
        
    } failure:nil showLoading:NO];
}

- (void)executeWithModel:(SocketPacketModel *)model{
    _model = model;
    if (![model isValidData]) {
        return;
    }
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
    switch (model.command) {
        case SocketCommandConnect: // 链接服务器
            break;
        case SocketCommandDisConnect:  // 断开服务器
            break;
        case SocketCommandRequstPlay://请求一起玩
            [self requestFriend:@" [%@] 邀请您一起玩" withUdpCommand:model.command];
            break;
        case SocketCommandAgreePlay://同意一起玩，此时不停发送电机数据
        {
            MessageController *contrller = [[MessageController alloc] init];
            contrller.udpPacketModel = _model;
             [self pushController:contrller];
            [UIAlertView alertWithMessage:@"同意一起玩邀请" clickBlock:nil];
        }
            break;
        case SocketCommandMachineConnecting:
        {
            NSLog(@"正在一起玩: %@",_model.data);
            
            BabyBluetooth *babyBluetooth = [BabyBluetooth shareBabyBluetooth];
            CBCharacteristic *currCharacteristic = [BabyToy findCharacteristicFormServices:babyBluetooth.allServers UUIDString:WriteDateUUID];
            if (currCharacteristic == nil) {
                return;
            }
            
            NSData *data = [BabyToy stringToHex:_model.data];
            [babyBluetooth.currPeripheral writeValue:data forCharacteristic:currCharacteristic type:CBCharacteristicWriteWithoutResponse];
        }
            break;
        case SocketCommandRefausePlay:// 拒绝一起玩
            [UIAlertView alertWithMessage:@"对方拒绝您的一起玩邀请" clickBlock:nil];
            break;
        case SocketCommandRequestFriend:   // 申请加好友
            [self requestFriend:@" [%@] 申请添加你为好友" withUdpCommand:model.command];
            break;
        case SocketCommandAgreeFriend:     // 同意加好友
            [RequestStaticMethod joinFriendAction:_model.sendUserId with:_model.receiveUserId];
            break;
        case SocketCommandRefuseFriend:    // 拒绝加好友
            [UIAlertView alertWithMessage:@"对方拒绝您的好友请求" clickBlock:nil];
            break;
        case SocketCommandMachineConnect:  //连接设备
            [self requestFriend:@" [%@] 请求联机" withUdpCommand:model.command];
            break;
        case SocketCommandMachineDisConnect:   // 断开设备
            break;
        case SocketCommandRequestMachineConnect:
            [self requestFriend:@" [%@] 请求与你联机" withUdpCommand:model.command];
            break;
        case SocketCommandRefuseMachineConnect:
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:NO] forKey:IsConnectioning];
            [UIAlertView alertWithMessage:@"对方拒绝您的联机请求" clickBlock:nil];
            break;
        case SocketCommandAgreeMachineConnect:
            [self friendsWithOnlinePlayingAdd];
            break;
        case SocketCommandRequestStopMachineConnect:
            [self requestFriend:@" [%@] 请求结束联机" withUdpCommand:model.command];
            break;
        case SocketCommandRefuseStopMachineConnect:
        {
            int count = [[[NSUserDefaults standardUserDefaults] valueForKey:RequestQuitCount] intValue];
            count++;
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:count] forKey:RequestQuitCount];
            [UIAlertView alertWithMessage:@"对方拒绝结束联机" clickBlock:nil];
        }
            break;
        case SocketCommandAgreeStopMachineConnect:
        {
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:0] forKey:RequestQuitCount];
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:NO] forKey:IsConnectioning];
            [self requestFriend:@" [%@] 同意结束联机" withUdpCommand:model.command];
        }
            break;
        case SocketCommandMustStopMachineConnect:
        {
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:0] forKey:RequestQuitCount];
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:NO] forKey:IsConnectioning];
            [UIAlertView alertWithMessage:@"对方强制结束了联机" clickBlock:nil];
        }
            break;
        default:
            break;
    }
}

/**
 *  @brief 建立联机
 */
- (void)friendsWithOnlinePlayingAdd{
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:IsConnectioning];
    NSDictionary *param = @{@"AccountId" : _model.sendUserId,
                            @"AccountMachineCode" : @"1",
                            @"PlayerId" : _model.receiveUserId,
                            @"PlayerMachineCode" : @"1"};
   [[HttpClientHelper sharedInstance] post:FriendsWithOnlinePlayingAdd resultType:[BaseResponseModel class] parameters:param success:^(BaseResponseModel *result) {
       
       if (result.Success) {
           
           [appDelegate connectionSocketAndSendData:SocketCommandMachineConnecting receiveUserId:_model.sendUserId data:@""];
           
       }else{
           [SVProgressHUD showErrorWithStatus:result.Message];
       }
       
   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
       
   } showLoading:YES];
}

/**
 *  @brief　跳转到一起玩界面
 */
- (void)pushController:(UIViewController *)controller{
    
    UINavigationController *nav = [AppDelegate findNavigationController];
    
    if (nav != nil) {
        [nav pushViewController:controller animated:YES];
    }
}

@end

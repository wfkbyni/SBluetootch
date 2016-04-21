//
//  SBMachineConnectBusiness.m
//  SBluetoothReceive
//
//  Created by rrkd on 16/1/29.
//  Copyright © 2016年 sych. All rights reserved.
//

#import "SBMachineConnectBusiness.h"
#import "ChatViewController.h"
#import "BluetoothHelper.h"

@interface SBMachineConnectBusiness(){
    NSMutableArray *bufferArray;
}

@end

@implementation SBMachineConnectBusiness

- (void)sendData:(NSString *)data receiveUserId:(NSString *)receiveUserId{
    [appDelegate connectionSocketAndSendData:SocketCommandMachineConnecting receiveUserId:receiveUserId data:data];
}

- (void)createCanExecuteCommand{
    [self addModuleWithCommand:SocketCommandMachineConnect mode:self];
    [self addModuleWithCommand:SocketCommandMachineDisConnect mode:self];
    [self addModuleWithCommand:SocketCommandRequestMachineConnect mode:self];
    [self addModuleWithCommand:SocketCommandRefuseMachineConnect mode:self];
    [self addModuleWithCommand:SocketCommandAgreeMachineConnect mode:self];
    [self addModuleWithCommand:SocketCommandRequestStopMachineConnect mode:self];
    [self addModuleWithCommand:SocketCommandRefuseStopMachineConnect mode:self];
    [self addModuleWithCommand:SocketCommandAgreeStopMachineConnect mode:self];
    [self addModuleWithCommand:SocketCommandMustStopMachineConnect mode:self];
    [self addModuleWithCommand:SocketCommandMachineConnecting mode:self];
    
    bufferArray = [NSMutableArray new];
    [self getChangeValue];
}

- (void)executeWithModel:(SocketPacketModel *)model{
    switch (model.command) {
            //此处两个命令不是用作联机的，是用户的设备和手机配对成功后发送的命令，将设备标识一起发送，其他人收到对应的设备标识好显示该用户正在使用的设备
        case SocketCommandMachineConnect:  //连接设备
//            [self requestFriendInfo:@" [%@] 请求联机"
//                     withSocketCommand:model.command
//                         alertBlock:^SocketCommandEnum(SocketCommandEnum modelCommand, UIAlertView *alertView, NSInteger clickIndex) {
//                             return 0;
//            }];
            break;
        case SocketCommandMachineDisConnect:   // 断开设备
            break;
        case SocketCommandRequestMachineConnect://请求联机
            [self requestFriendInfo:@" [%@] 请求与你联机" alertBlock:^SocketCommandEnum(UIAlertView *alertView, NSInteger clickIndex) {
                if (clickIndex == alertView.cancelButtonIndex) {
                    return SocketCommandRefuseMachineConnect;
                }
                return SocketCommandAgreeMachineConnect;
            }];
            break;
        case SocketCommandRefuseMachineConnect://拒绝联机
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:NO] forKey:IsConnectioning];
            [UIAlertView alertWithMessage:@"对方拒绝您的联机请求" clickBlock:nil];
            break;
        case SocketCommandMachineConnecting://接收方收到此命令就可以直接发送给电机，让电机动起来
        {
            [bufferArray addObject:model.data];
            
        }
            break;
        case SocketCommandAgreeMachineConnect://同意联机
            [self agreeMachineConnect:model];
            break;
        case SocketCommandRequestStopMachineConnect://请求结束联机
            [self requestFriendInfo:@" [%@] 请求结束联机" alertBlock:^SocketCommandEnum(UIAlertView *alertView, NSInteger clickIndex) {
                if (clickIndex == alertView.cancelButtonIndex) {
                    return SocketCommandRefuseStopMachineConnect;
                }
                return SocketCommandAgreeStopMachineConnect;
            }];
            break;
        case SocketCommandRefuseStopMachineConnect://拒绝结束联机
        {
            int count = [[[NSUserDefaults standardUserDefaults] valueForKey:RequestQuitCount] intValue];
            count++;
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:count] forKey:RequestQuitCount];
            [UIAlertView alertWithMessage:@"对方拒绝结束联机" clickBlock:nil];
        }
            break;
        case SocketCommandAgreeStopMachineConnect://同意结束联机
            [self agreeStopMachineConnect:model];
            break;
        case SocketCommandMustStopMachineConnect://强制结束联机
            [self mustStopMachineConnect:model];
            if ([self.navigationController.visibleViewController isKindOfClass:[ChatViewController class]]) {
                [self.navigationController popViewControllerAnimated:YES];
            }
            [UIAlertView alertWithMessage:@"对方强制结束了联机" clickBlock:nil];
            break;
        default:
            break;
    }
}

/**
 *  @brief 每隔50毫秒取一个值
 */
- (void)getChangeValue{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(50 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
            
            if (bufferArray != nil && bufferArray.count > 0) {
                NSLog(@"changeValue %@",bufferArray);
                
                BluetoothHelper *helper = [BluetoothHelper shareBluetoothHelper];
                [helper writeDataToDevice:bufferArray.firstObject];
                [bufferArray removeObject:bufferArray.firstObject inRange:NSMakeRange(0, 1)];
                
            }
            
            [self getChangeValue];
            
        });
        
    });
}

/**
 *  强制结束联机
 *
 */
- (void)mustStopMachineConnect:(SocketPacketModel *)model{
    [[NSUserDefaults standardUserDefaults] setValue:@(NO) forKey:IsConnectioning];
    [[NSUserDefaults standardUserDefaults] setValue:@(0) forKey:RequestQuitCount];
    NSDictionary *param = @{@"AccountId" : model.sendUserId,
                            @"PlayerId" : model.receiveUserId};
    [[HttpClientHelper sharedInstance] post:FriendsWithUnPlaying resultType:[BaseResponseModel class] parameters:param success:^(BaseResponseModel *result) {
        
        if (result.Success) return;
        [SVProgressHUD showErrorWithStatus:result.Message];
        
    } failure:nil showLoading:YES];
}

/**
 *  同意结束联机
 *
 */
- (void)agreeStopMachineConnect:(SocketPacketModel *)model{
    [self mustStopMachineConnect:model];
    [self requestFriendInfo:^(UserMessage *result) {
        NSString *message = [NSString stringWithFormat:@" [%@] 同意结束联机",result.NickName];
        [UIAlertView alertWithMessage:message clickBlock:nil];
    }];
}

/**
 *  收到同意联机命令（修改数据库状态后，可以不停接收SocketCommandMachineConnecting命令，让电机动起来）
 *
 */
- (void)agreeMachineConnect:(SocketPacketModel *)model{
    [self requestFriendInfo:^(UserMessage *result) {
        NSString *message = [NSString stringWithFormat:@" [%@] 同意您的联机请求，你们可以欢快的玩耍啦！",result.NickName];
        [UIAlertView alertWithMessage:message clickBlock:^(UIAlertView *alertView, NSInteger clickIndex) {
            [[NSUserDefaults standardUserDefaults] setValue:@(YES) forKey:IsConnectioning];
            
            UserMessage *reveiceUser = [PublicMethod getReceiveUserMessage];
            
            ChatViewController *chatController = [[ChatViewController alloc] initWithConversationChatter:reveiceUser.Phone conversationType:eConversationTypeGroupChat];
            chatController.title = reveiceUser.NickName;
            
            chatController.receiverUser = reveiceUser;
            
            [self pushController:chatController];
        }];
    }];
    
    NSDictionary *param = @{@"AccountId" : model.sendUserId,
                            @"AccountMachineCode" : @"1",
                            @"PlayerId" : model.receiveUserId,
                            @"PlayerMachineCode" : @"1"};
    [[HttpClientHelper sharedInstance] post:FriendsWithOnlinePlayingAdd resultType:[BaseResponseModel class] parameters:param success:^(BaseResponseModel *result) {
        
        if (result.Success) {
            [[NSUserDefaults standardUserDefaults] setValue:@(YES) forKey:IsConnectioning];
            return;
        }
        [SVProgressHUD showErrorWithStatus:result.Message];
        
    } failure:nil showLoading:YES];
}

@end

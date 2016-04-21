//
//  SBPlayTogetherBusiness.m
//  SBluetoothReceive
//
//  Created by rrkd on 16/1/29.
//  Copyright © 2016年 sych. All rights reserved.
//

#import "SBPlayTogetherBusiness.h"
#import "ChatViewController.h"

@implementation SBPlayTogetherBusiness

- (void)createCanExecuteCommand{
    [self addModuleWithCommand:SocketCommandRequstPlay mode:self];
    [self addModuleWithCommand:SocketCommandAgreePlay mode:self];
    [self addModuleWithCommand:SocketCommandRefausePlay mode:self];
}

- (void)executeWithModel:(SocketPacketModel *)model{
    @weakify(self)
    switch (model.command) {
        case SocketCommandRequstPlay://请求一起玩
        {
            [self requestFriendInfo:@" [%@] 邀请您一起玩" alertBlock:^SocketCommandEnum(UIAlertView *alertView, NSInteger clickIndex) {
                if (clickIndex == alertView.cancelButtonIndex) {
                    return SocketCommandRefausePlay;
                }
                [self_weak_ agreePlay:model];
                return SocketCommandAgreePlay;
            }];
        }
            break;
        case SocketCommandAgreePlay://同意一起玩
        {
            [self agreePlay:model];
            [UIAlertView alertWithMessage:@"同意一起玩邀请" clickBlock:nil];
        }
            break;
        case SocketCommandRefausePlay:// 拒绝一起玩
            [UIAlertView alertWithMessage:@"对方拒绝您的一起玩邀请" clickBlock:nil];
            break;
        default:
            break;
    }
}

/**
 *  同意一起玩
 *
 */
- (void)agreePlay:(SocketPacketModel *)model{
    [[NSUserDefaults standardUserDefaults] setValue:@(YES) forKey:IsConnectioning];
    
    UserMessage *reveiceUser = [PublicMethod getReceiveUserMessage];
    
    ChatViewController *chatController = [[ChatViewController alloc] initWithConversationChatter:reveiceUser.Phone conversationType:eConversationTypeGroupChat];
    chatController.title = reveiceUser.NickName;
    
    chatController.receiverUser = reveiceUser;
    [self pushController:chatController];
}

@end

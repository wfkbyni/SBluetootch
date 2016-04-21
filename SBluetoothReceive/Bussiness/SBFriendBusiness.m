//
//  SBFriendBusiness.m
//  SBluetoothReceive
//
//  Created by rrkd on 16/1/29.
//  Copyright © 2016年 sych. All rights reserved.
//

#import "SBFriendBusiness.h"

@implementation SBFriendBusiness

- (void)createCanExecuteCommand{
    [self addModuleWithCommand:SocketCommandRequestFriend mode:self];
    [self addModuleWithCommand:SocketCommandAgreeFriend mode:self];
    [self addModuleWithCommand:SocketCommandRefuseFriend mode:self];
}

- (void)executeWithModel:(SocketPacketModel *)model{
    switch (model.command) {
        case SocketCommandRequestFriend:   // 申请加好友
            [self requestFriendInfo:@" [%@] 申请添加你为好友" alertBlock:^SocketCommandEnum(UIAlertView *alertView, NSInteger clickIndex) {
                if (clickIndex == alertView.cancelButtonIndex) {
                    return SocketCommandRefuseFriend;
                }
                return SocketCommandAgreeFriend;
            }];
            break;
        case SocketCommandAgreeFriend:     // 同意加好友
            [RequestStaticMethod joinFriendAction:model.sendUserId with:model.receiveUserId];
            break;
        case SocketCommandRefuseFriend:    // 拒绝加好友
            [UIAlertView alertWithMessage:@"对方拒绝您的好友请求" clickBlock:nil];
            break;
        default:
            break;
    }
}

@end

//
//  SBServerBusiness.m
//  SBluetoothReceive
//
//  Created by rrkd on 16/1/29.
//  Copyright © 2016年 sych. All rights reserved.
//

#import "SBServerBusiness.h"

@implementation SBServerBusiness

- (void)createCanExecuteCommand{
    [self addModuleWithCommand:SocketCommandConnect mode:self];
    [self addModuleWithCommand:SocketCommandDisConnect mode:self];
}

- (void)executeWithModel:(SocketPacketModel *)model{
    switch (model.command) {
        case SocketCommandConnect: // 链接服务器
            break;
        case SocketCommandDisConnect:  // 断开服务器
            break;
        default:
            break;
    }
}

@end

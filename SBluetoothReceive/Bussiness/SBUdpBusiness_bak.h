//
//  SBSocketBusiness.h
//  SBluetoothReceive
//
//  Created by rrkd on 15/12/17.
//  Copyright © 2015年 sych. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocketPacketModel.h"

@interface SBUdpBusiness_bak : NSObject

/**
 *  能否执行此命令
 *
 *  @param command 命令
 */
- (BOOL)canExecute:(SocketCommandEnum)command;

/**
 *  执行业务
 *
 *  @param model    Socket包
 */
- (void)executeWithModel:(SocketPacketModel *)model;

@end

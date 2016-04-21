//
//  SBMachineConnectBusiness.h
//  SBluetoothReceive
//
//  Created by rrkd on 16/1/29.
//  Copyright © 2016年 sych. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBSocketBusiness.h"

/**
 *  联机业务模块
 */
@interface SBMachineConnectBusiness : SBSocketBusiness

/**
 *  将正在联机的发送方的电机数据（6字节）发送给接收方
 *
 *  @param data          数据
 *  @param receiveUserId 接收方
 */
- (void)sendData:(NSString *)data
   receiveUserId:(NSString *)receiveUserId;

/**
 *  创建命令与业务的关系
 *
 */
- (void)createCanExecuteCommand;

/**
 *  执行业务
 *
 *  @param model    udp包
 */
- (void)executeWithModel:(SocketPacketModel *)model;

@end

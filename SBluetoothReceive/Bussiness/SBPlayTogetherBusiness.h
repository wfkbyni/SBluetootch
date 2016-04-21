//
//  SBPlayTogetherBusiness.h
//  SBluetoothReceive
//
//  Created by rrkd on 16/1/29.
//  Copyright © 2016年 sych. All rights reserved.
//

#import "SBSocketBusiness.h"

/**
 *  一起玩模块
 */
@interface SBPlayTogetherBusiness : SBSocketBusiness

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

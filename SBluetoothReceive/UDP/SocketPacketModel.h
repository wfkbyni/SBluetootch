//
//  SocketPacketModel.h
//  UdpClient
//
//  Created by XIONGWANG on 15/11/28.
//  Copyright © 2015年 熊猫人. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocketCommandEnum.h"

#define kSocketPacketLength 86// socket包长度
@interface SocketPacketModel : NSObject
/**
 *  命令
 */
@property (nonatomic,assign) SocketCommandEnum command;
/**
 *  发送方用户id
 */
@property (nonatomic,strong) NSString *sendUserId;
/**
 *  接收方用户id
 */
@property (nonatomic,strong) NSString *receiveUserId;
/**
 *  数据,如要发送的电机数据
 */
@property (nonatomic,strong) NSString *data;

/**
 *  初始化udp包对象
 *
 *  @param data 从服务端接收到的udp数据包
 *
 *  @return udp包对象
 */
- (instancetype)initWithData:(NSData *)data;

/**
 *  初始化udp包对象
 *
 *  @param command        要发送的命令
 *  @param sendUserId     发送包的user id
 *  @param receiveUserId  接收方的user id
 *  @param dataCode       要发送的数据，如电机数据
 *
 *  @return udp包对象
 */
- (instancetype)initWithCommand:(SocketCommandEnum)command
                     sendUserId:(NSString *)sendUserId
                  receiveUserId:(NSString *)receiveUserId
                       data:(NSString *)data;
/**
 *  当前对象转换成的86个字节的data类型
 */
- (NSMutableData *)buffer;

/**
 *  判断初始化传入的数据是否合法
 */
- (BOOL)isValidData;

@end

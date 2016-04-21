//
//  SocketPacketModel.m
//  UdpClient
//
//  Created by XIONGWANG on 15/11/28.
//  Copyright © 2015年 熊猫人. All rights reserved.
//

#import "SocketPacketModel.h"

#import "AppDelegate.h"

#define kSocketPacketKey "~[$]"
#define kSocketEmptyUserId @"00000000-0000-0000-0000-000000000000"
@interface SocketPacketModel (){
    const char *_udpPacketKey;
}

@end

@implementation SocketPacketModel

- (instancetype)initWithData:(NSData *)data{
    if (self = [super init]) {
        char *udpPacketKey = (char *)malloc(sizeof(char) * 4);
        [data getBytes:udpPacketKey length:4];
        NSString *str = [[NSString alloc] initWithBytes:udpPacketKey length:4 encoding:NSUTF8StringEncoding];
        free(udpPacketKey);
        _udpPacketKey = str.UTF8String;
        if (strcmp(_udpPacketKey, kSocketPacketKey) != 0) {
            return self;
        }
        [data getBytes:&_command range:NSMakeRange(4, 4)];
        char *userId = (char *)malloc(sizeof(char) * 36);
        [data getBytes:userId range:NSMakeRange(8, 36)];
        _sendUserId = [[NSString alloc] initWithBytes:userId length:36 encoding:NSUTF8StringEncoding];
        [data getBytes:userId range:NSMakeRange(44, 36)];
        _receiveUserId = [[NSString alloc] initWithBytes:userId length:36 encoding:NSUTF8StringEncoding];
        free(userId);
        char *dataChar = (char *)malloc(sizeof(char) * 6);
        [data getBytes:dataChar range:NSMakeRange(80, 6)];
        _data = [[NSString alloc] initWithBytes:dataChar length:6 encoding:NSUTF8StringEncoding];
        free(dataChar);
        _data = [_data stringByReplacingOccurrencesOfString:@"\0" withString:@""];
    }
    return self;
}

- (instancetype)initWithCommand:(SocketCommandEnum)command sendUserId:(NSString *)sendUserId receiveUserId:(NSString *)receiveUserId data:(NSString *)data{
    if (self = [super init]) {
        _udpPacketKey = kSocketPacketKey;
        _command = command;
        _sendUserId = sendUserId;
        _receiveUserId = receiveUserId;
        _data = data.length ? data : @"000000";
    }
    return self;
}

- (NSMutableData *)buffer{
    NSMutableData *bufferData = [NSMutableData dataWithBytes:_udpPacketKey length:4];
    [bufferData appendBytes:&_command length:4];
    if (_sendUserId.length != kSocketEmptyUserId.length) {
        _sendUserId = kSocketEmptyUserId;
    }
    
    const char *sendUserId = _sendUserId.UTF8String;
    [bufferData appendBytes:sendUserId length:36];
    if (_receiveUserId.length != kSocketEmptyUserId.length) {
        _receiveUserId = kSocketEmptyUserId;
    }
    
    const char *receiveUserId = _receiveUserId.UTF8String;
    [bufferData appendBytes:receiveUserId length:36];
    
    const char *dataChar = _data.UTF8String;
    [bufferData appendBytes:dataChar length:6];
    
    return bufferData;
}

- (BOOL)isValidData{
    return strcmp(_udpPacketKey, kSocketPacketKey) == 0;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"命令:%ld,发送方id:%@,接收方id:%@,数据:%@",_command,_sendUserId,_receiveUserId,_data];
}

@end

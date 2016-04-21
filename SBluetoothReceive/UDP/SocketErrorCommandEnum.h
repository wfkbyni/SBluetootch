//
//  SocketErrorCommandEnum.h
//  UdpClient
//
//  Created by XIONGWANG on 15/11/29.
//  Copyright © 2015年 熊猫人. All rights reserved.
//

//错误信息
typedef NS_ENUM(NSUInteger,SocketErrorCommandEnum) {
    /**
     *  接收方已断开连接（已下线）
     */
    SocketCommandReceiveUserDisConnect = 1, // 接收方已断开连接（已下线）

    SocketCommandReceiveUserMachineDisConnect = 2 // 当联机过程中任何一方设备断开时需发送此命令给另一方，并同时结束联机过程，然后调用HTTP文档【断开联机】接口
};

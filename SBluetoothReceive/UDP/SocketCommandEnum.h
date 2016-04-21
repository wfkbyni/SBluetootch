//
//  UdpCommandEnum.h
//  UdpClient
//
//  Created by rrkd on 15/11/27.
//  Copyright © 2015年 熊猫人. All rights reserved.
//

typedef NS_ENUM(NSUInteger,SocketCommandEnum) {
    /**
     *  链接服务器
     */
    SocketCommandConnect = 1,
    /**
     *  断开服务器
     */
    SocketCommandDisConnect = 2,
    /**
     *  请求一起玩
     */
    SocketCommandRequstPlay = 3,
    /**
     *  同意一起玩
     */
    SocketCommandAgreePlay = 4,
    /**
     *  正在玩
     */
    SocketCommandPlaying = 5,
    /**
     *  拒绝一起玩
     */
    SocketCommandRefausePlay = 6,
    /**
     *  申请加好友
     */
    SocketCommandRequestFriend = 7,
    /**
     *  同意加好友
     */
    SocketCommandAgreeFriend = 8,
    /**
     *  拒绝加好友
     */
    SocketCommandRefuseFriend = 9,
    /**
     *  连接设备
     */
    SocketCommandMachineConnect = 10,
    /**
     *  断开设备
     */
    SocketCommandMachineDisConnect = 11,
    /**
     *  请求联机
     */
    SocketCommandRequestMachineConnect = 12,
    /**
     *  同意联机
     */
    SocketCommandAgreeMachineConnect = 13,
    /**
     *  正在联机
     */
    SocketCommandMachineConnecting = 14,
    /**
     *  拒绝联机
     */
    SocketCommandRefuseMachineConnect = 15,
    /**
     *  请求结束联机
     */
    SocketCommandRequestStopMachineConnect = 16,
    /**
     *  同意结束联机
     */
    SocketCommandAgreeStopMachineConnect = 17,
    /**
     *  拒绝结束联机
     */
    SocketCommandRefuseStopMachineConnect = 18,
    /**
     *  强制结束联机
     */
    SocketCommandMustStopMachineConnect = 19,

    /**
     *  错误 参见SocketErrorCommandEnum
     */
    SocketCommandError = 999,
    /*  SocketCommandReceiveUserDisConnect = 1,   接收方已断开连接（已下线）
        SocketCommandReceiveUserMachineDisConnect = 2 ，当联机过程中任何一方设备断开时需发送此命令给另一方，并同时结束联机过程，然后调用HTTP文档【断开联机】接口*/
};

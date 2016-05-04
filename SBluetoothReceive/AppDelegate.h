//
//  AppDelegate.h
//  SBluetoothReceive
//
//  Created by 舒永超 on 15/10/18.
//  Copyright © 2015年 sych. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"

#define SocketType 0//0:udp 1:tcp

@interface AppDelegate : UIResponder <UIApplicationDelegate,
#if SocketType
GCDAsyncSocketDelegate,
#else
GCDAsyncUdpSocketDelegate,
#endif
IChatManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

#if SocketType
@property (nonatomic, strong) GCDAsyncSocket *socket;
#else
@property (nonatomic, strong) GCDAsyncUdpSocket *socket;
#endif

@property (strong, nonatomic) MainViewController *mainController;

/**
 *  发送数据
 *
 *  @param command       命令
 *  @param receiveUserId 接收方
 *  @param data          发送的数据
 */
- (void)connectionSocketAndSendData:(SocketCommandEnum)command
                      receiveUserId:(NSString *)receiveUserId
                               data:(NSString *)data;

+ (UINavigationController *)findNavigationController;

@end


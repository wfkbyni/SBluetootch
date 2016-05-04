//
//  AppDelegate.m
//  SBluetoothReceive
//
//  Created by 舒永超 on 15/10/18.
//  Copyright © 2015年 sych. All rights reserved.
//

#import "AppDelegate.h"

#import "LoginController.h"

#import "BluetoochListController.h"

#import "UserInfoController.h"

#import "StrangerListController.h"

#import "UIAlertViewExtension.h"

#import "OneController.h"
#import "TwoController.h"
#import "DoubleController.h"
#import "UserInfoController.h"
#import "SettingController.h"
#import "SBSocketBusiness.h"
#import "MainViewController.h"

#import "AppDelegate+EaseMob.h"


@interface AppDelegate (){
    SBSocketBusiness *_bll;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
#pragma 初始化环信SDK，详细内容在AppDelegate+EaseMob.m 文件中
#pragma SDK注册 APNS文件的名字, 需要与后台上传证书时的名字一一对应
    NSString *apnsCertName = nil;
#if DEBUG
    apnsCertName = @"sbluetoothreveice_dev";
#else
    apnsCertName = @"sbluetoothreveice_dev";
#endif
    [self easemobApplication:application
didFinishLaunchingWithOptions:launchOptions
                      appkey:EaseMobAppKey
                apnsCertName:apnsCertName
                 otherConfig:@{kSDKConfigEnableConsoleLogger:[NSNumber numberWithBool:YES]}];
    
    [self.window makeKeyAndVisible];
    [self initComponent];
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if (_mainController) {
        [_mainController jumpToChatList];
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if (_mainController) {
        [_mainController didReceiveLocalNotification:notification];
    }
}

- (void)initComponent{
    if (!_socket) {
        #if SocketType
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        #else
        _socket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        NSError *error = nil;
        if (![_socket bindToPort:0 error:&error]){
            NSLog(@"Error bindToPort: %@", error);
            return;
        }
        if (![_socket beginReceiving:&error]){
            NSLog(@"Error receiving: %@", error);
            return;
        }
        #endif
    }
    if (!_bll) {
        _bll = [SBSocketBusiness new];
        [_bll registerAllCommand];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application{
    //程序退出时通知服务器断开连接，且要调用http退出登录接口，这是需要处理的，但是写在这儿有问题
    if (_socket) {
        NSString *accoutId = [PublicMethod getLoginUserMessage].AccountId;
        if (!accoutId.length) {
        #if SocketType
            [_socket disconnect];
        #else
            [_socket close];
        #endif
            return;
        }
        [self connectionSocketAndSendData:SocketCommandDisConnect receiveUserId:@"" data:@""];
        #if SocketType
        [_socket disconnectAfterWriting];
        #else
        [_socket closeAfterSending];
        #endif
    }
}

- (void)connectionSocketAndSendData:(SocketCommandEnum)command
                      receiveUserId:(NSString *)receiveUserId
                               data:(NSString *)data{
    NSData *bufferData = nil;
    if (receiveUserId.length) {
        UserMessage *user = [PublicMethod getLoginUserMessage];
        bufferData = [[[SocketPacketModel alloc] initWithCommand:command sendUserId:user.AccountId receiveUserId:receiveUserId data:data] buffer];
        DebugLog(@"命令：%d 数据：%@ 接收方：%@",(int)command,data,receiveUserId);
    }
    #if SocketType
    if (![_socket isConnected] || [_socket isDisconnected]) {
    #else
    if (![_socket isConnected] || [_socket isClosed]) {
    #endif
        NSError *error = nil;
        #if SocketType
        uint16_t port = 9011;
        #else
        uint16_t port = 9010;
        #endif
        if (![_socket connectToHost:serverurl onPort:port error:&error]) {
            NSLog(@"Error connect: %@", error);
            return;
        }
        NSString *accoutId = [PublicMethod getLoginUserMessage].AccountId;
        if (accoutId == nil || accoutId.length == 0) {
            return;
        }
        SocketPacketModel *model = [[SocketPacketModel alloc] initWithCommand:SocketCommandConnect sendUserId:accoutId receiveUserId:@"" data:@""];
        bufferData = [model buffer];
    }
    if (bufferData) {
        #if SocketType
        [_socket writeData:bufferData withTimeout:20 tag:0];
        #else
        [_socket sendData:bufferData withTimeout:20 tag:0];
        #endif
    }
}

#if SocketType

#pragma mark - GCDAsyncSocketDelegate
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    DebugLog(@"断开连接：%@",err);
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    [sock readDataToLength:kSocketPacketLength withTimeout:-1 tag:tag];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    SocketPacketModel *model = [[SocketPacketModel alloc] initWithData:data];
    [_bll executeWithModel:model];
    [sock readDataToLength:kSocketPacketLength withTimeout:-1 tag:tag];
}
    
#else
#pragma mark - GCDAsyncUdpSocketDelegate
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error{
    NSLog(@"链接失败：%@",error);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{
    NSLog(@"发送数据失败：%@",error);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock
   didReceiveData:(NSData *)data
      fromAddress:(NSData *)address withFilterContext:(id)filterContext{
    SocketPacketModel *model = [[SocketPacketModel alloc] initWithData:data];
    [_bll executeWithModel:model];
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error{
    NSLog(@"udp socket关闭：%@",error);
}
#endif

+(UINavigationController *)findNavigationController{
    
    AppDelegate *delegate = appDelegate;

    id rootViewController = [delegate.window rootViewController];
    
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *controller = (UITabBarController *)rootViewController;
        rootViewController = [controller.viewControllers objectAtIndex:controller.selectedIndex];
    }
    
    if ([rootViewController isKindOfClass:[UINavigationController class]]) {

        return rootViewController;
    }else{
        [SVProgressHUD showErrorWithStatus:@"未找到有效的nav控制器"];
        NSAssert([rootViewController isKindOfClass:[UINavigationController class]], @"未找到有效的nav控制器");
    }
    
    return nil;
}
@end

//
//  SBSocketBusiness.h
//  SBluetoothReceive
//
//  Created by rrkd on 15/12/17.
//  Copyright © 2015年 sych. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocketPacketModel.h"
#import "AppDelegate.h"

@interface SBSocketBusiness : NSObject

@property (nonatomic,strong) SocketPacketModel *model;

@property (nonatomic,strong,readonly) UINavigationController *navigationController;

/**
 *  添加模块与命令到字典中
 *
 *  @param command 命令
 *  @param mode    业务模块
 */
- (void)addModuleWithCommand:(SocketCommandEnum)command mode:(SBSocketBusiness *)mode;
/**
 *  根据命令获取业务模块
 *
 *  @param command 命令
 *
 *  @return 业务模块
 */
- (SBSocketBusiness *)getModuleWithCommand:(SocketCommandEnum)command;

/**
 *  获取用户信息
 *
 *  @param successBlock 成功后回调
 */
- (void)requestFriendInfo:(successResultBlock)successBlock;

/**
 *  获取用户信息
 *
 *  @param alertMsg   提示信息
 *  @param alertBlock 点击弹框按钮的回调
 */
- (void)requestFriendInfo:(NSString *)alertMsg
               alertBlock:(SocketCommandEnum (^)(UIAlertView *alertView, NSInteger clickIndex))alertBlock;

/**
 *  注册所有命令
 */
- (void)registerAllCommand;

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

/**
 *  push控制器
 *
 */
- (void)pushController:(UIViewController *)controller;

@end

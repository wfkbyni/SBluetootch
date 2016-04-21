//
//  MessageController.h
//  SBluetoothReceive
//
//  Created by 舒永超 on 15/12/17.
//  Copyright © 2015年 sych. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SocketPacketModel.h"
#import "BaseController.h"

@interface MessageController : BaseController

@property (nonatomic, strong) SocketPacketModel *udpPacketModel;

@end

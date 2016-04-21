//
//  MessageController.m
//  SBluetoothReceive
//
//  Created by 舒永超 on 15/12/17.
//  Copyright © 2015年 sych. All rights reserved.
//

#import "MessageController.h"
#import "CacheDataInfo.h"

#import "AppDelegate.h"

@interface MessageController (){
    ACEDrawingView *acedrawingView;
    
    BabyBluetooth *babyBluetooth;
}
@end

@implementation MessageController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"消息";

    babyBluetooth = [BabyBluetooth shareBabyBluetooth];
    
    [self addDrawingView];
    
    [self babybluetoothDelegate];
}

/**
 *  @brief 添加指画view
 */
- (void)addDrawingView{
    
    acedrawingView = [[ACEDrawingView alloc] initWithFrame:CGRectMake(0, ScreenSize.height - 200, ScreenSize.height, 200)];
    [acedrawingView setBackgroundColor:[UIColor orangeColor]];
    acedrawingView.lineWidth = 2;
    acedrawingView.lineColor = [UIColor greenColor];
    [self.view addSubview:acedrawingView];
    
    @weakify(self)
    [acedrawingView startSendDrawData:^(NSMutableArray *drawData) {
        
        @strongify(self)
        NSMutableArray *array = [NSMutableArray arrayWithArray:drawData];
        
        if (![self isConnectionBluetooth]) {
            
            CacheDataInfo *info = [[CacheDataInfo alloc] init];
            info.value = @"020000";
            [array addObject:info];
            
            //[babyBluetooth writeData:array];
            
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @strongify(self)
            @autoreleasepool {
                
                for (CacheDataInfo *info in array) {

                    if (info.value.length != 6) {
                        continue;
                    }
                    
                    sleep(ABS((int)[info.timeInterval longLongValue] / 1000));
                    
                    [appDelegate connectionSocketAndSendData:SocketCommandMachineConnecting receiveUserId:_udpPacketModel.receiveUserId data:info.value];
                    
                }
            }
        });
        
        [acedrawingView clear];
    }];
}

/**
 *  @brief 读取从蓝牙硬件上接收到的数据
 */
- (void)babybluetoothDelegate{
    
    @weakify(self)
    [babyBluetooth setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        @strongify(self)
        if (![self isConnectionBluetooth]) {
            NSString *value = [NSString stringWithFormat:@"%@",characteristics.value];
            
            value = [value stringByReplacingOccurrencesOfString:@" " withString:@""];
            
            NSLog(@"value :%@",value);
            
            value = [value stringByReplacingOccurrencesOfString:@"<" withString:@""];
            value = [value stringByReplacingOccurrencesOfString:@">" withString:@""];
            
            [appDelegate connectionSocketAndSendData:SocketCommandMachineConnecting receiveUserId:self.udpPacketModel.sendUserId data:value];
        }
        
    }];
    
    [babyBluetooth setBlockOnCancelAllPeripheralsConnectionBlock:^(CBCentralManager *centralManager) {
        [SVProgressHUD showErrorWithStatus:@"硬件连接已断开"];
    }];
}

/**
 *  @brief 是否连接蓝牙
 *
 *  @return <#return value description#>
 */
- (BOOL)isConnectionBluetooth{
    
    BOOL conn = babyBluetooth.currPeripheral.state != CBPeripheralStateConnected;
    
    if (conn) {
        [SVProgressHUD showErrorWithStatus:@"请先连接硬件设备"];
    }
    
    return conn;
}


@end

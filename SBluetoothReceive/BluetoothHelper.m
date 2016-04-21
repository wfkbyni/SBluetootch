//
//  BluetoothHelper.m
//  SBluetoothReceive
//
//  Created by 舒永超 on 16/1/26.
//  Copyright © 2016年 sych. All rights reserved.
//

#import "BluetoothHelper.h"
#import "BabyBluetooth.h"
#import "CacheDataInfo.h"
#import "AppDelegate.h"

static BluetoothHelper *bluetoothHelper = nil;
static BabyBluetooth *babyBluetooth = nil;

#define dateformat @"yyyy-MM-dd hh:mm:ss.SSSZ"

@implementation BluetoothHelper

+(BluetoothHelper *)shareBluetoothHelper{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bluetoothHelper = [[self alloc] init];
        babyBluetooth = [BabyBluetooth shareBabyBluetooth];

        [bluetoothHelper babybluetoothDelegate];
        [bluetoothHelper babyWithDelegate];
        
    });
    
    return bluetoothHelper;
}

/**
 *  @brief 读取从蓝牙硬件上接收到的数据
 */
- (void)babybluetoothDelegate{
    
    _cacheDatas = [NSMutableArray new];
    
    @weakify(self)
    [babyBluetooth setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        @strongify(self)
        if (![self isConnectionBluetooth]) {
            NSString *value = [NSString stringWithFormat:@"%@",characteristics.value];
            
            NSLog(@"value :%@",value);
            
            value = [value stringByReplacingOccurrencesOfString:@"<" withString:@""];
            value = [value stringByReplacingOccurrencesOfString:@">" withString:@""];
            
            [self writeDataToDevice:value];
            if (_isStartCacheData) {
                [self cacheDataWithMsg:value withTimeIntervalSince:50];
            }
        }
        
    }];
    
    [babyBluetooth setBlockOnCancelAllPeripheralsConnectionBlock:^(CBCentralManager *centralManager) {
        [SVProgressHUD showErrorWithStatus:@"硬件连接已断开"];
    }];
}

//babyDelegate
-(void)babyWithDelegate{
    
    __weak typeof(self)weakSelf = self;
    BabyRhythm *rhythm = [[BabyRhythm alloc]init];
    
    //设置设备连接成功的委托,同一个baby对象，使用不同的channel切换委托回调
    [babyBluetooth setBlockOnConnected:^(CBCentralManager *central, CBPeripheral *peripheral) {
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--连接成功",peripheral.name]];
        
    }];
    
    //设置设备连接失败的委托
    [babyBluetooth setBlockOnFailToConnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"设备：%@--连接失败",peripheral.name);
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--连接失败",peripheral.name]];
        [weakSelf performSelector:@selector(loadData) withObject:nil afterDelay:2];
    }];
    
    //设置设备断开连接的委托
    [babyBluetooth setBlockOnDisconnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        
        NSLog(@"设备：%@--断开连接",peripheral.name);
        //weakSelf.services = [[NSMutableArray alloc]init];
        
    }];
    
    //设置发现设备的Services的委托
    [babyBluetooth setBlockOnDiscoverServices:^(CBPeripheral *peripheral, NSError *error) {
        for (CBService *s in peripheral.services) {
            ///插入section到tableview
            
        }
        
        [rhythm beats];
    }];
    
    //设置发现设service的Characteristics的委托
    [babyBluetooth setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        NSLog(@"===service name:%@",service.UUID);
        
    }];
    
    //设置读取characteristics的委托
    [babyBluetooth setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"1 characteristic name:%@ value is:%@",characteristic.UUID,characteristic.value);
        
        NSString *value = [NSString stringWithFormat:@"%@",characteristic.value];
        
        value = [value stringByReplacingOccurrencesOfString:@"<" withString:@""];
        value = [value stringByReplacingOccurrencesOfString:@">" withString:@""];
        
    }];
    //设置发现characteristics的descriptors的委托
    [babyBluetooth setBlockOnDiscoverDescriptorsForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"===characteristic name:%@",characteristic.service.UUID);
        for (CBDescriptor *d in characteristic.descriptors) {
            NSLog(@"CBDescriptor name is :%@",d.UUID);
        }
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
        //[SVProgressHUD showErrorWithStatus:@"请先连接硬件设备"];
    }
    
    return conn;
}


/**
 *  @brief 往蓝牙硬件上写数据
 *
 *  @param value <#value description#>
 */
- (void)writeDataToDevice:(NSString *)changeValue{
    CBCharacteristic *currCharacteristic = [BabyToy findCharacteristicFormServices:babyBluetooth.allServers UUIDString:WriteDateUUID];
    if (currCharacteristic == nil) {
        return;
    }
    
    NSData *data = [BabyToy stringToHex:changeValue];
    [babyBluetooth.currPeripheral writeValue:data forCharacteristic:currCharacteristic type:CBCharacteristicWriteWithoutResponse];
    //[babyBluetooth.currPeripheral readValueForCharacteristic:currCharacteristic];
}

/**
 *  @brief 缓存电机数据
 *
 *  @param msg          <#msg description#>
 *  @param timeInterval <#timeInterval description#>
 */
#warning 注意 这里的timeInterval是在手机上操作的时候加的延迟时间 ，硬件上无效
- (void)cacheDataWithMsg:(NSString *)msg withTimeIntervalSince:(int)timeInterval{
    
    NSDateFormatter *df = [NSDateFormatter new];
    df.dateFormat = dateformat;
    NSString *dateStr = [df stringFromDate:[NSDate date]];
    
    CacheDataInfo *info = [[CacheDataInfo alloc] init];
    info.value = msg;
    info.date = dateStr;
    
    NSDate *date = [df dateFromString:dateStr];
    long timeInterval1 = [date timeIntervalSince1970] * 1000;
    
    if (_cacheDatas != nil && _cacheDatas.count > 0) {
        CacheDataInfo *oldCacheDataInfo = _cacheDatas.lastObject;
        
        dateStr = oldCacheDataInfo.date;
        
        date = [df dateFromString:dateStr];
        
        long timeInterval2 = [date timeIntervalSince1970] * 1000 + timeInterval;
        
        long timeInterval = timeInterval2 - timeInterval1;
        
        info.timeInterval = [NSNumber numberWithLong:timeInterval];
    }
    
    if (msg.length == 6) {
        [_cacheDatas addObject:info];
    }
}

-(void)writeDataToDevice:(NSArray *)data withIsCache:(BOOL)isCache{
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:data];
    
    CacheDataInfo *info = [[CacheDataInfo alloc] init];
    info.value = @"020000";
    [array addObject:info];
    
    [babyBluetooth writeData:array];
    
    if (isCache) {
        [_cacheDatas addObjectsFromArray:array];
    }
}

/**
 *  @brief 显示输入文件名alert
 */
- (void)showFileNameAlert:(CacheDataType)cacheDataType withCacheImage:(UIImage *)image{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"缓存文件" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:NULL];
    [controller addAction:cancel];
    
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = controller.textFields.firstObject;
        if ([textField.text length] == 0) {
            [SVProgressHUD showErrorWithStatus:@"请输入文件名"];
            [self showFileNameAlert:cacheDataType withCacheImage:image];
        }else{
            NSString *fileName = textField.text;
            
            fileName = [NSString stringWithFormat:@"%@|:|%@|:|%lu",fileName,[[NSDate new] stringWithFormat:@"yyyy-MM-dd hh:mm"],(unsigned long)cacheDataType];
            
            CacheDataInfo *info = [[CacheDataInfo alloc] init];
            info.value = @"020000";
            [_cacheDatas addObject:info];
            
            [PublicMethod archiverData:_cacheDatas withCacheName:[NSString stringWithFormat:@"%@|:|data",fileName]];
            [PublicMethod saveImageToLocal:image == nil ? [UIImage imageNamed:@"Icon-40"] : image/*acedrawingView.image*/ withFileName:[NSString stringWithFormat:@"%@|:|img",fileName]];
        }
    }];
    
    [controller addAction:confirm];
    
    [controller addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入文件名";
    }];
    
    UINavigationController *nav = [AppDelegate findNavigationController];
    [nav.visibleViewController presentViewController:controller animated:YES completion:NULL];
    
}

@end

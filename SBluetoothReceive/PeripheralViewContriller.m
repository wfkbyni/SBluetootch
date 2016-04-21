//
//  PeripheralViewContriller.m
//  BabyBluetoothAppDemo
//
//  Created by 刘彦玮 on 15/8/4.
//  Copyright (c) 2015年 刘彦玮. All rights reserved.
//

#import "PeripheralViewContriller.h"

#import "OperationTableViewController.h"

#import "CacheDataInfo.h"

#define width [UIScreen mainScreen].bounds.size.width
#define height [UIScreen mainScreen].bounds.size.height
#define channelOnPeropheralView @"peripheralView"

@interface PeripheralViewContriller ()<UITableViewDataSource,UITableViewDelegate>
{
    CBCharacteristic *currCharacteristic;
    
    int sendCount;
    
    // 缓存用的数据
    NSMutableArray *cacheDataArray;
    
    ACEDrawingView *acedrawingView;
    
}

// 是否连接到服务器
@property (nonatomic, assign) BOOL isConnection;
@end

@implementation PeripheralViewContriller{

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"数据测试";
    
    NSError *error = nil;
    NSString *path = [FCFileManager pathForDocumentsDirectoryWithPath:@"Data/"];
    if (![FCFileManager isDirectoryItemAtPath:path error:&error]) {
        BOOL isSuccess = [FCFileManager createDirectoriesForPath:path];
        NSLog(@"是否创建成功:%d",isSuccess);
    }
    
    self.myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, width, height - 200)];
    self.myTableView.dataSource = self;
    self.myTableView.delegate = self;
    [self.view addSubview:self.myTableView];
    
    acedrawingView = [[ACEDrawingView alloc] initWithFrame:CGRectMake(0, height - 200, width, 200)];
    [acedrawingView setBackgroundColor:[UIColor orangeColor]];
    acedrawingView.lineWidth = 2;
    acedrawingView.lineColor = [UIColor greenColor];
    [self.view addSubview:acedrawingView];
    
    __weak typeof(PeripheralViewContriller *) weakSelf = self;
    [acedrawingView startSendDrawData:^(NSMutableArray *drawData) {
        
        NSMutableArray *array = [NSMutableArray arrayWithArray:drawData];
        
        CacheDataInfo *info = [[CacheDataInfo alloc] init];
        info.value = @"020000";
        [array addObject:info];
        
        //[weakSelf writeData:array];
        
        NSString *fileName = [[NSDate date] stringWithFormat:@"yyyy-MM-dd hh:mm:ss"];
        
        [weakSelf archiverData:array withCacheName:[NSString stringWithFormat:@"%@-data",fileName]];
        [weakSelf saveImageToLocal:acedrawingView.image withFileName:[NSString stringWithFormat:@"%@-img",fileName]];
        
        [acedrawingView clear];
    }];
    
    //初始化
    self.services = [[NSMutableArray alloc]init];
    cacheDataArray = [NSMutableArray new];
    
    [self babyDelegate];
    

    [SVProgressHUD showInfoWithStatus:@"准备连接设备"];
    //开始扫描设备
    [self performSelector:@selector(loadData) withObject:nil afterDelay:2];
    
    UIButton *navLeftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [navLeftBtn setFrame:CGRectMake(0, 0, 30, 30)];
    [navLeftBtn setTitle:@"😸" forState:UIControlStateNormal];
    [navLeftBtn.titleLabel setTextColor:[UIColor blackColor]];
    //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:navLeftBtn];
    [navLeftBtn addTarget:self action:@selector(startArchiverData) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *navRightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [navRightBtn setFrame:CGRectMake(0, 0, 30, 30)];
    [navRightBtn setTitle:@"😸" forState:UIControlStateNormal];
    [navRightBtn.titleLabel setTextColor:[UIColor blackColor]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:navRightBtn];
    [navRightBtn addTarget:self action:@selector(operationCacheData) forControlEvents:UIControlEventTouchUpInside];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

//babyDelegate
-(void)babyDelegate{
    
    __weak typeof(self)weakSelf = self;
    BabyRhythm *rhythm = [[BabyRhythm alloc]init];
    
    //设置设备连接成功的委托,同一个baby对象，使用不同的channel切换委托回调
    [self.myBabyBluetooch setBlockOnConnectedAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral) {
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--连接成功",peripheral.name]];
        
    }];
    
    //设置设备连接失败的委托
    [self.myBabyBluetooch setBlockOnFailToConnectAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"设备：%@--连接失败",peripheral.name);
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--连接失败",peripheral.name]];
        [weakSelf performSelector:@selector(loadData) withObject:nil afterDelay:2];
    }];

    //设置设备断开连接的委托
    [self.myBabyBluetooch setBlockOnDisconnectAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"设备：%@--断开连接",peripheral.name);
        weakSelf.services = [[NSMutableArray alloc]init];
        
        [weakSelf performSelector:@selector(loadData) withObject:nil afterDelay:2];
    }];
    
    //设置发现设备的Services的委托
    [self.myBabyBluetooch setBlockOnDiscoverServicesAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, NSError *error) {
        for (CBService *s in peripheral.services) {
            ///插入section到tableview
            [weakSelf insertSectionToTableView:s];
            
        }
        
        [rhythm beats];
    }];
    //设置发现设service的Characteristics的委托
    [self.myBabyBluetooch setBlockOnDiscoverCharacteristicsAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        NSLog(@"===service name:%@",service.UUID);
        //插入row到tableview
        [weakSelf insertRowToTableView:service];
        
    }];
    
    //设置读取characteristics的委托
    [self.myBabyBluetooch setBlockOnReadValueForCharacteristicAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        NSLog(@"1 characteristic name:%@ value is:%@",characteristics.UUID,characteristics.value);
        
        NSString *value = [NSString stringWithFormat:@"%@",characteristics.value];
        
        value = [value stringByReplacingOccurrencesOfString:@"<" withString:@""];
        value = [value stringByReplacingOccurrencesOfString:@">" withString:@""];
        //if (weakSelf.isConnection) {
            [weakSelf sendMsg:value isCacheDate:YES];
        //}
        
    }];
    //设置发现characteristics的descriptors的委托
    [self.myBabyBluetooch setBlockOnDiscoverDescriptorsForCharacteristicAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"===characteristic name:%@",characteristic.service.UUID);
        for (CBDescriptor *d in characteristic.descriptors) {
            NSLog(@"CBDescriptor name is :%@",d.UUID);
        }
    }];
    //设置读取Descriptor的委托
    [self.myBabyBluetooch setBlockOnReadValueForDescriptorsAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
        NSLog(@"Descriptor name:%@ value is:%@",descriptor.characteristic.UUID, descriptor.value);
    }];
    
    
    //设置beats break委托
    [rhythm setBlockOnBeatsBreak:^(BabyRhythm *bry) {
        NSLog(@"setBlockOnBeatsBreak call");
        
        //如果完成任务，即可停止beat,返回bry可以省去使用weak rhythm的麻烦
//        if (<#condition#>) {
//            [bry beatsOver];
//        }
        
    }];
    
    //设置beats over委托
    [rhythm setBlockOnBeatsOver:^(BabyRhythm *bry) {
        NSLog(@"setBlockOnBeatsOver call");
    }];
    
    //扫描选项->CBCentralManagerScanOptionAllowDuplicatesKey:忽略同一个Peripheral端的多个发现事件被聚合成一个发现事件
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    /*连接选项->
     CBConnectPeripheralOptionNotifyOnConnectionKey :当应用挂起时，如果有一个连接成功时，如果我们想要系统为指定的peripheral显示一个提示时，就使用这个key值。
     CBConnectPeripheralOptionNotifyOnDisconnectionKey :当应用挂起时，如果连接断开时，如果我们想要系统为指定的peripheral显示一个断开连接的提示时，就使用这个key值。
     CBConnectPeripheralOptionNotifyOnNotificationKey:
     当应用挂起时，使用该key值表示只要接收到给定peripheral端的通知就显示一个提
    */
     NSDictionary *connectOptions = @{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES,
     CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES,
     CBConnectPeripheralOptionNotifyOnNotificationKey:@YES};
     
    [self.myBabyBluetooch setBabyOptionsAtChannel:channelOnPeropheralView scanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:connectOptions scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
}

-(void)loadData{
    [SVProgressHUD showInfoWithStatus:@"开始连接设备"];
    self.myBabyBluetooch.having(self.currPeripheral).and.channel(channelOnPeropheralView).then.connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
    //    baby.connectToPeripheral(self.currPeripheral).begin();
}

//读取设备数据
-(void)readPlantAssistantData{
    //写入当前系统时间
    //读取当前RecordStartTime（FFA2）RecordPeriod(FFAB) CurrentTime(FFA8)，ReadID（FFA4），ReadOT(FFA5)
    //设置ReadID,ReadOT
    //TransferStatus(FFA9) 写1
    //订阅RecordBuf(FFA1)数据
    CBCharacteristic *recordBuf = [BabyToy findCharacteristicFormServices:self.services UUIDString:NotifyUUID];

    if (recordBuf) {
        [self.currPeripheral setNotifyValue:YES forCharacteristic:recordBuf];
    }
}

#pragma mark -插入table数据
-(void)insertSectionToTableView:(CBService *)service{
    NSLog(@"搜索到服务:%@",service.UUID.UUIDString);
    PeripheralInfo *info = [[PeripheralInfo alloc]init];
    [info setServiceUUID:service.UUID];
    [self.services addObject:info];
    [self.myBabyBluetooch.allServers addObject:info];
    NSIndexSet *indexSet = [[NSIndexSet alloc]initWithIndex:self.services.count-1];
    [self.myTableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
}
    
-(void)insertRowToTableView:(CBService *)service{
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    int sect = -1;
    for (int i=0;i<self.services.count;i++) {
        PeripheralInfo *info = [self.services objectAtIndex:i];
        if (info.serviceUUID == service.UUID) {
            sect = i;
        }
    }
    
    if (sect != -1) {
        PeripheralInfo *info =[self.services objectAtIndex:sect];
        for (int row=0;row<service.characteristics.count;row++) {
            CBCharacteristic *c = service.characteristics[row];
            [info.characteristics addObject:c];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:sect];
            [indexPaths addObject:indexPath];
            NSLog(@"add indexpath in row:%d, sect:%d",row,sect);
        }
        PeripheralInfo *curInfo =[self.services objectAtIndex:sect];
        NSLog(@"%@",curInfo.characteristics);
        [self.myTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }

    [self readPlantAssistantData];
}

#pragma mark -Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.services.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    PeripheralInfo *info = [self.services objectAtIndex:section];
    return [info.characteristics count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CBCharacteristic *characteristic = [[[self.services objectAtIndex:indexPath.section] characteristics]objectAtIndex:indexPath.row];
    NSString *cellIdentifier = @"characteristicCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }

    cell.textLabel.text = [NSString stringWithFormat:@"%@",characteristic.UUID];
    cell.detailTextLabel.text = characteristic.description;
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 50)];
    PeripheralInfo *info = [self.services objectAtIndex:section];
    title.text = [NSString stringWithFormat:@"%@", info.serviceUUID];
    [title setTextColor:[UIColor whiteColor]];
    [title setBackgroundColor:[UIColor darkGrayColor]];
    return title;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    CharacteristicViewController *vc = [[CharacteristicViewController alloc]init];
//    vc.currPeripheral = self.currPeripheral;
//    vc.characteristic =[[[self.services objectAtIndex:indexPath.section] characteristics]objectAtIndex:indexPath.row];
//    vc->baby = baby;
//    [self.navigationController pushViewController:vc animated:YES];
}

- (void)sendMsg:(NSString *)msg isCacheDate:(BOOL)isCache{
    
    NSDateFormatter *df = [NSDateFormatter new];
    df.dateFormat = @"yyyy-MM-dd hh:mm:ss.SSSZ";
    NSString *dateStr = [df stringFromDate:[NSDate date]];
    
    CacheDataInfo *info = [[CacheDataInfo alloc] init];
    info.value = msg;
    info.date = dateStr;
    
    if (isCache) {
        NSDate *date = [df dateFromString:dateStr];
        long timeInterval1 = [date timeIntervalSince1970] * 1000;
        
        if (cacheDataArray != nil && cacheDataArray.count > 0) {
            CacheDataInfo *oldCacheDataInfo = cacheDataArray.lastObject;
            
            dateStr = oldCacheDataInfo.date;
            
            date = [df dateFromString:dateStr];
            
            long timeInterval2 = [date timeIntervalSince1970] * 1000;
            
            long timeInterval = timeInterval2 - timeInterval1;
            
            info.timeInterval = [NSNumber numberWithLong:timeInterval];
        }
    }
    
    if (msg.length == 6) {
        [cacheDataArray addObject:info];
    }
}

// 归档数据
- (void)startArchiverData{
    
    if (cacheDataArray.count == 0) {
        [SVProgressHUD showErrorWithStatus:@"没有数据，不能缓存"];
        return;
    }
    
    NSString *fileName = [[NSDate date] stringWithFormat:@"yyyy-MM-dd hh:mm:ss"];
    [self archiverData:cacheDataArray withCacheName:[NSString stringWithFormat:@"%@-data",fileName]];
    
    [self saveImageToLocal:[UIImage imageNamed:@"Icon-Small"] withFileName:[NSString stringWithFormat:@"%@-img",fileName]];
}

- (void)archiverData:(NSMutableArray *)archiverData withCacheName:(NSString *)name{
    
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    
    [archiver encodeObject:archiverData forKey:@"array"];
    
    [archiver finishEncoding];
    
    NSString *path = [FCFileManager pathForDocumentsDirectoryWithPath:@"Data/"];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",path, name];
    
    BOOL success = [data writeToFile:filePath atomically:YES];
    
    if (success) {
        [SVProgressHUD showSuccessWithStatus:@"数据缓存成功!"];
        [cacheDataArray removeAllObjects];
    }
}

// 解档数据
- (NSArray *)unarchiverDataWithName:(NSString *)fileName{
    NSString *path = [FCFileManager pathForDocumentsDirectoryWithPath:@"Data/"];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",path, fileName];
    
    NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    
    NSArray *array = [unarchiver decodeObjectForKey:@"array"];
    
    return array;
}

/*
 * 缓存图片到本地
 */
- (void)saveImageToLocal:(UIImage *)uiImage withFileName:(NSString *)fileName{
    NSString *path = [FCFileManager pathForDocumentsDirectoryWithPath:@"Data/"];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",path,fileName];
    
    // Write image to PNG
    [UIImagePNGRepresentation(uiImage) writeToFile:filePath atomically:YES];
    
    // Let's check to see if files were successfully written...
    
    // Create file manager
    NSError *error;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    // Write out the contents of home directory to console
    NSLog(@"Documents directory: %@", [fileMgr contentsOfDirectoryAtPath:path error:&error]);
}

- (void)operationCacheData{

    
    OperationTableViewController *controller = [[OperationTableViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)sendDataWithFileName:(NSString *)fileName{
    //while (YES) {
        NSArray *dataList = [self unarchiverDataWithName:fileName];
        //[self writeData:dataList];
    //}
}

//- (void)writeData:(NSArray *)dataList{
//    if (dataList != nil && dataList.count > 0) {
//        
//        for (int i = 0; i < dataList.count; i++) {
//            CacheDataInfo *obj = [dataList objectAtIndex:i];
//            NSLog(@"%@",[obj toJSONString]);
//            if (obj.value.length != 6) {
//                continue;
//            }
//            
//            sleep(ABS((int)[obj.timeInterval longLongValue] / 1000));
//            
//            currCharacteristic = [BabyToy findCharacteristicFormServices:self.services UUIDString:WriteDateUUID];
//            if (currCharacteristic == nil) {
//                currCharacteristic = [BabyToy findCharacteristicFormServices:self.services UUIDString:WriteDateUUID];
//            }
//            
//            if (currCharacteristic == nil) {
//                continue;
//            }
//            
//            NSData *data = [BabyToy stringToHex:obj.value];
//            [self.currPeripheral writeValue:data forCharacteristic:currCharacteristic type:CBCharacteristicWriteWithoutResponse];
//            NSLog(@"%@  ",self.currPeripheral);
//        }
//        
//    }
//    
//    [SVProgressHUD showSuccessWithStatus:@"数据发送完毕！"];
//}


@end

//
//  ViewController.m
//  SBluetoothReceive
//
//  Created by 舒永超 on 15/10/18.
//  Copyright © 2015年 sych. All rights reserved.
//

#import "BluetoochListController.h"
#import "PeripheralViewContriller.h"

#import "SBMachineConnectBusiness.h"

@interface BluetoochListController ()
{
    NSMutableArray *peripherals;
    NSMutableArray *peripheralsAD;
    BabyBluetooth *baby;
    
}
@end

@implementation BluetoochListController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"蓝牙列表";
    [SVProgressHUD showInfoWithStatus:@"准备打开设备"];
    
    //初始化其他数据 init other
    peripherals = [[NSMutableArray alloc]init];
    peripheralsAD = [[NSMutableArray alloc]init];
    
    //初始化BabyBluetooth 蓝牙库
    baby = [BabyBluetooth shareBabyBluetooth];
    [baby.allServers removeAllObjects];
    //设置蓝牙委托
    [self babyDelegate];
    
}

-(void)viewDidAppear:(BOOL)animated{
    NSLog(@"viewDidAppear");
    //停止之前的连接
    //[baby cancelAllPeripheralsConnection];
    //设置委托后直接可以使用，无需等待CBCentralManagerStatePoweredOn状态。
    baby.scanForPeripherals().begin();
    //baby.scanForPeripherals().begin().stop(10);
}

- (void)viewDidDisappear:(BOOL)animated{
    [baby cancelScan];
    
    NSLog(@"%@",baby.currPeripheral);
}


#pragma mark -蓝牙配置和操作
//蓝牙网关初始化和委托方法设置
-(void)babyDelegate{
    
    __weak typeof(self) weakSelf = self;
    [baby setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
        if (central.state == CBCentralManagerStatePoweredOn) {
            [SVProgressHUD showInfoWithStatus:@"设备打开成功，开始扫描设备"];
        }
    }];
    
    //设置扫描到设备的委托
    [baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        NSLog(@"搜索到了设备:%@",peripheral.name);
        [weakSelf insertTableView:peripheral advertisementData:advertisementData];
        NSLog(@"%@",peripheral.identifier.UUIDString);
        [weakSelf.tableView reloadData];
    }];
    
    //设置发现设备的Services的委托
    [baby setBlockOnDiscoverServices:^(CBPeripheral *peripheral, NSError *error) {
        for (CBService *service in peripheral.services) {
            NSLog(@"搜索到服务:%@",service.UUID.UUIDString);
        }
        //找到cell并修改detaisText
        for (int i=0;i < self->peripherals.count; i++) {
            UITableViewCell *cell = [weakSelf.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            if (cell.textLabel.text == peripheral.name) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu个service",(unsigned long)peripheral.services.count];
            }
        }
    }];
    //设置发现设service的Characteristics的委托
    [baby setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        NSLog(@"===service name:%@",service.UUID);
        for (CBCharacteristic *c in service.characteristics) {
            NSLog(@"charateristic name is :%@",c.UUID);
        }
    }];
    //设置读取characteristics的委托
    [baby setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        NSLog(@"characteristic name:%@ value is:%@",characteristics.UUID,characteristics.value);
    }];
    //设置发现characteristics的descriptors的委托
    [baby setBlockOnDiscoverDescriptorsForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"===characteristic name:%@",characteristic.service.UUID);
        for (CBDescriptor *d in characteristic.descriptors) {
            NSLog(@"CBDescriptor name is :%@",d.UUID);
        }
    }];
    //设置读取Descriptor的委托
    [baby setBlockOnReadValueForDescriptors:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
        NSLog(@"Descriptor name:%@ value is:%@",descriptor.characteristic.UUID, descriptor.value);
    }];
    
    //设置查找设备的过滤器
    [baby setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName) {
        
        //设置查找规则是名称大于1 ， the search rule is peripheral.name length > 2
//        if (peripheralName.length >2) {
//            return YES;
//        }
        return YES;
    }];
    
    
    [baby setBlockOnCancelAllPeripheralsConnectionBlock:^(CBCentralManager *centralManager) {
        NSLog(@"setBlockOnCancelAllPeripheralsConnectionBlock");
    }];
    
    [baby setBlockOnCancelScanBlock:^(CBCentralManager *centralManager) {
        NSLog(@"setBlockOnCancelScanBlock");
    }];
}

#pragma mark -UIViewController 方法
//插入table数据
-(void)insertTableView:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData{
    if(![peripherals containsObject:peripheral]){
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:peripherals.count inSection:0];
        [indexPaths addObject:indexPath];
        [peripherals addObject:peripheral];
        [peripheralsAD addObject:advertisementData];
//        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark -table委托 table delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return peripherals.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    CBPeripheral *peripheral = [peripherals objectAtIndex:indexPath.row];
    NSDictionary *ad = [peripheralsAD objectAtIndex:indexPath.row];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    //peripheral的显示名称,优先用kCBAdvDataLocalName的定义，若没有再使用peripheral name
    NSString *localName;
    if ([ad objectForKey:@"kCBAdvDataLocalName"]) {
        localName = [NSString stringWithFormat:@"%@",[ad objectForKey:@"kCBAdvDataLocalName"]];
    }else{
        localName = peripheral.name;
    }
    
    cell.textLabel.text = localName;
    //信号和服务
    cell.detailTextLabel.text = @"读取中...";
    //找到cell并修改detaisText
    NSArray *serviceUUIDs = [ad objectForKey:@"kCBAdvDataServiceUUIDs"];
    if (serviceUUIDs) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu个service %@",(unsigned long)serviceUUIDs.count,peripheral.identifier.UUIDString];
    }else{
        cell.detailTextLabel.text = [NSString stringWithFormat:@"0个service %@",peripheral.identifier.UUIDString];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //停止扫描
    [baby cancelScan];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    PeripheralViewContriller *vc = [[PeripheralViewContriller alloc]init];
    
    id currPeripheral = [peripherals objectAtIndex:indexPath.row];
    vc.currPeripheral = currPeripheral;
    baby.currPeripheral = currPeripheral;
    vc.myBabyBluetooch = baby;
    //[self.navigationController pushViewController:vc animated:YES];
 
    [self babyWithDelegate];
    
    [self loadData];
}


//babyDelegate
-(void)babyWithDelegate{
    
    __weak typeof(self)weakSelf = self;
    BabyRhythm *rhythm = [[BabyRhythm alloc]init];
    
    //设置设备连接成功的委托,同一个baby对象，使用不同的channel切换委托回调
    [baby setBlockOnConnected:^(CBCentralManager *central, CBPeripheral *peripheral) {
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--连接成功",peripheral.name]];
        
    }];
    
    //设置设备连接失败的委托
    [baby setBlockOnFailToConnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"设备：%@--连接失败",peripheral.name);
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--连接失败",peripheral.name]];
        [weakSelf performSelector:@selector(loadData) withObject:nil afterDelay:2];
    }];
    
    //设置设备断开连接的委托
    [baby setBlockOnDisconnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        
        NSLog(@"设备：%@--断开连接",peripheral.name);
        //weakSelf.services = [[NSMutableArray alloc]init];
        
        [weakSelf performSelector:@selector(loadData) withObject:nil afterDelay:2];
    }];
    
    //设置发现设备的Services的委托
    [baby setBlockOnDiscoverServices:^(CBPeripheral *peripheral, NSError *error) {
        for (CBService *s in peripheral.services) {
            ///插入section到tableview
            [weakSelf insertSectionToTableView:s];
            
        }
        
        [rhythm beats];
    }];
    
    //设置发现设service的Characteristics的委托
    [baby setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        NSLog(@"===service name:%@",service.UUID);
        //插入row到tableview
        [weakSelf insertRowToTableView:service];
        
    }];
    
    //设置读取characteristics的委托
    [baby setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"1 characteristic name:%@ value is:%@",characteristic.UUID,characteristic.value);
        
        NSString *value = [NSString stringWithFormat:@"%@",characteristic.value];
        
        value = [value stringByReplacingOccurrencesOfString:@"<" withString:@""];
        value = [value stringByReplacingOccurrencesOfString:@">" withString:@""];
        
        if ([value isEqualToString:@"dd000000"] || [value isEqualToString:@"dd000000 dd000000"]) {
            return ;
        }
        
        // 温度值
        [[NSNotificationCenter defaultCenter] postNotificationName:TemperatureValue object:value];
        
        SBMachineConnectBusiness *business = [[SBMachineConnectBusiness alloc] init];
        UserMessage *userMessage = [PublicMethod getReceiveUserMessage];
        [business sendData:value receiveUserId:userMessage.AccountId];
        
        //if (weakSelf.isConnection) {
        //[weakSelf sendMsg:value isCacheDate:YES];
        //}
    }];
    //设置发现characteristics的descriptors的委托
    [baby setBlockOnDiscoverDescriptorsForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"===characteristic name:%@",characteristic.service.UUID);
        for (CBDescriptor *d in characteristic.descriptors) {
            NSLog(@"CBDescriptor name is :%@",d.UUID);
        }
    }];
   
}

-(void)insertSectionToTableView:(CBService *)service{
    NSLog(@"搜索到服务:%@",service.UUID.UUIDString);
    PeripheralInfo *info = [[PeripheralInfo alloc]init];
    [info setServiceUUID:service.UUID];
    [baby.allServers addObject:info];
}

-(void)insertRowToTableView:(CBService *)service{
    int sect = -1;
    for (int i=0;i<baby.allServers.count;i++) {
        PeripheralInfo *info = [baby.allServers objectAtIndex:i];
        if (info.serviceUUID == service.UUID) {
            sect = i;
        }
    }
    
    if (sect != -1) {
        PeripheralInfo *info =[baby.allServers objectAtIndex:sect];
        for (int row=0;row<service.characteristics.count;row++) {
            CBCharacteristic *c = service.characteristics[row];
            [info.characteristics addObject:c];
        }
    }
    
    [self readPlantAssistantData];
}

-(void)loadData{
    [SVProgressHUD showInfoWithStatus:@"开始连接设备"];
    baby.having(baby.currPeripheral).connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
    //    baby.connectToPeripheral(self.currPeripheral).begin();
}

//读取设备数据
-(void)readPlantAssistantData{
    
    //订阅RecordBuf(FFA1)数据
    CBCharacteristic *recordBuf = [BabyToy findCharacteristicFormServices:baby.allServers UUIDString:NotifyUUID];
    
    if (recordBuf) {
        [baby.currPeripheral setNotifyValue:YES forCharacteristic:recordBuf];
    }
}


@end

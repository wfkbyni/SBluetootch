//
//  OperationTableViewController.m
//  SBluetoothReceive
//
//  Created by 舒永超 on 15/11/30.
//  Copyright © 2015年 sych. All rights reserved.
//

#import "OperationTableViewController.h"

#import "CacheDataInfo.h"
#import "BluetoothHelper.h"

@interface OperationTableViewController ()
{
    NSMutableArray *shakeImageData;
    NSMutableArray *shakeFileData;
    
    NSMutableArray *motorImageData;
    NSMutableArray *motorFileData;
    
    // 数据目录
    NSString *dataPath;
    
    CacheDataType cacehDataType;
    
    BluetoothHelper *bluetoothHelper;
    
    BOOL isSend;    // 是否发送数据
    BOOL isStop;
}
@end

@implementation OperationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"操作数据";
    
    dataPath = [FCFileManager pathForDocumentsDirectory];
    bluetoothHelper = [BluetoothHelper shareBluetoothHelper];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"清除所有" forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [button sizeToFit];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [UIAlertView alertWithTitles:@"删除提示" message:@"您确定要删除所有的数据吗?" clickBlock:^(UIAlertView *alertView, NSInteger clickIndex) {
            if (clickIndex != alertView.cancelButtonIndex) {
                [self deleteAllData];
            }
        } cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    }];
    
    self.myTableView.tableFooterView = [UIView new];
    self.myTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    cacehDataType = ShakeTypeData;
    [self registerCellXib];
    [self viewWithStyle];
    [self getAllCacheData];
    
    @weakify(self)
    [[self.shakeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self)
        
        cacehDataType = ShakeTypeData;
        [self viewWithStyle];
        [self registerCellXib];
        
        [self.myTableView reloadData];
    }];
    
    [[self.motorBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self)
        
        cacehDataType = MotorTypeData;
        [self viewWithStyle];
        [self registerCellXib];
        
        [self.myTableView reloadData];
    
    }];    
}

- (void)registerCellXib{
    if (cacehDataType == ShakeTypeData) {
        [self.myTableView registerNib:[UINib nibWithNibName:@"OperationShakeCell" bundle:nil] forCellReuseIdentifier:@"cell1"];
    }else{
        [self.myTableView registerNib:[UINib nibWithNibName:@"OperationCell" bundle:nil] forCellReuseIdentifier:@"cell2"];
    }
}

- (void)viewWithStyle{
    
    [self.blockView setBackgroundColor:[UIColor colorWithHexString:@"#fc4392"]];
    CGRect frame = self.blockView.frame;
    
    if (cacehDataType == ShakeTypeData) {
        [self.shakeBtn setTitleColor:[UIColor colorWithHexString:@"#fb3393"] forState:UIControlStateNormal];
        [self.motorBtn setTitleColor:[UIColor colorWithHexString:@"#666666"] forState:UIControlStateNormal];
        frame = CGRectMake(CGRectGetMinX(self.shakeBtn.frame) + 10,
                           CGRectGetHeight(self.shakeBtn.frame) - 5,
                           CGRectGetWidth(self.shakeBtn.frame) - 20, 5);
    }else if(cacehDataType == MotorTypeData){
        [self.shakeBtn setTitleColor:[UIColor colorWithHexString:@"#666666"] forState:UIControlStateNormal];
        [self.motorBtn setTitleColor:[UIColor colorWithHexString:@"#fb3393"] forState:UIControlStateNormal];
        frame = CGRectMake(CGRectGetMinX(self.motorBtn.frame) + 10,
                           CGRectGetHeight(self.motorBtn.frame) - 5,
                           CGRectGetWidth(self.motorBtn.frame) - 20, 5);
    }
    
    @weakify(self)
    [UIView transitionWithView:self.blockView duration:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        @strongify(self)
        self.blockView.frame = frame;
    } completion:NULL];
    
}

- (void)getAllCacheData{
    NSError *error;
    
    NSArray *allData = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dataPath error:&error];

    shakeImageData = [NSMutableArray new];
    shakeFileData = [NSMutableArray new];
    
    motorImageData = [NSMutableArray new];
    motorFileData = [NSMutableArray new];
    
    for (int i = 0; i < allData.count; i++) {
        NSString *obj = allData[i];
        
        if ([obj hasSuffix:[NSString stringWithFormat:@"|:|%lu|:|img",(unsigned long)ShakeTypeData]]) {
            [shakeImageData addObject:obj];
        }
        
        if ([obj hasSuffix:[NSString stringWithFormat:@"|:|%lu|:|data",(unsigned long)ShakeTypeData]]) {
            [shakeFileData addObject:obj];
        }
        
        if ([obj hasSuffix:[NSString stringWithFormat:@"|:|%lu|:|img",(unsigned long)MotorTypeData]]) {
            [motorImageData addObject:obj];
        }
        
        if ([obj hasSuffix:[NSString stringWithFormat:@"|:|%lu|:|data",(unsigned long)MotorTypeData]]) {
            [motorFileData addObject:obj];
        }
    }
    
    [self.myTableView reloadData];
}

- (void)deleteAllData{
    
    BOOL delete = [FCFileManager removeItemsInDirectoryAtPath:dataPath];
    if (delete) {
        [SVProgressHUD showSuccessWithStatus:@"删除成功!"];
        
        [shakeImageData removeAllObjects];
        [shakeFileData removeAllObjects];
        [self.myTableView reloadData];
    }
    
}

- (NSString *)getFilePathWithFileName:(NSString *)fileName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory
                                                         , NSUserDomainMask
                                                         , YES);
    NSString *filePath = [paths.firstObject stringByAppendingPathComponent:fileName];
    
    return filePath;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // >>>>>>>>>>>>>>>>>>>>> * cell自适应步骤1 * >>>>>>>>>>>>>>>>>>>>>>>>
    
    //[self.myTableView startAutoCellHeightWithCellClass:[OperationCell class] contentViewWidth:[UIScreen mainScreen].bounds.size.width];
    
    if (cacehDataType == ShakeTypeData) {
        return shakeFileData.count;
    }
    
    return motorFileData.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // >>>>>>>>>>>>>>>>>>>>> * cell自适应步骤2 * >>>>>>>>>>>>>>>>>>>>>>>>
    /* model 为模型实例， keyPath 为 model 的属性名，通过 kvc 统一赋值接口 */
    return 60;//[self.myTableView cellHeightForIndexPath:indexPath model:allFileData[indexPath.row] keyPath:@"data"];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *value;
    if (cacehDataType == ShakeTypeData) {
        value = shakeFileData[indexPath.row];
        
        OperationShakeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell1" forIndexPath:indexPath];
        
        [cell setLeftUtilityButtons:[self leftButtons] WithButtonWidth:60];
        cell.delegate = self;
        
        cell.data = value;
        cell.fileImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@/%@",dataPath,shakeImageData[indexPath.row]]];
        
        [[cell.sendBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            
            isSend = !isSend;
            
            NSString *fileName = value;
            
            [self sendDataWithFileName:fileName];
            
        }];
        return cell;
    }else{
        value = motorFileData[indexPath.row];
        
        OperationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell2" forIndexPath:indexPath];
        
        [cell setLeftUtilityButtons:[self leftButtons] WithButtonWidth:60];
        cell.delegate = self;
        
        cell.data = value;
        
        [[cell.sendBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            
            isSend = !isSend;
            
            NSString *fileName = value;
            
            [self sendDataWithFileName:fileName];
            
        }];
        return cell;
    }

    return nil;
}

/**
 *  @brief
 *
 *  @param fileName <#fileName description#>
 */
- (void)sendDataWithFileName:(NSString *)fileName{
    NSArray *dataList = [PublicMethod unarchiverDataWithName:fileName];
    
    dataList = [dataList subarrayWithRange:NSMakeRange(0, dataList.count - 1)];
    
    if (isSend) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            int i = 0;
            while (i < 1000) {
                i ++;
                for (CacheDataInfo *info in dataList) {

                    if (!isSend) {
                        
                        [self stopRuning];
                        break;
                    }else{
                        [NSThread sleepForTimeInterval:0.05];
                        [bluetoothHelper writeDataToDevice:info.value];
                        
                    }
                }
                if (!isSend) {
                    [self stopRuning];
                    break;
                }
            }
        });
    }else{
        [self stopRuning];
    }
}

/**
 *  @brief 停止运行
 */
- (void)stopRuning{
    NSArray *array = [NSArray new];
    
    [bluetoothHelper writeDataToDevice:array withIsCache:bluetoothHelper.isStartCacheData];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (NSArray *)leftButtons
{
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    
    UIColor *color = [UIColor colorWithRed:215.0f / 255.0f green:217.0f / 255.0f blue:218.0f/255.0f alpha:1];
    
    [leftUtilityButtons sw_addUtilityButtonWithColor:color icon:[UIImage imageNamed:@"delete_off"]];
    [leftUtilityButtons sw_addUtilityButtonWithColor:color icon:[UIImage imageNamed:@"upload_off"]];
    
    return leftUtilityButtons;
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell{
    return YES;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index{

    switch (index) {
        case 0:{
            // Delete button was pressed
            NSIndexPath *cellIndexPath = [self.myTableView indexPathForCell:cell];
            
            NSString *fileName;
            NSString *imageName;
            
            if (cacehDataType == ShakeTypeData) {
                fileName = shakeFileData[cellIndexPath.row];
                imageName = shakeImageData[cellIndexPath.row];
                
                [shakeFileData removeObjectAtIndex:cellIndexPath.row];
                [shakeImageData removeObjectAtIndex:cellIndexPath.row];
            }else if(cacehDataType == MotorTypeData){
                fileName =  motorFileData[cellIndexPath.row];
                imageName = motorImageData[cellIndexPath.row];
                
                [motorFileData removeObjectAtIndex:cellIndexPath.row];
                [motorImageData removeObjectAtIndex:cellIndexPath.row];
            }
            
            
            NSError *error = nil;
            BOOL deleteFile = [FCFileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@",dataPath,fileName]  error:&error];
            
            BOOL deleteImage = [FCFileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@",dataPath,imageName] error:&error];
            
            if (deleteFile && deleteImage) {
                DebugLog(@"%@",@"删除成功");
                [self.myTableView beginUpdates];
                [self.myTableView deleteRowsAtIndexPaths:@[cellIndexPath]
                                        withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.myTableView endUpdates];
                
                [self.myTableView reloadData];
            }
            
        }
            break;
        case 1:{
            [SVProgressHUD showErrorWithStatus:@"上传功能请稍候..."];
        }
            break;
        default:
            break;
    }
}

@end

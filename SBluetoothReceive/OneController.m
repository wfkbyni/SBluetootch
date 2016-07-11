//
//  OneController.m
//  SBluetoothReceive
//
//  Created by Mac on 15/12/9.
//  Copyright © 2015年 sych. All rights reserved.
//

#import "OneController.h"

#import "ACEDrawingView.h"
#import "CacheDataInfo.h"
#import "AppDelegate.h"
#import "BluetoothHelper.h"

#import "BluetoochListController.h"
#import "OperationTableViewController.h"

#import "MySlider.h"
#import "SBMachineConnectBusiness.h"

#define dateformat @"yyyy-MM-dd hh:mm:ss.SSSZ"

@interface OneController ()
{
    // 指画view
    ACEDrawingView *acedrawingView;
    
    UIImage *acedrawingImage;
    
    NSMutableArray *cacheDatas;
    
    MySlider *mySlider;
    
    // 选中的哪一个选项 1,震动 2电机
    int selectItem;
    
    CacheDataType cacheDataType;
}
@property (nonatomic, strong) BluetoothHelper *bluetoothHelper;
@end

@implementation OneController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    selectItem = 1;
    [self viewWithStyle];
    
    [appDelegate connectionSocketAndSendData:SocketCommandConnect receiveUserId:nil data:nil];
    
//    SBMachineConnectBusiness *business = [[SBMachineConnectBusiness alloc] init];
//    UserMessage *userMessage = [PublicMethod getReceiveUserMessage];
//    while (YES) {
//        [NSThread sleepForTimeInterval:0.05];
//        
//        [business sendData:@"dd0000" receiveUserId:userMessage.AccountId];
//    }
    
    self.title = @"单人";
    
    _bluetoothHelper = [BluetoothHelper shareBluetoothHelper];
    cacheDatas = [NSMutableArray new];
    
    [self addDrawingView];
    
    @weakify(self)
    [[self.fileBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self)
        OperationTableViewController *controller = [OperationTableViewController new];
        [self.navigationController pushViewController:controller animated:YES];
    }];
    
    [[self.cacheBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self)
        NSString *value = self.cacheBtn.titleLabel.text;
        
        if (_bluetoothHelper.isStartCacheData) {
            
            [[NSUserDefaults standardUserDefaults] setObject:@"EndCache" forKey:@"ShakeDataCache"];
            
            if (_bluetoothHelper.cacheDatas.count == 0) {
                
                _bluetoothHelper.isStartCacheData = NO;
                
                [self.cacheBtn setImage:[UIImage imageNamed:@"cachewithstart_off"] forState:UIControlStateNormal];
                [self.cacheBtn setImage:[UIImage imageNamed:@"cachewithstart_on"] forState:UIControlStateHighlighted];
                [SVProgressHUD showErrorWithStatus:@"数据为空，不能缓存"];
                return ;
            }
            
            [_bluetoothHelper showFileNameAlert:cacheDataType withCacheImage:acedrawingImage];
            
            [self.cacheBtn setImage:[UIImage imageNamed:@"cachewithstart_off"] forState:UIControlStateNormal];
            [self.cacheBtn setImage:[UIImage imageNamed:@"cachewithstart_on"] forState:UIControlStateHighlighted];
        }else{
            
            [[NSUserDefaults standardUserDefaults] setObject:@"StartCache" forKey:@"ShakeDataCache"];
            
            [_bluetoothHelper.cacheDatas removeAllObjects];
            
            [self.cacheBtn setImage:[UIImage imageNamed:@"cachewithend_off"] forState:UIControlStateNormal];
            [self.cacheBtn setImage:[UIImage imageNamed:@"cachewithend_on"] forState:UIControlStateHighlighted];
        }
        
        _bluetoothHelper.isStartCacheData = !_bluetoothHelper.isStartCacheData;
        
        [self.cacheBtn setTitle:value forState:UIControlStateNormal];
    }];
    
    [[self.shakeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
       @strongify(self)
        [_bluetoothHelper.cacheDatas removeAllObjects];
        
        selectItem = 1;
        [self viewWithStyle];
        
        [self showHidden];
        
        cacheDataType = ShakeTypeData;

    }];
    
    [[self.motorBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
       @strongify(self)
        
        [_bluetoothHelper.cacheDatas removeAllObjects];
        
        selectItem = 2;
        [self viewWithStyle];
        
        [self showHidden];
        
        cacheDataType = MotorTypeData;
        
    }];
    
    if (mySlider == nil) {
        mySlider = [[MySlider alloc] init];
        [self.sliderView addSubview:mySlider];
        
        [mySlider startSendSliderDrawData:^(NSString *drawData) {
            if (drawData != nil) {
                
                [_bluetoothHelper cacheDataWithMsg:drawData withTimeIntervalSince:0];
                
                [_bluetoothHelper writeDataToDevice:drawData];
            }
        }];

    }
    
    [[self.connBluetoothBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        BluetoochListController *controller = [BluetoochListController new];
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self showHidden];
}

- (void)showHidden{
    BOOL isConnection = NO;//[self isConnectionBluetooth];
    
    if (isConnection) {
        acedrawingView.hidden = YES;
        self.sliderView.hidden = YES;
        
        self.alertView.hidden = NO;
    }else{
        self.alertView.hidden = YES;
        
        if (selectItem == 1) {
            acedrawingView.hidden = NO;
            self.sliderView.hidden = YES;
        }else if(selectItem == 2){
            acedrawingView.hidden = YES;
            self.sliderView.hidden = NO;
        }
    }
}

- (void)viewWithStyle{
    
    [self.blockView setBackgroundColor:[UIColor colorWithHexString:@"#fc4392"]];
    CGRect frame = self.blockView.frame;
    
    if (selectItem == 1) {
        [self.shakeBtn setTitleColor:[UIColor colorWithHexString:@"#fb3393"] forState:UIControlStateNormal];
        [self.motorBtn setTitleColor:[UIColor colorWithHexString:@"#666666"] forState:UIControlStateNormal];
        frame = CGRectMake(CGRectGetMinX(self.shakeBtn.frame) + 10,
                           CGRectGetHeight(self.shakeBtn.frame) - 5,
                           CGRectGetWidth(self.shakeBtn.frame) - 20, 5);
    }else if(selectItem == 2){
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

/**
 *  @brief 添加指画view
 */
- (void)addDrawingView{
    
    acedrawingView = [[ACEDrawingView alloc] initWithFrame:CGRectMake(0, ScreenSize.height - 200 - 100 - 30, ScreenSize.height, 200) withisHiddenBtn:YES];
    [acedrawingView setBackgroundColor:[UIColor orangeColor]];
    acedrawingView.lineWidth = 2;
    acedrawingView.lineColor = [UIColor greenColor];
    [self.view addSubview:acedrawingView];
    
    __weak typeof(OneController) *weakSelf = self;
    [acedrawingView startSendDrawData:^(NSMutableArray *drawData) {
        
        [weakSelf.bluetoothHelper writeDataToDevice:drawData withIsCache:_bluetoothHelper.isStartCacheData];
        
        acedrawingImage = acedrawingView.image;
        
        [acedrawingView clear];
    }];
    
    
    [acedrawingView setSendControlValue:^(NSString *value) {
        if ([value isEqualToString:@"BB01"]) {
            [[NSNotificationCenter defaultCenter] addObserver:weakSelf selector:@selector(updateTemperatureValue:) name:TemperatureValue object:nil];
        }else if([value isEqualToString:@"BC01"]){
        
        }else if([value isEqualToString:@"BC02"]){
            
        }else if([value isEqualToString:@"BC03"]){
            
        }else{
            [[NSNotificationCenter defaultCenter] removeObserver:weakSelf name:TemperatureValue object:nil];
        }
        [weakSelf.bluetoothHelper writeDataToDevice:value];
        
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%@值已发送",value]];
    }];
    
    self.sliderView.frame = acedrawingView.frame;
    self.alertView.frame = acedrawingView.frame;
        
    [self.connBluetoothBtn setCornerRadius:10];
}

- (void)updateTemperatureValue:(NSNotification *)notification{
    NSString * value = notification.object;
    
    UILabel *label = (UILabel *)[acedrawingView viewWithTag:99];
    if (label) {
        [label setText:[NSString stringWithFormat:@"%.1f",(CGFloat)[value integerValue] / 10]];
    }
}
@end

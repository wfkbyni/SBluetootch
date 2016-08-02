//
//  SettingController.m
//  SBluetoothReceive
//
//  Created by 舒永超 on 15/12/10.
//  Copyright © 2015年 sych. All rights reserved.
//

#import "SettingController.h"

#import "AppDelegate.h"

#import "BluetoochListController.h"
#import "UpdatePwdController.h"
#import "UserInfoController.h"
#import "LoginController.h"
#import "AboutController.h"
#import "ShopController.h"

#import "BluetoothHelper.h"
#import "SettingCell.h"

@interface SettingController (){
    NSArray *titleArray;
    NSArray *controllerArray;
    NSArray *leftImageArray;
    NSArray *rightImageArray;
    
    BluetoothHelper *bluetoothHelper;
    
    NSString *bluetoothImageName;
}

@end

@implementation SettingController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"设置";
    
    bluetoothHelper = [BluetoothHelper shareBluetoothHelper];
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"SettingCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    [self.myTableView setTableFooterView:[self footerView]];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (![bluetoothHelper isConnectionBluetooth]) {
        bluetoothImageName = @"bluetooth_p";
    }else{
        bluetoothImageName = @"bluetooth";
    }
    
    [self loadConfigData];
}

- (void)loadConfigData{
    leftImageArray = @[@[[UIImage imageNamed:@"link"],[UIImage imageNamed:@"shock_1"]],
                       @[[UIImage imageNamed:@"message"],[UIImage imageNamed:@"about"],[UIImage imageNamed:@"shop"],[UIImage imageNamed:@"modify_password"]]];
    rightImageArray = @[@[[UIImage imageNamed:bluetoothImageName],[UIImage imageNamed:@"shock_off"]],
                        @[[UIImage imageNamed:@"arrow"],[UIImage imageNamed:@"arrow"],[UIImage imageNamed:@"arrow"],[UIImage imageNamed:@"arrow"]]];
    
    titleArray = @[@[@"连接设备",@"震动消息接收方式"],@[@"个人信息", @"修改密码",@"妄想商城",@"关于我们"]];
    
    controllerArray = @[@[@"BluetoochListController",@""],@[@"RecordViewController",@"UpdatePwdController",@"ShopController",@"UpdateInfoController"]];//AboutController
    
    [self.myTableView reloadData];
}


/**
 *  footerview
 *
 *  @return <#return value description#>
 */
- (UIView *)footerView{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenSize.width, 60)];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(20, 10, ScreenSize.width - 40, 40)];
    
    [button setTitle:@"退出登录" forState:UIControlStateNormal];
    
    [button setCornerRadius:10];
    
    [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"提示" message:@"您确定要退出当前登录账号吗?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:NULL];
        UIAlertAction *exit = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self exitLoginAction];
        }];
        [controller addAction:cancel];
        [controller addAction:exit];
        [self presentViewController:controller animated:YES completion:NULL];
    }];
    
    [footerView addSubview:button];
    
    return footerView;
}

//section头部间距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == titleArray.count - 1) {
        return 30;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return titleArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [titleArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.contentLabel.text = titleArray[indexPath.section][indexPath.row];
    
    UIImage *image = leftImageArray[indexPath.section][indexPath.row];
    cell.leftImageView.image = image;
    
    image = rightImageArray[indexPath.section][indexPath.row];
    cell.rightImageView.image = image;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *controllerName = controllerArray[indexPath.section][indexPath.row];
    Class class = NSClassFromString(controllerName);
    
    UIViewController *controller = [[class alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/**
 *  @brief 退出
 */
- (void)exitLoginAction{
    NSString *accoutId = [PublicMethod getLoginUserMessage].AccountId;
    
    NSDictionary *param = @{@"AccountId":accoutId};
    
    [[HttpClientHelper sharedInstance] post:LoginWithSignOut resultType:[BaseResponseModel class] parameters:param success:^(BaseResponseModel *result) {
        
        if ([result Success]) {
            
            [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:YES completion:^(NSDictionary *info, EMError *error) {
                if (!error) {
                    
                    //[[NSUserDefaults standardUserDefaults] setValue:nil forKey:LOGINUSERMESSAGE];
                    
                    CustomNavigationController *nav = [[CustomNavigationController alloc] initWithRootViewController:[LoginController new]];
                    [[appDelegate window] setRootViewController:nav];
                }
            } onQueue:nil];
            
        }else{
            [SVProgressHUD showErrorWithStatus:result.Message];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    } showLoading:YES];
}

@end

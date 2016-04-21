//
//  TwoController.m
//  SBluetoothReceive
//
//  Created by Mac on 15/12/9.
//  Copyright © 2015年 sych. All rights reserved.
//

#import "TwoController.h"

#import "JoinQuitPlayController.h"
#import "FriendsListController.h"

@interface TwoController ()
@end

@implementation TwoController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"双人";
    
    [self bindEvent];
    
}

- (void)bindEvent{
    
    @weakify(self)
    // 挂起
    [[self.onlineBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self)
        JoinQuitPlayController *controller = [[JoinQuitPlayController alloc] init];
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }];
    
    // 好友
    [[self.friendBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self)
        FriendsListController *controller = [[FriendsListController alloc] init];
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }];
}

@end

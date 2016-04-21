//
//  FriendMessageController.m
//  SBluetoothReceive
//
//  Created by 舒永超 on 16/1/24.
//  Copyright © 2016年 sych. All rights reserved.
//

#import "FriendMessageController.h"

@interface FriendMessageController ()

@end

@implementation FriendMessageController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"用户信息";
    
    [self setup];
}

- (void)setup{
    NSURL *url = [self.userMessage getUrlPicPath];
    [self.headBackgroundImageView sd_setImageWithURL:url];
    self.headBackgroundImageView.layer.cornerRadius = CGRectGetWidth(self.headBackgroundImageView.frame) / 2;
    self.headBackgroundImageView.layer.masksToBounds = YES;
    
    self.userName.text = self.userMessage.NickName;
    
    [self.addFriendBtn setCornerRadius:10];
    
    // 添加好友
    [[self.addFriendBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        UserMessage *message = [PublicMethod getLoginUserMessage];
        [RequestStaticMethod joinFriendAction:message.AccountId with:self.userMessage.AccountId];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

//
//  FriendMessageController.h
//  SBluetoothReceive
//
//  Created by 舒永超 on 16/1/24.
//  Copyright © 2016年 sych. All rights reserved.
//

#import "BaseController.h"

@interface FriendMessageController : BaseController

@property (nonatomic, strong) UserMessage *userMessage;

@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UIImageView *headBackgroundImageView;

@property (weak, nonatomic) IBOutlet UIButton *addFriendBtn;
@end

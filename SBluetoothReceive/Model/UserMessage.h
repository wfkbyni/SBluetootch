//
//  UserMessage.h
//  SBluetoothReceive
//
//  Created by 舒永超 on 15/12/2.
//  Copyright © 2015年 sych. All rights reserved.
//

#import "BaseResponseModel.h"

@interface UserMessage : BaseResponseModel

@property (nonatomic, strong) NSString *AccountId;

@property (nonatomic, strong) NSString *Phone;

@property (nonatomic, strong) NSString *NickName;

@property (nonatomic, strong) NSString *Country;

@property (nonatomic, strong) NSString *Sex;

@property (nonatomic, strong) NSString *Avatar;

@property (nonatomic, strong) NSString *LastLoginTime;

@property (nonatomic, assign) BOOL IsMyFriend; //是否是我的好友

// 得到完整路径url
- (NSURL *)getUrlPicPath;

- (NSString *)getStrPicPath;

@end

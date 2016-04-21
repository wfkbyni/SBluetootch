//
//  RequestMethod.h
//  SBluetoothReceive
//
//  Created by Mac on 15/12/2.
//  Copyright © 2015年 sych. All rights reserved.
//

#ifndef RequestMethod_h
#define RequestMethod_h

// 1.	用户登录
#define LoginWithLogin @"/Login/Login"

// 2.	用户注册
#define  LoginWithRegiste @"/Login/Registe"

// 3.	发送验证码
#define LoginWithSmsCode @"/Login/SmsCode"

// 4.	加入一起玩
#define FriendsWithJoin @"/Friends/PlayTogether/Join"

// 5.	退出一起玩
#define FriendsWithQuit @"/Friends/PlayTogether/Quit"

// 6.	添加好友
#define FriendsWithAdd @"/Friends/Friend/Add"

// 7.	选择性别
//#define AccountWithUpdateInfo @"/Account/Account/UpdateInfo"   /// 已废弃

// 8.	删除好友
#define FriendsWithDelete @"/Friends/Friend/Delete"

// 9.	好友列表
#define FriendsWithGetFriendsList @"/Friends/Friend/GetFriendsList"

// 10.	一起玩列表
#define FriendsWithGetPlayList @"/Friends/PlayTogether/GetPlayList"

// 11.	陌生人列表
#define FriendsWithGetStrangerList @"/Friends/PlayTogether/GetStrangerList"

// 12.  修改资料
#define AccountWithUpdateInfo @"/Account/Account/UpdateInfo"

// 13.	退出登录
#define LoginWithSignOut @"/Login/SignOut"

// 14.	连接设备
#define AccoutWithActive @"/Account/AccountMachine/Active"

// 15.	断开设备
#define AccoutWithDeActive @"/Account/AccountMachine/DeActive"

// 16.	修改密码
#define LoginWithUpdatePwd @"/Login/UpdatePwd"

// 17.	找回密码
#define LoginWithFindBackPwd @"/Login/FindBackPwd"

// 18.	好友信息
#define FriendsWithGetFriendInfo @"/Friends/Friend/GetFriendInfo"

// 19.	能否联机
#define FriendsWithCanPlay @"/Friends/OnlinePlaying/CanPlay"

// 20.  建立联机
#define FriendsWithOnlinePlayingAdd @"/Friends/OnlinePlaying/Add"

// 21.	断开联机
#define FriendsWithUnPlaying @"/Friends/OnlinePlaying/UnPlaying"

#endif /* RequestMethod_h */

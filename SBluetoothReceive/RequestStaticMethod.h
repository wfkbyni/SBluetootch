//
//  RequestStaticMethod.h
//  SBluetoothReceive
//
//  Created by 舒永超 on 15/12/15.
//  Copyright © 2015年 sych. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RequestStaticMethod : NSObject

/**
 *  加好友 
 *      sendAccoutId发送方id
 *      receiveAccoutId接收方id
 **/
+ (void)joinFriendAction:(NSString *)sendAccoutId with:(NSString *)receiveAccoutId;

/**
 *  加入或退出一起玩
 *
 *  @param methodName 标记是加入一起玩，还是退出一起玩
 */
+ (void)joinOrQuitPlay:(NSString *)methodName;
@end

//
//  FriendsModel.h
//  SBluetoothReceive
//
//  Created by Mac on 15/12/3.
//  Copyright © 2015年 sych. All rights reserved.
//

#import "BaseResponseModel.h"
#import "UserMessage.h"

@interface FriendsModel : BaseResponseModel

@property (nonatomic, assign) NSArray *Items;

@property BOOL HasJoin;

@property int Total;

@end

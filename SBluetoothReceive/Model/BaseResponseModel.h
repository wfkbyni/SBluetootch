//
//  BaseResponseModel.h
//  SBluetoothReceive
//
//  Created by 舒永超 on 15/12/2.
//  Copyright © 2015年 sych. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface BaseResponseModel : JSONModel

@property BOOL Success;

@property (nonatomic, strong) NSString *Message;

@end

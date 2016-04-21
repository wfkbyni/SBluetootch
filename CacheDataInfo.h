//
//  CacheDataInfo.h
//  SBluetoothReceive
//
//  Created by 舒永超 on 15/11/11.
//  Copyright © 2015年 sych. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CacheDataInfo : JSONModel<NSCoding>

@property (nonatomic, copy) NSString *value;
@property (nonatomic, copy) NSString *date;

@property (nonatomic, copy) NSNumber *timeInterval;

@end

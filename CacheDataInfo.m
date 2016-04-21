//
//  CacheDataInfo.m
//  SBluetoothReceive
//
//  Created by 舒永超 on 15/11/11.
//  Copyright © 2015年 sych. All rights reserved.
//

#import "CacheDataInfo.h"

@implementation CacheDataInfo

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    if (self = [super init]) {
        _value = [aDecoder decodeObjectForKey:@"value"];
        _date = [aDecoder decodeObjectForKey:@"date"];
        _timeInterval = [aDecoder decodeObjectForKey:@"timeInterval"];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.value forKey:@"value"];
    [aCoder encodeObject:self.date forKey:@"date"];
    [aCoder encodeObject:self.timeInterval forKey:@"timeInterval"];
}

@end

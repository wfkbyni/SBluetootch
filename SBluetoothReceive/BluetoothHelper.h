//
//  BluetoothHelper.h
//  SBluetoothReceive
//
//  Created by 舒永超 on 16/1/26.
//  Copyright © 2016年 sych. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    ShakeTypeData,  // 震动类型数据
    MotorTypeData,  // 电机类型数据
} CacheDataType;

@interface BluetoothHelper : NSObject

+ (BluetoothHelper *)shareBluetoothHelper;

// 缓存的数据集
@property (nonatomic, strong) NSMutableArray *cacheDatas;

// 是否开始缓存数据
@property (nonatomic, assign) BOOL isStartCacheData;

/**
 *  @brief 是否连接蓝牙
 *
 *  @return <#return value description#>
 */
- (BOOL)isConnectionBluetooth;

/**
 *  @brief 写数据到硬件，是否缓存数据
 *
 *  @param data    数据
 *  @param isCache 是否缓存数据
 */
- (void)writeDataToDevice:(NSArray *)data withIsCache:(BOOL)isCache;

/**
 *  @brief 写数据到硬件
 *
 *  @param changeValue <#changeValue description#>
 */
- (void)writeDataToDevice:(NSString *)changeValue;


/**
 *  @brief 缓存电机数据
 *
 *  @param msg          <#msg description#>
 *  @param timeInterval <#timeInterval description#>
 */
#warning 注意 这里的timeInterval是在手机上操作的时候加的延迟时间 ，硬件上无效
- (void)cacheDataWithMsg:(NSString *)msg withTimeIntervalSince:(int)timeInterval;

/**
 *  @brief 显示文件输入框
 */
- (void)showFileNameAlert:(CacheDataType)cacheDataType withCacheImage:(UIImage *)image;

@end

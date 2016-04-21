//
//  ALAssetExtension.h
//  家师傅
//
//  Created by pactera on 15/5/22.
//  Copyright (c) 2015年 酬城网络. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ALAsset (ALAssetExtension)

///获取实体数据
- (NSData *)getData:(NSString **)fileName mimeType:(NSString **)mimeType;

@end

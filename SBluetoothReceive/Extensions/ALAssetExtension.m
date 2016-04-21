//
//  ALAssetExtension.m
//  家师傅
//
//  Created by pactera on 15/5/22.
//  Copyright (c) 2015年 酬城网络. All rights reserved.
//

#import "ALAssetExtension.h"
#import "NSStringExtension.h"

@implementation ALAsset (ALAssetExtension)

- (NSData *)getData:(NSString **)fileName mimeType:(NSString **)mimeType{
    ALAssetRepresentation *rep = self.defaultRepresentation;
    *fileName = [rep filename];
    *mimeType = [*fileName mimeType];
    unsigned long repSize = (unsigned long)rep.size;
    Byte *buffer = (Byte *)malloc(repSize);
    NSUInteger length = [rep getBytes:buffer fromOffset:0 length:repSize error:nil];
    
    NSData *data = [NSData dataWithBytesNoCopy:buffer length:length freeWhenDone:YES];
    return data;
}

@end

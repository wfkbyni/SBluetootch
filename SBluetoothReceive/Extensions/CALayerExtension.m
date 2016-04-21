//
//  CALayerExtension.m
//  短线精灵
//
//  Created by XIONGWANG on 15/8/16.
//  Copyright (c) 2015年 毛君. All rights reserved.
//

#import "CALayerExtension.h"

@implementation CALayer (CALayerExtension)

- (void)removeAllLayers{
    for (CALayer *layer in [self.sublayers copy]) {
        [layer removeFromSuperlayer];
    }
}

@end

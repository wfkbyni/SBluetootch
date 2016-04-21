//
//  OperationShakeCell.m
//  SBluetoothReceive
//
//  Created by 舒永超 on 16/2/14.
//  Copyright © 2016年 sych. All rights reserved.
//

#import "OperationShakeCell.h"

@implementation OperationShakeCell

-(void)setData:(NSString *)data{
    NSArray *array = [data componentsSeparatedByString:@"|:|"];
    if (array != nil && array.count > 0) {
        self.fileName.text = array[0];
        self.fileDate.text = array[1];
    }
}

@end

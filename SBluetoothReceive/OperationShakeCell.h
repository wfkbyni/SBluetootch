//
//  OperationShakeCell.h
//  SBluetoothReceive
//
//  Created by 舒永超 on 16/2/14.
//  Copyright © 2016年 sych. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"

@interface OperationShakeCell : SWTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *fileName;
@property (weak, nonatomic) IBOutlet UILabel *fileDate;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UIImageView *fileImage;

@property (nonatomic, strong) NSString *data;

@end

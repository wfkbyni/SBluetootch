//
//  OperationCell.h
//  SBluetoothReceive
//
//  Created by 舒永超 on 16/1/18.
//  Copyright © 2016年 sych. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"

@interface OperationCell : SWTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *fileName;
@property (weak, nonatomic) IBOutlet UILabel *fileDate;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;

@property (nonatomic, strong) NSString *data;

@end

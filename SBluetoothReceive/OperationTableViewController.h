//
//  OperationTableViewController.h
//  SBluetoothReceive
//
//  Created by 舒永超 on 15/11/30.
//  Copyright © 2015年 sych. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseController.h"
#import "OperationCell.h"
#import "OperationShakeCell.h"

@interface OperationTableViewController : BaseController<SWTableViewCellDelegate>


@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UIButton *shakeBtn;
@property (weak, nonatomic) IBOutlet UIButton *motorBtn;
@property (weak, nonatomic) IBOutlet UIView *blockView;

@end

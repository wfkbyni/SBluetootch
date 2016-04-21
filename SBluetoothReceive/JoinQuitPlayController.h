//
//  JoinQuitPlayController.h
//  SBluetoothReceive
//
//  Created by Mac on 15/12/3.
//  Copyright © 2015年 sych. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseController.h"

@interface JoinQuitPlayController : BaseController

@property (weak, nonatomic) IBOutlet UITableView *myTableView;

- (void)getPlayList;


@end

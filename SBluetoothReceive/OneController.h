//
//  OneController.h
//  SBluetoothReceive
//
//  Created by Mac on 15/12/9.
//  Copyright © 2015年 sych. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseController.h"

@interface OneController : BaseController

@property (weak, nonatomic) IBOutlet UIButton *shakeBtn;
@property (weak, nonatomic) IBOutlet UIButton *motorBtn;

@property (weak, nonatomic) IBOutlet UIView *sliderView;
@property (weak, nonatomic) IBOutlet UIView *alertView;

@property (weak, nonatomic) IBOutlet UIButton *fileBtn;
@property (weak, nonatomic) IBOutlet UIButton *cacheBtn;
@property (weak, nonatomic) IBOutlet UIView *blockView;
@property (weak, nonatomic) IBOutlet UIButton *connBluetoothBtn;

@end

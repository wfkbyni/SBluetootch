//
//  UserInfoController.h
//  SBluetoothReceive
//
//  Created by 舒永超 on 15/12/15.
//  Copyright © 2015年 sych. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseController.h"

@interface UserInfoController : BaseController
<UIActionSheetDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *headBtn;
@property (weak, nonatomic) IBOutlet UITextField *nickName;
@property (weak, nonatomic) IBOutlet UIButton *sexBtn;

@property (weak, nonatomic) IBOutlet UIButton *confrimEditBtn;

@end

//
//  UpdateSexController.h
//  SBluetoothReceive
//
//  Created by Mac on 15/12/2.
//  Copyright © 2015年 sych. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UpdateInfoController : BaseController<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *manBtn;
@property (weak, nonatomic) IBOutlet UIButton *woman;

@property (weak, nonatomic) IBOutlet UIButton *headBtn;

@property (weak, nonatomic) IBOutlet UITextField *nickName;

@property (weak, nonatomic) IBOutlet UIButton *confrimEditBtn;
@property (weak, nonatomic) IBOutlet UIButton *nationalityBtn;

@end

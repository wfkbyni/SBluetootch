//
//  UpdateSexController.m
//  SBluetoothReceive
//
//  Created by Mac on 15/12/2.
//  Copyright © 2015年 sych. All rights reserved.
//

#import "UpdateInfoController.h"
#import "HttpClientHelper/HttpClientFileModel.h"
#import "AppDelegate.h"
#import "MainViewController.h"

@interface UpdateInfoController ()
{
    NSString *sex;
    
    NSData *headData;
}
@end

@implementation UpdateInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"完善资料";
    
    sex = @"男";
    
    [[self.confrimEditBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [self updateInfo];
    }];

    
    float width = CGRectGetWidth(self.headBtn.frame);
    [self.headBtn setCornerRadius:width / 2];
    
    [self.confrimEditBtn setCornerRadius:5];
    
    [self settingBackgroundColor:0];
    [self bindEvent];
}

- (void)bindEvent{
    [[self.manBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {

        [self settingBackgroundColor:0];
        sex = self.manBtn.titleLabel.text;
    }];
    
    [[self.woman rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [self settingBackgroundColor:1];
        sex = self.woman.titleLabel.text;
    }];
    
    [[self.nationalityBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:@"请选择国籍" preferredStyle:UIAlertControllerStyleActionSheet];

        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"中国" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.nationalityBtn.titleLabel.text = action.title;
        }];
        
        [controller addAction:action1];
        
        [self presentViewController:controller animated:YES completion:NULL];
        
    }];
}


- (void)settingBackgroundColor:(int)manOrWoman{
    [UIView animateWithDuration:0.5 animations:^{
        if (manOrWoman == 0) {
            
            [self.manBtn setImage:[UIImage imageNamed:@"boy_off"] forState:UIControlStateNormal];
            [self.woman setImage:[UIImage imageNamed:@"girl_on"] forState:UIControlStateNormal];
        }else{
            
            [self.manBtn setImage:[UIImage imageNamed:@"boy_on"] forState:UIControlStateNormal];
            [self.woman setImage:[UIImage imageNamed:@"girl_off"] forState:UIControlStateNormal];
        }
    }];
}

/**
 *  @brief 完善资料
 */
- (void)updateInfo{
    
    UserMessage *info = [PublicMethod getLoginUserMessage];
    
    NSString *nickName = self.nickName.text;
    
    NSDictionary *params = @{@"AccountId":info.AccountId,
                             @"NickName":nickName,
                             @"Sex":sex,};
    
    [[HttpClientHelper sharedInstance] post:AccountWithUpdateInfo resultType:[UserMessage class] parameters:params success:^(id result) {
        UserMessage *info = result;
        
        if (info.Success) {
            
            [[EaseMob sharedInstance].chatManager asyncRegisterNewAccount:info.Phone password:info.AccountId withCompletion:^(NSString *username, NSString *password, EMError *error) {
                NSLog(@"%@",error);
                
                if (!error) {
                    DebugLog(@"注册成功");
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setValue:[info toJSONString] forKey:LOGINUSERMESSAGE];
                    [defaults synchronize];
                    
                    MainViewController *controller = [[MainViewController alloc] init];
                    UIApplication *application = [UIApplication sharedApplication];
                    UIWindow *window = application.windows.firstObject;
                    
                    CustomNavigationController *nav = [[CustomNavigationController alloc] initWithRootViewController:controller];
                    
                    [window setRootViewController:nav];
                    
                    [window makeKeyAndVisible];
                    
                }
            } onQueue:nil];
            
        }else{
            [SVProgressHUD showErrorWithStatus:info.Message];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    } showLoading:YES];
}

- (IBAction)uploadHeadAction:(id)sender {
    [self uesrImageClicked];
}

- (void)uesrImageClicked{
    UIActionSheet *sheet;
    
    // 判断是否支持相机
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        sheet  = [[UIActionSheet alloc] initWithTitle:@"选择图像"
                                             delegate:self
                                    cancelButtonTitle:@"取消"
                               destructiveButtonTitle:nil
                                    otherButtonTitles:@"拍照", @"从相册选择", nil];
    }
    else {
        sheet = [[UIActionSheet alloc] initWithTitle:@"选择图像"
                                            delegate:self
                                   cancelButtonTitle:@"取消"
                              destructiveButtonTitle:nil
                                   otherButtonTitles:@"从相册选择", nil];
    }
    
    [sheet showInView:self.view];
}

#pragma mark - action sheet delegte
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSUInteger sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    // 判断是否支持相机
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        switch (buttonIndex) {
            case 2:
                return;
            case 0: //相机
                sourceType = UIImagePickerControllerSourceTypeCamera;
                break;
            case 1: //相册
                sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                break;
        }
    }else {
        if (buttonIndex == 1) {
            return;
        } else {
            sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        }
    }
    // 跳转到相机或相册页面
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    imagePickerController.sourceType = sourceType;
    
    [self presentViewController:imagePickerController animated:YES completion:^{}];
}

#pragma mark - image picker delegte
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    
    UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];

    [self.headBtn setImage:image forState:UIControlStateNormal];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    
    headData = imageData;
    
    //[HttpRequestManager uploadImage:compressedImage httpClient:self.httpClient delegate:self];
    
}

@end

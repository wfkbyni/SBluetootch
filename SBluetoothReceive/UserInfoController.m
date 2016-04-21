//
//  UserInfoController.m
//  SBluetoothReceive
//
//  Created by 舒永超 on 15/12/15.
//  Copyright © 2015年 sych. All rights reserved.
//

#import "UserInfoController.h"

#import "MainViewController.h"
#import "LoginController.h"
#import "AppDelegate.h"

#import "HttpClientFileModel.h"

@interface UserInfoController (){
    NSData *headData;
}

@end

@implementation UserInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"用户信息";
    
    float width = CGRectGetWidth(self.headBtn.frame);
    [self.headBtn setCornerRadius:width / 2];
    
    UserMessage *info = [PublicMethod getLoginUserMessage];
    
    [self.headBtn setImageWithURL:[info getUrlPicPath] forState:UIControlStateNormal placeholder:[UIImage imageNamed:@"Icon"]];
    self.nickName.text = info.NickName;
    [self.sexBtn setTitle:info.Sex forState:UIControlStateNormal];

    [self bindEvent];
}

/**
 *  @brief 绑定事件
 */
- (void)bindEvent{
    
    @weakify(self)
    [[self.headBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self)
        [self userImageClicked];
    }];
    
    [[self.confrimEditBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self)
        if ([self.nickName.text length] < 2) {
            [SVProgressHUD showErrorWithStatus:@"昵称不能为空"];
            return ;
        }
    
        // 修改资料
        [self updateInfo];
    }];
    
    [self.confrimEditBtn setCornerRadius:5];
}

/**
 *  @brief 修改资料
 */
- (void)updateInfo{
    
    UserMessage *info = [PublicMethod getLoginUserMessage];
    
    NSString *nickName = self.nickName.text;
    
    NSDictionary *params = @{@"AccountId":info.AccountId,
                             @"NickName":nickName,
                             @"Sex":[PublicMethod getLoginUserMessage].Sex};
    // image/jpg，image/png
    NSArray *files = @[[HttpClientFileModel fileModelWithFileData:headData requestFileName:@"filename.jpg" fileName:@"filename.jpg" mimeType:@"image/jpeg"]];
    [[HttpClientHelper sharedInstance] postWithFiles:AccountWithUpdateInfo resultType:[UserMessage class] parameters:params files:files success:^(id result) {
        
        UserMessage *info = result;
        
        if (info.Success) {

            MainViewController *controller = [[MainViewController alloc] init];
            UIApplication *application = [UIApplication sharedApplication];
            UIWindow *window = application.windows.firstObject;
            
            [window setRootViewController:controller];
            
            [window makeKeyAndVisible];
        }else{
            [SVProgressHUD showErrorWithStatus:info.Message];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    } showLoading:YES];
    
}


/**
 *  @brief 选择图片
 */
- (void)userImageClicked{
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

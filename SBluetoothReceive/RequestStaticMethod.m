//
//  RequestStaticMethod.m
//  SBluetoothReceive
//
//  Created by 舒永超 on 15/12/15.
//  Copyright © 2015年 sych. All rights reserved.
//

#import "RequestStaticMethod.h"
#import "AppDelegate.h"
#import "JoinQuitPlayController.h"

@implementation RequestStaticMethod

- (void)jointQuitPlayWithGetPlayList{
    
    UINavigationController *nav = [AppDelegate findNavigationController];
    if (nav != nil) {
        if ([nav.visibleViewController isKindOfClass:[JoinQuitPlayController class]]) {
         
            JoinQuitPlayController *controller = (JoinQuitPlayController *)nav.visibleViewController;
            [controller getPlayList];
        }
    }
}

+(void)joinFriendAction:(NSString *)sendAccoutId with:(NSString *)receiveAccoutId{

    NSDictionary *param = @{@"AccountId":sendAccoutId,
                            @"FriendId":receiveAccoutId};
    
    [[HttpClientHelper sharedInstance] post:FriendsWithAdd resultType:[BaseResponseModel class] parameters:param  success:^(id result) {
        
        BaseResponseModel *model = result;
        if (model.Success) {
            
            [SVProgressHUD showSuccessWithStatus:@"好友添加成功!"];
            
            RequestStaticMethod *obj = [RequestStaticMethod new];
            [obj jointQuitPlayWithGetPlayList];
            
        }else{
            [SVProgressHUD showErrorWithStatus:model.Message];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    } showLoading:YES];
}

/**
 *  加入或退出一起玩
 *
 *  @param methodName 标记是加入一起玩，还是退出一起玩
 */
+ (void)joinOrQuitPlay:(NSString *)methodName{
    
    NSDictionary *param;
    UserMessage *info = [PublicMethod getLoginUserMessage];
    if ([methodName isEqualToString:FriendsWithJoin]) {
        param = @{@"AccountId":info.AccountId,
                  @"Remark":@""};
    }else if([methodName isEqualToString:FriendsWithQuit]){
        param = @{@"AccountId":info.AccountId};
    }
    
    [[HttpClientHelper sharedInstance] post:methodName resultType:[BaseResponseModel class] parameters:param success:^(id result) {
        
        BaseResponseModel *model = result;
        if (model.Success) {
            RequestStaticMethod *obj = [RequestStaticMethod new];
            [obj jointQuitPlayWithGetPlayList];
        }else{
            [SVProgressHUD showErrorWithStatus:model.Message];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    } showLoading:YES];
    
}
@end

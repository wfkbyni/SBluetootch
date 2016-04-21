//
//  FriendsListController.m
//  SBluetoothReceive
//
//  Created by Mac on 15/12/3.
//  Copyright © 2015年 sych. All rights reserved.
//

#import "FriendsListController.h"

#import "JoinQuitPlayController.h"

#import "UserInfoController.h"

#import "UIImageView+YYWebImage.h"

#import "ChatViewController.h"

@interface FriendsListController ()
{
    NSMutableArray *friendsData;
}
@end

@implementation FriendsListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"好友列表";
    
    [self.myTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    friendsData = [NSMutableArray new];
    [self getFriendsList];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return friendsData.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSDictionary *dic = friendsData[indexPath.row];
    
    NSError *error;
    UserMessage *info = [[UserMessage alloc] initWithDictionary:dic error:&error];
    
    [cell.imageView setImageWithURL:[info getUrlPicPath] placeholder:[UIImage imageNamed:@"Icon-Small-50"]];
    
    cell.textLabel.text = info.NickName;
    
    
    UIButton *joinFriend = (UIButton *)[cell.contentView viewWithTag:indexPath.row + 10000];
    if (joinFriend == nil) {
        joinFriend = [UIButton buttonWithType:UIButtonTypeCustom];
        [joinFriend setTitleColor:maincolor forState:UIControlStateNormal];
        [joinFriend setTitle:@"删除好友" forState:UIControlStateNormal];
        [joinFriend sizeToFit];
        joinFriend.frame = CGRectMake(ScreenSize.width - CGRectGetWidth(joinFriend.frame) - 10, 5, CGRectGetWidth(joinFriend.frame), 30);
        joinFriend.tag = indexPath.row + 10000;

        [joinFriend addTarget:self action:@selector(deleteFriendAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (![info.AccountId isEqualToString:[PublicMethod getLoginUserMessage].AccountId]) {
        [cell.contentView addSubview:joinFriend];
    }
    
    return cell;
}

#pragma mark - Table view delegate
// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dic = friendsData[indexPath.row];
    
    NSError *error;
    UserMessage *info = [[UserMessage alloc] initWithDictionary:dic error:&error];
    
    ChatViewController *controller = [[ChatViewController alloc] initWithConversationChatter:info.Phone conversationType:eConversationTypeChat];
    controller.receiverUser = info;
    controller.title = info.NickName;
    [self.navigationController pushViewController:controller animated:YES];
}

/**
 *  获取好友列表
 */
- (void)getFriendsList{
    
    UserMessage *userMessage = [PublicMethod getLoginUserMessage];
    if (userMessage != nil) {
        
        NSDictionary *param = @{@"AccountId":userMessage.AccountId,
                                @"CurrentItemCount":@"0",
                                @"PageSize":@"20"};
        
        __weak typeof(self) weakSelf = self;
        [[HttpClientHelper sharedInstance] post:FriendsWithGetFriendsList resultType:[FriendsModel class] parameters:param success:^(id result) {
            
            FriendsModel *model = result;
            
            if (model.Success) {
                
                [friendsData addObjectsFromArray:model.Items];
                
                [weakSelf.myTableView reloadData];
                
            }else{
                [SVProgressHUD showErrorWithStatus:model.Message];
            }
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        } showLoading:YES];
        
    }
}

/**
 *  删除好友
 *
 *  @param sender <#sender description#>
 */
- (void)deleteFriendAction:(UIButton *)sender{
    NSDictionary *dic = friendsData[sender.tag - 10000];
    
    NSError *error;
    UserMessage *info = [[UserMessage alloc] initWithDictionary:dic error:&error];
    
    NSDictionary *param = @{@"AccountId":[PublicMethod getLoginUserMessage].AccountId,
                            @"FriendId":info.AccountId};
    
    __weak typeof(self) weakSelf = self;
    [[HttpClientHelper sharedInstance] post:FriendsWithDelete resultType:[BaseResponseModel class] parameters:param success:^(id result) {
        
        BaseResponseModel *model = result;
        if (model.Success) {
            [SVProgressHUD showSuccessWithStatus:@"好友删除成功!"];
            
            [friendsData removeAllObjects];
            [weakSelf getFriendsList];
        }else{
            [SVProgressHUD showErrorWithStatus:model.Message];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    } showLoading:YES];
}



@end

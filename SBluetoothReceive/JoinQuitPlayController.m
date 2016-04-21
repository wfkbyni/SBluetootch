//
//  JoinQuitPlayController.m
//  SBluetoothReceive
//
//  Created by Mac on 15/12/3.
//  Copyright © 2015年 sych. All rights reserved.
//

#import "JoinQuitPlayController.h"

#import "ChatView/ChatViewController.h"

#import "AppDelegate.h"

@interface JoinQuitPlayController ()
{
    NSMutableArray *playList;
}
@end

@implementation JoinQuitPlayController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"一起玩";
    
    playList = [NSMutableArray new];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.myTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    [self getPlayList];
}

/**
 *  添加footerView
 */
- (void)addTableViewFooterView:(BOOL)hasJoin{
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenSize.width, 100)];
    
    NSString *text = @"加入一起玩";
    NSString *methodName = FriendsWithJoin;
    if (hasJoin) {
        
        text = @"退出一起玩";
        methodName = FriendsWithQuit;
    }
    
    UIButton *joinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    joinBtn.frame = CGRectMake(20, 30, ScreenSize.width - 40, 40);
    [joinBtn setTitle:text forState:UIControlStateNormal];
    
    [[joinBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self jointOrQuitPlay:methodName];
    }];
    
    [footerView addSubview:joinBtn];
    
    [joinBtn setCornerRadius:10];
    
    self.myTableView.tableFooterView = footerView;
}

- (void)jointOrQuitPlay:(NSString *)methodName{
    
    [playList removeAllObjects];
    
    [RequestStaticMethod joinOrQuitPlay:methodName];
}

/**
 *  获取一起玩列表数据
 */
- (void)getPlayList{
    
    NSDictionary *param = @{@"AccountId":[PublicMethod getLoginUserMessage].AccountId,
                        @"CurrentItemCount":@"0",
                        @"PageSize":@"20"};
    
    
    __weak typeof(self) weakSelf = self;
    [[HttpClientHelper sharedInstance] post:FriendsWithGetPlayList resultType:[FriendsModel class] parameters:param success:^(id result) {

        FriendsModel *model = result;
        
        if (model.Success) {
            
            [weakSelf addTableViewFooterView:model.HasJoin];
            
            [playList addObjectsFromArray:model.Items];
            [weakSelf.myTableView reloadData];
        }else{
            [SVProgressHUD showErrorWithStatus:model.Message];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

    } showLoading:YES];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return playList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSDictionary *dic = playList[indexPath.row];
    
    NSError *error;
    UserMessage *info = [[UserMessage alloc] initWithDictionary:dic error:&error];
    
    [cell.imageView setImageWithURL:[info getUrlPicPath] placeholder:[UIImage imageNamed:@"Icon-Small-50"]];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@",info.NickName];
    
    UIButton *joinFriend = (UIButton *)[cell.contentView viewWithTag:indexPath.row + 10000];
    if (![info.AccountId isEqualToString:[PublicMethod getLoginUserMessage].AccountId]) {
        
        if (joinFriend == nil) {
            joinFriend = [UIButton buttonWithType:UIButtonTypeContactAdd];
            joinFriend.frame = CGRectMake(ScreenSize.width - 80, 5, 70, 30);
            joinFriend.tag = indexPath.row + 10000;
            //[joinFriend setTitle:@"加好友" forState:UIControlStateNormal];
            //[joinFriend addTarget:self action:@selector(joinFriendAction:) forControlEvents:UIControlEventTouchUpInside];
            
            [joinFriend setTitle:@"一起玩" forState:UIControlStateNormal];
            [joinFriend addTarget:self action:@selector(requestPlayAction:) forControlEvents:UIControlEventTouchUpInside];
            
            
            [cell.contentView addSubview:joinFriend];
        }
        
        joinFriend.hidden = NO;
    }else{
        joinFriend.hidden = YES;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *dic = playList[indexPath.row];
    
    NSError *error;
    UserMessage *info = [[UserMessage alloc] initWithDictionary:dic error:&error];
    
    [[NSUserDefaults standardUserDefaults] setObject:@{info.Phone :[info toJSONString]} forKey:ChatRecipient];
    [[NSUserDefaults standardUserDefaults] setObject:info.Phone forKey:ChatRecipientID];
    
    ChatViewController *controller = [[ChatViewController alloc] initWithConversationChatter:info.Phone conversationType:eConversationTypeChat];
    controller.receiverUser = info;
    controller.title = info.NickName;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)joinFriendAction:(UIButton *)sender{
    
    NSDictionary *dic = playList[sender.tag - 10000];
    
    NSError *error;
    UserMessage *freind = [[UserMessage alloc] initWithDictionary:dic error:&error];
    
    [UIAlertView alertWithTitles:@"提示" message:[NSString stringWithFormat:@"您确定要添加 [%@] 为好友吗?",freind.NickName] clickBlock:^(UIAlertView *alertView, NSInteger clickIndex) {
        
        if (clickIndex != alertView.cancelButtonIndex) {
            
            [appDelegate connectionSocketAndSendData:SocketCommandRequestFriend receiveUserId:freind.AccountId data:@"020001"];
        }
        
    } cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];

}

- (void)requestPlayAction:(UIButton *)sender{
    NSDictionary *dic = playList[sender.tag - 10000];
    
    NSError *error;
    UserMessage *freind = [[UserMessage alloc] initWithDictionary:dic error:&error];
    
    [UIAlertView alertWithTitles:@"提示" message:[NSString stringWithFormat:@"您确定要邀请 [%@] 一起玩吗?",freind.NickName] clickBlock:^(UIAlertView *alertView, NSInteger clickIndex) {
        
        if (clickIndex != alertView.cancelButtonIndex) {
            
            [appDelegate connectionSocketAndSendData:SocketCommandRequstPlay receiveUserId:freind.AccountId data:@"020001"];
        }
        
    } cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
}


@end

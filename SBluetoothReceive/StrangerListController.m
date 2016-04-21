//
//  StrangerListController.m
//  SBluetoothReceive
//
//  Created by Mac on 15/12/4.
//  Copyright © 2015年 sych. All rights reserved.
//

#import "StrangerListController.h"

#import "FriendsListController.h"

@interface StrangerListController ()
{
    NSMutableArray *strangerList;
}
@end

@implementation StrangerListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"主页";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(friendsListAction)];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    strangerList = [NSMutableArray new];
    [self getStrangerList];
}

- (void)friendsListAction{
    FriendsListController *controller = [[FriendsListController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)getStrangerList{
    
    NSDictionary *param = @{@"AccountId":[PublicMethod getLoginUserMessage].AccountId,
                            @"CurrentItemCount":@"0",
                            @"PageSize":@"20",
                            @"Key":@""};
    
    
    __weak typeof(self) weakSelf = self;
    [[HttpClientHelper sharedInstance] post:FriendsWithGetStrangerList resultType:[FriendsModel class] parameters:param success:^(id result) {
        
        FriendsModel *model = result;
        if (model.Success) {
            
            [strangerList addObjectsFromArray:model.Items];
            
            [weakSelf.tableView reloadData];
            
        }else{
            [SVProgressHUD showErrorWithStatus:model.Message];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    } showLoading:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return strangerList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSDictionary *dic = strangerList[indexPath.row];
    
    NSError *error;
    UserMessage *info = [[UserMessage alloc] initWithDictionary:dic error:&error];
    
    cell.imageView.image = [UIImage imageNamed:@"Icon-Small-50"];

    cell.textLabel.text = [NSString stringWithFormat:@"昵称:%@   %@",info.NickName,info.LastLoginTime];
    // Configure the cell...
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

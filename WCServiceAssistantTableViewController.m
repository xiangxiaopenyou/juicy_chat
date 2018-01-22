//
//  WCServiceAssistantTableViewController.m
//  SealTalk
//
//  Created by 项小盆友 on 2018/1/3.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "WCServiceAssistantTableViewController.h"
#import "RCDUserInfo.h"
#import "RCDUtilities.h"
#import "MBProgressHUD+Add.h"
#import "RCDCommonDefine.h"
#import "RCDContactTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "WCUserDetailsViewController.h"
#import "RCDataBaseManager.h"
#import "RCDUserInfoManager.h"
#import "RCDChatViewController.h"

@interface WCServiceAssistantTableViewController ()
@property (strong, nonatomic) NSMutableArray *dataArray;

@end

@implementation WCServiceAssistantTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.title = @"客服助手";
    self.tableView.backgroundColor = HEXCOLOR(0xf2f2f2);
    self.tableView.tableFooterView = [UIView new];
    self.dataArray = [[self getAllFriendList] mutableCopy];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Requests
- (NSArray *)getAllFriendList {
    NSMutableArray *friendList = [[NSMutableArray alloc] init];
    NSMutableArray *userInfoList = [NSMutableArray arrayWithArray:[[RCDataBaseManager shareInstance] getAllFriends]];
    for (RCDUserInfo *user in userInfoList) {
        if ([user.status integerValue] == 1) {
            [friendList addObject:user];
        }
    }
    //如有好友备注，则显示备注
    NSArray *resultList = [[RCDUserInfoManager shareInstance] getFriendInfoList:friendList];
    NSMutableArray *resultFriendsArray = [[NSMutableArray alloc] init];
    for (RCDUserInfo *tempInfo in resultList) {
        if (tempInfo.userId.integerValue <= 10010) {
            [resultFriendsArray addObject:tempInfo];
        }
    }
    return resultFriendsArray;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.5;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reusableCellWithIdentifier = @"RCDContactTableViewCell";
    RCDContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];
    if (cell == nil) {
        cell = [[RCDContactTableViewCell alloc] init];
    }
    RCDUserInfo *userInfo = self.dataArray[indexPath.row];
    cell.nicknameLabel.text = userInfo.name;
    [cell.portraitView sd_setImageWithURL:[NSURL URLWithString:userInfo.portraitUri] placeholderImage:[UIImage imageNamed:@"contact"]];
    cell.portraitView.contentMode = UIViewContentModeScaleAspectFill;
    cell.nicknameLabel.font = [UIFont systemFontOfSize:15.f];
    cell.portraitView.layer.masksToBounds = YES;
    cell.portraitView.layer.cornerRadius = 5.f;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    RCDUserInfo *userInfo = self.dataArray[indexPath.row];
//    WCUserDetailsViewController *detailViewController = [[UIStoryboard storyboardWithName:@"Additional" bundle:nil] instantiateViewControllerWithIdentifier:@"UserDetails"];
//    detailViewController.userId = [NSString stringWithFormat:@"%@", userInfo.userId];
//    [self.navigationController pushViewController:detailViewController
//                                         animated:YES];
    RCDChatViewController *conversationVC = [[RCDChatViewController alloc] init];
    conversationVC.conversationType = ConversationType_PRIVATE;
    conversationVC.targetId = userInfo.userId;
    conversationVC.title = userInfo.name;
    [self.navigationController pushViewController:conversationVC animated:YES];
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
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

@end

//
//  WCTransferGroupViewController.m
//  SealTalk
//
//  Created by 项小盆友 on 2017/11/15.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import "WCTransferGroupViewController.h"
#import "WCTransferGroupMemberCell.h"

#import "WCTransferGroupRequest.h"

#import "RCDataBaseManager.h"
#import "RCDGroupInfo.h"
#import "RCDUtilities.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD+Add.h"

@interface WCTransferGroupViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *allMembersArray;
@property (strong, nonatomic) NSMutableArray *allKeysArray;
@property (strong, nonatomic) NSMutableDictionary *allMembersDictionary;

@end

@implementation WCTransferGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.tableFooterView = [UIView new];
    [self allData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Private methods
- (void)allData {
    _allMembersArray = [[NSMutableArray alloc] init];
    _allKeysArray = [[NSMutableArray alloc] init];
    _allMembersDictionary = [[NSMutableDictionary alloc] init];
    _allMembersArray = [[RCDataBaseManager shareInstance] getGroupMember:self.groupInfo.groupId];
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    [_allMembersArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        RCDUserInfo *tempInfo = (RCDUserInfo *)obj;
        if (![tempInfo.userId isEqualToString:self.groupInfo.creatorId]) {
            [tempArray addObject:tempInfo];
        }
    }];
    _allMembersArray = [tempArray mutableCopy];
    NSMutableDictionary *resultDic = [RCDUtilities sortedArrayWithPinYinDic:_allMembersArray];
    _allMembersDictionary = resultDic[@"infoDic"];
    _allKeysArray = resultDic[@"allKeys"];
    [self.tableView reloadData];
}

#pragma mark - Request
- (void)transferRequest:(NSString *)userId {
    [[WCTransferGroupRequest new] request:^BOOL(WCTransferGroupRequest *request) {
        request.userId = userId;
        request.groupId = self.groupInfo.groupId;
        return YES;
    } result:^(id object, NSString *msg) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (object) {
            [MBProgressHUD showSuccess:@"成功" toView:self.view];
            if (self.transferBlock) {
                self.transferBlock(userId);
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        } else {
            [MBProgressHUD showError:msg toView:self.view];
        }
    }];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _allKeysArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        NSString *key = [_allKeysArray objectAtIndex:section];
        NSArray *arr = [_allMembersDictionary objectForKey:key];
        return [arr count];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.f;
}
- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return _allKeysArray;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"TransferGroupMemberCell";
    WCTransferGroupMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    NSString *key = [_allKeysArray objectAtIndex:indexPath.section];
    NSArray *arr = [_allMembersDictionary objectForKey:key];
    RCDUserInfo *userInfo = arr[indexPath.row];
    [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:userInfo.portraitUri] placeholderImage:nil];
    cell.nameLabel.text = userInfo.name;
    return cell;
}

#pragma mark - Table view delegate
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *key = [_allKeysArray objectAtIndex:section];
    return key;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [MBProgressHUD showHUDAddedTo:self.view animated:self.view];
    NSString *key = [_allKeysArray objectAtIndex:indexPath.section];
    NSArray *arr = [_allMembersDictionary objectForKey:key];
    RCDUserInfo *userInfo = arr[indexPath.row];
    [self transferRequest:userInfo.userId];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

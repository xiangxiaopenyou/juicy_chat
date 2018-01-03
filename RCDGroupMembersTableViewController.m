//
//  RCDGroupMembersTableViewController.m
//  RCloudMessage
//
//  Created by Jue on 16/4/10.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDGroupMembersTableViewController.h"
#import "DefaultPortraitView.h"
#import "RCDAddFriendViewController.h"
#import "RCDContactTableViewCell.h"
#import "RCDMeInfoTableViewController.h"
//#import "RCDPersonDetailViewController.h"
#import "WCUserDetailsViewController.h"
#import "RCDataBaseManager.h"
#import "UIImageView+WebCache.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDUIBarButtonItem.h"
#import "RCDSearchBar.h"

@interface RCDGroupMembersTableViewController ()<UISearchBarDelegate>

@property (nonatomic, strong) RCDUIBarButtonItem *leftBtn;
@property (nonatomic, strong) RCDSearchBar *searchBar;

@property (nonatomic, strong) NSMutableArray *resultArray;

@end

@implementation RCDGroupMembersTableViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  // Uncomment the following line to preserve selection between presentations.
  // self.clearsSelectionOnViewWillAppear = NO;

  // Uncomment the following line to display an Edit button in the navigation
  // bar for this view controller.
  // self.navigationItem.rightBarButtonItem = self.editButtonItem;
  self.tableView.tableFooterView = [UIView new];
    self.tableView.tableHeaderView = self.searchBar;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;

  self.title = [NSString stringWithFormat:@"群组成员(%lu)",
                                          (unsigned long)[_GroupMembers count]];
  
  self.leftBtn =
  [[RCDUIBarButtonItem alloc] initContainImage:[UIImage imageNamed:@"navigator_btn_back"]
                                imageViewFrame:CGRectMake(-6, 4, 10, 17)
                                   buttonTitle:@"返回"
                                    titleColor:[UIColor whiteColor]
                                    titleFrame:CGRectMake(9, 4, 85, 17)
                                   buttonFrame:CGRectMake(0, 6, 87, 23)
                                        target:self
                                        action:@selector(clickBackBtn)];
  self.navigationItem.leftBarButtonItem = self.leftBtn;
    self.resultArray = [_GroupMembers mutableCopy];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)searchMembers:(NSString *)searchString {
    [self.resultArray removeAllObjects];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (searchString != nil && searchString.length > 0) {
            for (RCDUserInfo *userInfo in _GroupMembers) {
                NSString *nameString = userInfo.name;
                NSRange range = [nameString rangeOfString:searchString options:NSCaseInsensitiveSearch];
                if (range.location != NSNotFound) {
                    [self.resultArray addObject:userInfo];
                }
            }
        } else {
            self.resultArray = [_GroupMembers mutableCopy];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
  return [self.resultArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *reusableCellWithIdentifier = @"RCDContactTableViewCell";
  RCDContactTableViewCell *cell = [self.tableView
      dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];
  if (cell == nil) {
    cell = [[RCDContactTableViewCell alloc] init];
  }
  // Configure the cell...
  RCDUserInfo *user = self.resultArray[indexPath.row];
  if ([user.portraitUri isEqualToString:@""]) {
    DefaultPortraitView *defaultPortrait =
        [[DefaultPortraitView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [defaultPortrait setColorAndLabel:user.userId Nickname:user.name];
    UIImage *portrait = [defaultPortrait imageFromView];
    cell.portraitView.image = portrait;
  } else {
    [cell.portraitView sd_setImageWithURL:[NSURL URLWithString:user.portraitUri]
                         placeholderImage:[UIImage imageNamed:@"contact"]];
  }
  cell.portraitView.layer.masksToBounds = YES;
  cell.portraitView.layer.cornerRadius = 5.f;
  cell.portraitView.contentMode = UIViewContentModeScaleAspectFill;

  cell.nicknameLabel.font = [UIFont systemFontOfSize:15.f];
  cell.nicknameLabel.text = user.name;
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 70.0;
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  RCUserInfo *user = self.resultArray[indexPath.row];
  BOOL isFriend = NO;
  NSArray *friendList = [[RCDataBaseManager shareInstance] getAllFriends];
  for (RCDUserInfo *friend in friendList) {
    if ([user.userId isEqualToString:friend.userId] &&
        [friend.status isEqualToString:@"1"]) {
      isFriend = YES;
    }
  }
  if (isFriend == YES || [user.userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
      WCUserDetailsViewController *detailViewController = [[UIStoryboard storyboardWithName:@"Additional" bundle:nil] instantiateViewControllerWithIdentifier:@"UserDetails"];
//      RCDPersonDetailViewController *detailViewController =
//      [[RCDPersonDetailViewController alloc]init];
      RCUserInfo *user = self.resultArray[indexPath.row];
      detailViewController.userId = user.userId;
    [self.navigationController pushViewController:detailViewController
                                         animated:YES];
    
  } else {
      RCDAddFriendViewController *addViewController = [[RCDAddFriendViewController alloc]init];
    addViewController.targetUserInfo = self.resultArray[indexPath.row];
    [self.navigationController pushViewController:addViewController
                                         animated:YES];
  }
}

#pragma mark - Search bar delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self searchMembers:searchText];
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = YES;
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    searchBar.text = nil;
    searchBar.showsCancelButton = NO;
}

- (void)clickBackBtn {
  [self.navigationController popViewControllerAnimated:YES];
}

- (RCDSearchBar *)searchBar{
    if (!_searchBar) {
        _searchBar = [[RCDSearchBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 44)];
        _searchBar.placeholder = @"搜索群成员";
        _searchBar.delegate = self;
    }
    return _searchBar;
}

@end

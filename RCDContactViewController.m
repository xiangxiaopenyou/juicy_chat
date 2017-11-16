//
//  RCDContactViewController.m
//  RCloudMessage
//
//  Created by Jue on 16/3/16.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "DefaultPortraitView.h"
#import "RCDAddressBookTableViewCell.h"
#import "RCDAddressBookViewController.h"
#import "RCDContactTableViewCell.h"
#import "RCDContactViewController.h"
#import "RCDGroupViewController.h"
#import "RCDHttpTool.h"
//#import "RCDPersonDetailViewController.h"
#import "WCUserDetailsViewController.h"
#import "RCDPublicServiceListViewController.h"
#import "RCDRCIMDataSource.h"
#import "RCDSearchFriendViewController.h"
#import "RCDUserInfo.h"
#import "RCDataBaseManager.h"
#import "UIImageView+WebCache.h"
#import "pinyin.h"
#import "RCDCommonDefine.h"

#import "RCDUserInfoManager.h"
#import "RCDUtilities.h"
#import "RCDUIBarButtonItem.h"

#import "Masonry.h"


@interface RCDContactViewController ()
@property(strong, nonatomic) NSMutableArray *matchFriendList;
@property(strong, nonatomic) NSArray *defaultCellsTitle;
@property(strong, nonatomic) NSArray *defaultCellsPortrait;
@property(nonatomic, assign) BOOL hasSyncFriendList;
@property(nonatomic, assign) BOOL isBeginSearch;
@property(nonatomic, strong) NSMutableDictionary *resultDic;
@property (assign, nonatomic) NSInteger friendRequestNumber;

@end

@implementation RCDContactViewController

- (void)setUpView{
    [self.friendsTabelView
     setBackgroundColor:[UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1]];
    self.view.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1];
    
    [self.view addSubview:self.friendsTabelView];
    [self.view addSubview:self.searchFriendsBar];
    
    [self.friendsTabelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchFriendsBar.mas_bottom);
        make.leading.trailing.equalTo(self.view);
        make.height.mas_offset(RCDscreenHeight - 114 - 43.5);
    }];
}

- (UISearchBar *)searchFriendsBar {
    if (!_searchFriendsBar) {
        _searchFriendsBar=[[UISearchBar alloc]initWithFrame:CGRectMake(2, 0, RCDscreenWidth-4, 28)];
        [_searchFriendsBar sizeToFit];
        [_searchFriendsBar setPlaceholder:NSLocalizedStringFromTable(@"ToSearch", @"RongCloudKit", nil)];
        [_searchFriendsBar.layer setBorderWidth:0.5];
        [_searchFriendsBar.layer setBorderColor:[UIColor colorWithRed:235.0/255 green:235.0/255 blue:235.0/255 alpha:1].CGColor];
        [_searchFriendsBar setDelegate:self];
        [_searchFriendsBar setKeyboardType:UIKeyboardTypeDefault];
    }
    return _searchFriendsBar;
}

- (UITableView *)friendsTabelView {
    if (!_friendsTabelView) {
        _friendsTabelView=[[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        
        [_friendsTabelView setDelegate:self];
        [_friendsTabelView setDataSource:self];
        [_friendsTabelView setSectionIndexBackgroundColor:[UIColor clearColor]];
        [_friendsTabelView setSectionIndexColor:[UIColor darkGrayColor]];
        [_friendsTabelView setBackgroundColor:[UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1]];
//        _friendsTabelView.style = UITableViewStyleGrouped;
//        _friendsTabelView.tableHeaderView=self.searchFriendsBar;
        //cell无数据时，不显示间隔线
//        if ([UIDevice currentDevice].systemVersion.floatValue >= 11.0) {
//            if (@available(iOS 11.0, *)) {
//                _friendsTabelView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//            } else {
//                // Fallback on earlier versions
//            }
//        }
        UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
        [_friendsTabelView setTableFooterView:v];
    }
    return _friendsTabelView;
}


- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  self.edgesForExtendedLayout = UIRectEdgeNone;
  self.navigationController.navigationBar.translucent = NO;
  [self setUpView];
  // initial data
  self.matchFriendList = [[NSMutableArray alloc] init];
  self.allFriendSectionDic = [[NSDictionary alloc] init];
  
  self.friendsTabelView.tableFooterView = [UIView new];
  self.friendsTabelView.backgroundColor = HEXCOLOR(0xf0f0f6);
  self.friendsTabelView.separatorColor = HEXCOLOR(0xdfdfdf);
  
  self.friendsTabelView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.friendsTabelView.bounds.size.width, 0.01f)];
  
  //设置右侧索引
  self.friendsTabelView.sectionIndexBackgroundColor = [UIColor clearColor];
  self.friendsTabelView.sectionIndexColor = HEXCOLOR(0x555555);
  
  if ([self.friendsTabelView respondsToSelector:@selector(setSeparatorInset:)]) {
    [self.friendsTabelView setSeparatorInset:UIEdgeInsetsMake(0, 14, 0, 0)];
  }
  if ([self.friendsTabelView respondsToSelector:@selector(setLayoutMargins:)]) {
    [self.friendsTabelView setLayoutMargins:UIEdgeInsetsMake(0, 14, 0, 0)];
  }

  UIImage* searchBarBg = [self GetImageWithColor:[UIColor clearColor] andHeight:32.0f];
  //设置顶部搜索栏的背景图片
  [self.searchFriendsBar setBackgroundImage:searchBarBg];
  //设置顶部搜索栏的背景色
  [self.searchFriendsBar setBackgroundColor:HEXCOLOR(0xf0f0f6)];
  
  //设置顶部搜索栏输入框的样式
  UITextField *searchField = [self.searchFriendsBar valueForKey:@"_searchField"];
  searchField.layer.borderWidth = 0.5f;
  searchField.layer.borderColor = [HEXCOLOR(0xdfdfdf) CGColor];
  searchField.layer.cornerRadius = 5.f;
  self.searchFriendsBar.placeholder = @"搜索通讯录";

  self.defaultCellsTitle = [NSArray
      arrayWithObjects:@"新朋友", @"群组", nil];
  self.defaultCellsPortrait = [NSArray
      arrayWithObjects:@"newFriend", @"defaultGroup", nil];
  
  self.isBeginSearch = NO;
    //添加好友通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeNewFriendNumber) name:@"DidChangeNewFriendsNumber" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  [self.searchFriendsBar resignFirstResponder];
    [RCDDataSource syncFriendList:[RCIM sharedRCIM].currentUserInfo.userId
                         complete:^(NSMutableArray *result) {
                             [self messagesNumberOfRequest];
                         }];
  [self sortAndRefreshWithList:[self getAllFriendList]];
  
  //自定义rightBarButtonItem
  RCDUIBarButtonItem *rightBtn =
  [[RCDUIBarButtonItem alloc] initContainImage:[UIImage imageNamed:@"add_friend"]
                                imageViewFrame:CGRectMake(0, 0, 18, 20)
                                   buttonTitle:nil
                                    titleColor:nil
                                    titleFrame:CGRectZero
                                   buttonFrame:CGRectMake(0, 0, 18, 20)
                                        target:self
                                        action:@selector(pushAddFriend:)];
  self.tabBarController.navigationItem.rightBarButtonItems = [rightBtn setTranslation:rightBtn translation:-6];
    if ([UIDevice currentDevice].systemVersion.floatValue >= 11.0) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add_friend"] style:UIBarButtonItemStylePlain target:self action:@selector(pushAddFriend:)];
        self.tabBarController.navigationItem.rightBarButtonItems = @[item];
    }
  self.tabBarController.navigationItem.title = @"通讯录";
}

-(void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  if (_isBeginSearch == YES) {
    [self sortAndRefreshWithList:[self getAllFriendList]];
    _isBeginSearch = NO;
    self.searchFriendsBar.showsCancelButton = NO;
    [self.searchFriendsBar resignFirstResponder];
    self.searchFriendsBar.text = @"";
    [self.matchFriendList removeAllObjects];
    [self.friendsTabelView setContentOffset:CGPointMake(0,0) animated:NO];
  }
}
- (void)didChangeNewFriendNumber {
    //[self messagesNumberOfRequest];
    [RCDDataSource syncFriendList:[RCIM sharedRCIM].currentUserInfo.userId
                         complete:^(NSMutableArray *result) {
                             _friendRequestNumber = 0;
                             NSMutableArray *temp = [NSMutableArray arrayWithArray:[[RCDataBaseManager shareInstance] getAllFriends]];
                             for (RCDUserInfo *user in temp) {
                                 if ([user.status integerValue] == 2) {
                                     _friendRequestNumber += 1;
                                 }
                             }
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 [self.friendsTabelView reloadData];
                             });
                         }];
    
}

//获取好友请求消息数量
- (void)messagesNumberOfRequest {
    _friendRequestNumber = 0;
    NSMutableArray *temp = [NSMutableArray arrayWithArray:[[RCDataBaseManager shareInstance] getAllFriends]];
    for (RCDUserInfo *user in temp) {
        if ([user.status integerValue] == 2) {
            _friendRequestNumber += 1;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.friendsTabelView reloadData];
    });
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
  NSInteger rows = 0;
  if (section == 0) {
    if (_isBeginSearch == YES) {
      rows = 0;
    }
    else
    {
      rows = 3;
    }
  } else {
    NSString *letter = self.resultDic[@"allKeys"][section -1];
    rows = [self.allFriendSectionDic[letter] count];
  }
  return rows;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return [self.resultDic[@"allKeys"] count] + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
  if (section == 0) {
    return 0;
  }
  return 21.f;
}

//如果没有该方法，tableView会默认显示footerView，其高度与headerView等高
//另外如果return 0或者0.0f是没有效果的
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return section == [self.resultDic[@"allKeys"] count] ? 50.f : 0.1f;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == [self.resultDic[@"allKeys"] count]) {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
        footerView.backgroundColor = [UIColor clearColor];
        UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
        countLabel.textColor = [UIColor grayColor];
        countLabel.font = [UIFont systemFontOfSize:16];
        countLabel.textAlignment = NSTextAlignmentCenter;
        NSArray *tempArray = [self getAllFriendList];
        countLabel.text = tempArray.count > 0 ? [NSString stringWithFormat:@"%@位联系人", @(tempArray.count)] : nil;
        [footerView addSubview:countLabel];
        return footerView;
    } else {
        return nil;
    }
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
  UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
  view.frame = CGRectMake(0, 0, self.view.frame.size.width, 22);
  view.backgroundColor = [UIColor clearColor];
  
  UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
  title.frame = CGRectMake(13, 3, 15, 15);
  title.font = [UIFont systemFontOfSize:15.f];
  title.textColor = HEXCOLOR(0x999999);
  
  [view addSubview:title];
  
  if (section == 0) {
    title.text = nil;
  } else {
    title.text = self.resultDic[@"allKeys"][section - 1];
  }
  return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSString *isDisplayID = [[NSUserDefaults standardUserDefaults] objectForKey:@"isDisplayID"];
  static NSString *reusableCellWithIdentifier = @"RCDContactTableViewCell";
  RCDContactTableViewCell *cell = [self.friendsTabelView
      dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];
  if (cell == nil) {
      cell = [[RCDContactTableViewCell alloc] init];
  }

  if (indexPath.section == 0 && indexPath.row < 2) {
    cell.nicknameLabel.text = [_defaultCellsTitle objectAtIndex:indexPath.row];
      [cell.portraitView
          setImage:[UIImage
                       imageNamed:[NSString
                                      stringWithFormat:
                                          @"%@",
                                          [_defaultCellsPortrait
                                              objectAtIndex:indexPath.row]]]];
      if (indexPath.row == 0) {
          if (_friendRequestNumber > 0) {
              cell.numberLabel.hidden = NO;
              cell.numberLabel.text = [NSString stringWithFormat:@"%@", @(_friendRequestNumber)];
          } else {
              cell.numberLabel.hidden = YES;
          }
      }
  }
  if (indexPath.section == 0 && indexPath.row == 2) {
      if ([isDisplayID isEqualToString:@"YES"]) {
        cell.userIdLabel.text = [RCIM sharedRCIM].currentUserInfo.userId;
      }
    cell.nicknameLabel.text = [RCIM sharedRCIM].currentUserInfo.name;
    [cell.portraitView
     sd_setImageWithURL:[NSURL URLWithString:[RCIM sharedRCIM].currentUserInfo.portraitUri]
     placeholderImage:[UIImage imageNamed:@"contact"]];
  } if (indexPath.section != 0) {
    NSString *letter = self.resultDic[@"allKeys"][indexPath.section -1];

    NSArray *sectionUserInfoList = self.allFriendSectionDic[letter];
    RCDUserInfo *userInfo = sectionUserInfoList[indexPath.row];
    if (userInfo) {
      if ([isDisplayID isEqualToString:@"YES"]) {
        cell.userIdLabel.text = userInfo.userId;
      }
        cell.nicknameLabel.text = userInfo.name;
      if ([userInfo.portraitUri isEqualToString:@""]) {
        DefaultPortraitView *defaultPortrait = [[DefaultPortraitView alloc]
            initWithFrame:CGRectMake(0, 0, 100, 100)];
        [defaultPortrait setColorAndLabel:userInfo.userId Nickname:userInfo.name];
        UIImage *portrait = [defaultPortrait imageFromView];
        cell.portraitView.image = portrait;
      } else {
        [cell.portraitView
            sd_setImageWithURL:[NSURL URLWithString:userInfo.portraitUri]
              placeholderImage:[UIImage imageNamed:@"contact"]];
      }
    }
  }
  if ([RCIM sharedRCIM].globalConversationAvatarStyle == RC_USER_AVATAR_CYCLE &&
      [RCIM sharedRCIM].globalMessageAvatarStyle == RC_USER_AVATAR_CYCLE) {
    cell.portraitView.layer.masksToBounds = YES;
    cell.portraitView.layer.cornerRadius = 20.f;
  } else {
    cell.portraitView.layer.masksToBounds = YES;
    cell.portraitView.layer.cornerRadius = 5.f;
  }
  cell.selectionStyle = UITableViewCellSelectionStyleDefault;
  cell.portraitView.contentMode = UIViewContentModeScaleAspectFill;
  cell.nicknameLabel.font = [UIFont systemFontOfSize:15.f];
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 55.5;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
  return self.resultDic[@"allKeys"];
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  RCDUserInfo *user = nil;
  if (indexPath.section == 0) {
    switch (indexPath.row) {
    case 0: {
        RCDAddressBookViewController *addressBookVC = [RCDAddressBookViewController addressBookViewController];
      [self.navigationController pushViewController:addressBookVC animated:YES];
      return;
    } break;

    case 1: {
        RCDGroupViewController *groupVC = [[RCDGroupViewController alloc]init];
      [self.navigationController pushViewController:groupVC animated:YES];
      return;

    } break;

//    case 2: {
//      RCDPublicServiceListViewController *publicServiceVC =
//          [[RCDPublicServiceListViewController alloc] init];
//      [self.navigationController pushViewController:publicServiceVC
//                                           animated:YES];
//      return;
//
//    } break;

    case 2: {
        //RCDPersonDetailViewController *detailViewController =
        //[[RCDPersonDetailViewController alloc]init];
        WCUserDetailsViewController *detailViewController = [[UIStoryboard storyboardWithName:@"Additional" bundle:nil] instantiateViewControllerWithIdentifier:@"UserDetails"];
        detailViewController.userId = [RCIM sharedRCIM].currentUserInfo.userId;
      [self.navigationController pushViewController:detailViewController
                                           animated:YES];
      return;
    }

    default:
      break;
    }
  }
    NSString *letter = self.resultDic[@"allKeys"][indexPath.section -1];
    NSArray *sectionUserInfoList = self.allFriendSectionDic[letter];
    user = sectionUserInfoList[indexPath.row];
  if (user == nil) {
    return;
  }
  RCUserInfo *userInfo = [RCUserInfo new];
  userInfo.userId = user.userId;
  userInfo.portraitUri = user.portraitUri;
  userInfo.name = user.name;

//    RCDPersonDetailViewController *detailViewController = [[RCDPersonDetailViewController alloc]init];
//  detailViewController.userId = user.userId;
    WCUserDetailsViewController *detailViewController = [[UIStoryboard storyboardWithName:@"Additional" bundle:nil] instantiateViewControllerWithIdentifier:@"UserDetails"];
    detailViewController.userId = user.userId;
  [self.navigationController pushViewController:detailViewController
                                       animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  [self.searchFriendsBar resignFirstResponder];
}

#pragma mark - UISearchBarDelegate
/**
 *  执行delegate搜索好友
 *
 *  @param searchBar  searchBar description
 *  @param searchText searchText description
 */
- (void)searchBar:(UISearchBar *)searchBar
    textDidChange:(NSString *)searchText {
  [self.matchFriendList removeAllObjects];
  if (searchText.length <= 0) {
    [self sortAndRefreshWithList:[self getAllFriendList]];
  } else {
    for (RCUserInfo *userInfo in [self getAllFriendList]) {
      //忽略大小写去判断是否包含
      if ([userInfo.name rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound
          || [[RCDUtilities hanZiToPinYinWithString:userInfo.name] rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound) {
        [self.matchFriendList addObject:userInfo];
      }
    }
    [self sortAndRefreshWithList:self.matchFriendList];
  }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
  self.searchFriendsBar.showsCancelButton = NO;
  [self.searchFriendsBar resignFirstResponder];
  self.searchFriendsBar.text = @"";
  [self.matchFriendList removeAllObjects];
  [self sortAndRefreshWithList:[self getAllFriendList]];
  _isBeginSearch = NO;
  [self.friendsTabelView reloadData];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
  if (_isBeginSearch == NO) {
    _isBeginSearch = YES;
    [self.friendsTabelView reloadData];
  }
  self.searchFriendsBar.showsCancelButton = YES;
  return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
  [searchBar resignFirstResponder];
}

#pragma mark - 获取好友并且排序

- (NSArray *)getAllFriendList {
  NSMutableArray *friendList = [[NSMutableArray alloc] init];
  NSMutableArray *userInfoList = [NSMutableArray arrayWithArray:[[RCDataBaseManager shareInstance] getAllFriends]];
  for (RCDUserInfo *user in userInfoList) {
    if ([user.status integerValue] == 1) {
      [friendList addObject:user];
    }
  }
  if (friendList.count <= 0 && !self.hasSyncFriendList) {
    [RCDDataSource syncFriendList:[RCIM sharedRCIM].currentUserInfo.userId
                         complete:^(NSMutableArray *result) {
                           self.hasSyncFriendList = YES;
                           [self sortAndRefreshWithList:[self getAllFriendList]];
                         }];
  }
  //如有好友备注，则显示备注
  NSArray *resultList = [[RCDUserInfoManager shareInstance]
                         getFriendInfoList:friendList];
  
  return resultList;
}

- (void)sortAndRefreshWithList:(NSArray *)friendList {
  dispatch_async(dispatch_get_global_queue(0, 0), ^{
    self.resultDic = [RCDUtilities sortedArrayWithPinYinDic:friendList];
    dispatch_async(dispatch_get_main_queue(), ^{
      self.allFriendSectionDic = self.resultDic[@"infoDic"];
      [self.friendsTabelView reloadData];
    });
  });
}

/**
 *  添加好友
 *
 *  @param sender sender description
 */
- (void)pushAddFriend:(id)sender {
  RCDSearchFriendViewController *searchFirendVC =
  [RCDSearchFriendViewController searchFriendViewController];
  [self.navigationController pushViewController:searchFirendVC animated:YES];
}


- (UIImage*) GetImageWithColor:(UIColor*)color andHeight:(CGFloat)height
{
  CGRect r= CGRectMake(0.0f, 0.0f, 1.0f, height);
  UIGraphicsBeginImageContext(r.size);
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  CGContextSetFillColorWithColor(context, [color CGColor]);
  CGContextFillRect(context, r);
  
  UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return img;
}

@end

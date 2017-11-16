//
//  RCDMainTabBarViewController.m
//  RCloudMessage
//
//  Created by Jue on 16/7/30.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDMainTabBarViewController.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDSquareTableViewController.h"
#import "RCDChatListViewController.h"
#import "RCDContactViewController.h"
#import "RCDMeTableViewController.h"
#import "WCChatRoomViewController.h"
#import "UITabBar+badge.h"
#import "RCDUserInfo.h"
#import "RCDataBaseManager.h"
#import "RCDRCIMDataSource.h"

@interface RCDMainTabBarViewController ()

@property NSUInteger previousIndex;

@end

@implementation RCDMainTabBarViewController

+ (RCDMainTabBarViewController *)shareInstance {
  static RCDMainTabBarViewController *instance = nil;
  static dispatch_once_t predicate;
  dispatch_once(&predicate, ^{
    instance = [[[self class] alloc] init];
  });
  return instance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  [self setControllers];
  [self setTabBarItems];
  self.delegate = self;
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(changeSelectedIndex:)
                                               name:@"ChangeTabBarIndex"
                                             object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveFriendsRequest) name:@"DidReceiveFriendsRequest" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveFriendsRequest) name:@"DidChangeNewFriendsNumber" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ChangeTabBarIndex" object:nil];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"DidReceiveFriendsRequest" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DidChangeNewFriendsNumber" object:nil];
}

- (void)setControllers {
  RCDChatListViewController *chatVC = [[RCDChatListViewController alloc] init];
  
  RCDContactViewController *contactVC = [[RCDContactViewController alloc] init];
  
  //RCDSquareTableViewController *discoveryVC = [[RCDSquareTableViewController alloc] init];
   
  RCDMeTableViewController *meVC = [[RCDMeTableViewController alloc] init];
    
    WCChatRoomViewController *chatRoomController = [[UIStoryboard storyboardWithName:@"ChatRoom" bundle:nil] instantiateViewControllerWithIdentifier:@"ChatRoom"];
  
  self.viewControllers = @[chatVC, contactVC, chatRoomController,/*discoveryVC,*/ meVC];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[RCDChatListViewController class]]) {
            RCDChatListViewController *chatListVC = (RCDChatListViewController *)obj;
            [chatListVC updateBadgeValueForTabBarItem];
        }
    }];
    [self didChangeNewFriendNumber];
}

-(void)setTabBarItems {
  [self.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    if ([obj isKindOfClass:[RCDChatListViewController class]]) {
      obj.tabBarItem.title = @"果聊";
      obj.tabBarItem.image = [[UIImage imageNamed:@"icon_chat"]
                                       imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
      obj.tabBarItem.selectedImage = [[UIImage imageNamed:@"icon_chat_hover"]
                                               imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    } else if ([obj isKindOfClass:[RCDContactViewController class]]) {
      obj.tabBarItem.title = @"通讯录";
      obj.tabBarItem.image = [[UIImage imageNamed:@"contact_icon"]
                              imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
      obj.tabBarItem.selectedImage = [[UIImage imageNamed:@"contact_icon_hover"]
                                      imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    } else if ([obj isKindOfClass:[WCChatRoomViewController class]]) {
      obj.tabBarItem.title = @"聊天室";
      obj.tabBarItem.image = [[UIImage imageNamed:@"square"]
                              imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
      obj.tabBarItem.selectedImage = [[UIImage imageNamed:@"square_hover"]
                                      imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
//    else if ([obj isKindOfClass:[RCDSquareTableViewController class]]) {
//      obj.tabBarItem.title = @"发现";
//      obj.tabBarItem.image = [[UIImage imageNamed:@"square"]
//                              imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//      obj.tabBarItem.selectedImage = [[UIImage imageNamed:@"square_hover"]
//                                      imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    }
    else if ([obj isKindOfClass:[RCDMeTableViewController class]]){
      obj.tabBarItem.title = @"我";
      obj.tabBarItem.image = [[UIImage imageNamed:@"icon_me"]
                              imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
      obj.tabBarItem.selectedImage = [[UIImage imageNamed:@"icon_me_hover"]
                                      imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    } else {
      NSLog(@"Unknown TabBarController");
    }
  }];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
  NSUInteger index = tabBarController.selectedIndex;
  [RCDMainTabBarViewController shareInstance].selectedTabBarIndex = index;
  switch (index) {
    case 0:
    {
      if (self.previousIndex == index) {
        //判断如果有未读数存在，发出定位到未读数会话的通知
        if ([[RCIMClient sharedRCIMClient] getTotalUnreadCount] > 0) {
          [[NSNotificationCenter defaultCenter] postNotificationName:@"GotoNextCoversation" object:nil];
        }
        self.previousIndex = index;
      }
      self.previousIndex = index;
    }
      break;
      
    case 1:
      self.previousIndex = index;
      break;
      
    case 2:
      self.previousIndex = index;
      break;
      
//    case 3:
//      self.previousIndex = index;
//      break;
      
    default:
      break;
  }
}

//收到好友请求notification
- (void)didReceiveFriendsRequest {
    [RCDDataSource syncFriendList:[RCIM sharedRCIM].currentUserInfo.userId complete:^(NSMutableArray *friends) {
        [self didChangeNewFriendNumber];
    }];
}
//收到接受好友请求notification
- (void)didChangeNewFriendNumber {
    int friendRequestNumber = 0;
    NSMutableArray *temp = [NSMutableArray arrayWithArray:[[RCDataBaseManager shareInstance] getAllFriends]];
    for (RCDUserInfo *user in temp) {
        if ([user.status integerValue] == 2) {
            friendRequestNumber += 1;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (friendRequestNumber > 0) {
            [self.tabBar showBadgeOnItemIndex:1 badgeValue:friendRequestNumber];
        } else {
            [self.tabBar hideBadgeOnItemIndex:1];
        }
    });
}

-(void)changeSelectedIndex:(NSNotification *)notify {
  NSInteger index = [notify.object integerValue];
  self.selectedIndex = index;
}
@end

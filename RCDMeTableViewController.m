//
//  RCDMeTableViewController.m
//  RCloudMessage
//
//  Created by Liv on 14/11/28.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "RCDMeTableViewController.h"
#import "AFHttpTool.h"
#import "DefaultPortraitView.h"
#import "RCDChatViewController.h"
#import "RCDCommonDefine.h"
#import "RCDCustomerServiceViewController.h"
#import "RCDHttpTool.h"
#import "RCDRCIMDataSource.h"
#import "RCDUtilities.h"
#import "RCDataBaseManager.h"
#import "UIColor+RCColor.h"
#import "UIImageView+WebCache.h"
#import <RongIMLib/RongIMLib.h>
#import "RCDSettingsTableViewController.h"
#import "RCDMeInfoTableViewController.h"
#import "RCDAboutRongCloudTableViewController.h"
#import "RCDBaseSettingTableViewCell.h"
#import "RCDMeDetailsCell.h"
#import "RCDMeCell.h"
#import "MyInformationsCell.h"
#import "MyWalletViewController.h"
#import "AppealCenterViewController.h"
#import "WCShareWebViewController.h"
#import "FetchSharePictureRequest.h"
#import "MBProgressHUD+Add.h"
#import "KSBuyVideoView.h"
#import "KSConfigInformationsRequest.h"

#import <OpenShareHeader.h>

/* RedPacket_FTR */
//#import <JrmfWalletKit/JrmfWalletKit.h>

#define SERVICE_ID @"KEFU146001495753714"
#define SERVICE_ID_XIAONENG1 @"kf_4029_1483495902343"
#define SERVICE_ID_XIAONENG2 @"op_1000_1483495280515"

@interface RCDMeTableViewController ()
@property(nonatomic) BOOL hasNewVersion;
@property(nonatomic) NSString *versionUrl;
@property(nonatomic, strong) NSString *versionString;

@property(nonatomic, strong) NSURLConnection *connection;
@property(nonatomic, strong) NSMutableData *receiveData;

@property (strong, nonatomic) UIImageView *avatarImageView;
@property (strong, nonatomic) UILabel *nicknameLabel;

@end

@implementation RCDMeTableViewController {
  UIImage *userPortrait;
  BOOL isSyncCurrentUserInfo;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.edgesForExtendedLayout = UIRectEdgeNone;
  self.navigationController.navigationBar.translucent = NO;
  self.tableView.tableFooterView = [UIView new];
  self.tableView.backgroundColor = [UIColor colorWithHexString:@"f0f0f6" alpha:1.f];
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

  self.tabBarController.navigationItem.rightBarButtonItem = nil;
  self.tabBarController.navigationController.navigationBar.tintColor =
      [UIColor whiteColor];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(setUserPortrait:)
                                               name:@"setCurrentUserPortrait"
                                             object:nil];

  isSyncCurrentUserInfo = NO;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  self.tabBarController.navigationItem.title = @"我";
  self.tabBarController.navigationItem.rightBarButtonItems = nil;
  [self.tableView reloadData];
    
    [self requestForConfigInformations];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Request
- (void)requestForConfigInformations {
    [[KSConfigInformationsRequest new] request:^BOOL(id request) {
        return YES;
    } result:^(id object, NSString *msg) {
        if (object) {
            if (object[@"exchangerate"]) {
                CGFloat exchangeRate = [object[@"exchangerate"] floatValue];
                CGFloat savedExchangeRate = [[NSUserDefaults standardUserDefaults] floatForKey:@"ExchangeRate"];
                if (exchangeRate != savedExchangeRate) {
                    [[NSUserDefaults standardUserDefaults] setFloat:exchangeRate forKey:@"ExchangeRate"];
                }
            }
            if (object[@"videoprice"]) {
                CGFloat videoPrice = [object[@"videoprice"] floatValue];
                CGFloat savedVideoPrice = [[NSUserDefaults standardUserDefaults] floatForKey:@"VideoPrice"];
                if (videoPrice != savedVideoPrice) {
                    [[NSUserDefaults standardUserDefaults] setFloat:videoPrice forKey:@"VideoPrice"];
                }
            }
        } else {
            [MBProgressHUD showError:msg toView:self.view];
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  NSInteger rows = 0;
  switch (section) {
    case 0:
      rows = 1;
      break;
      
    case 1:
    /* RedPacket_FTR */ //添加了红包，row+=1；
          rows = [OpenShare isWeixinInstalled] && [OpenShare isQQInstalled] ? 3 : 2;
      break;
    case 2:
          rows = 1;
          break;
    case 3:
#if RCDDebugTestFunction
      rows = 4;
#else
      rows = 2;
#endif
      break;
      
    default:
      break;
  }
  return rows;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *reusableCellWithIdentifier = @"RCDMeCell";
  RCDMeCell *cell = [self.tableView
                                       dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];
  
  static NSString *detailsCellWithIdentifier = @"RCDMeDetailsCell";
  MyInformationsCell *detailsCell = [self.tableView
                                       dequeueReusableCellWithIdentifier:detailsCellWithIdentifier];
  if (cell == nil) {
    cell = [[RCDMeCell alloc] init];
  }
  if (detailsCell == nil) {
    detailsCell = [[MyInformationsCell alloc] init];
  }
    
  switch (indexPath.section) {
    case 0: {
      switch (indexPath.row) {
        case 0: {
//            static NSString *identifier = @"InformationCell";
//            UITableViewCell *informationCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
//            if (!_avatarImageView) {
//                _avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 11.5, 65, 65)];
//                _avatarImageView.layer.masksToBounds = YES;
//                _avatarImageView.layer.cornerRadius = 5.f;
//            }
//            [informationCell.contentView addSubview:_avatarImageView];
//            NSString *portraitUrl = [DEFAULTS stringForKey:@"userPortraitUri"];
//            if (!portraitUrl || [portraitUrl isEqualToString:@""]) {
//                portraitUrl = [RCDUtilities defaultUserPortrait:[RCIM sharedRCIM].currentUserInfo];
//                _avatarImageView.image = [UIImage imageNamed:portraitUrl];
//            } else {
//                [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:portraitUrl] placeholderImage:nil];
//            }
//            if (!_nicknameLabel) {
//                _nicknameLabel = [[UILabel alloc] initWithFrame:CGRectMake(83, 29, 300, 30)];
//                _nicknameLabel.textColor = [UIColor blackColor];
//                _nicknameLabel.font = [UIFont systemFontOfSize:16];
//            }
//            [informationCell.contentView addSubview:_nicknameLabel];
//            _nicknameLabel.text = [DEFAULTS stringForKey:@"userNickName"];
//          return informationCell;
            return detailsCell;
        }
          break;
          
        default:
          break;
      }
    }
      break;
      
    case 1: {
        switch (indexPath.row) {
            case 0: {
                [cell setCellWithImageName:@"setting_up" labelName:@"账号设置"];
            }
                break;
          
          /* RedPacket_FTR */ //wallet cell
            case 1: {
                [cell setCellWithImageName:@"wallet" labelName:@"我的快豆"];
            }
                break;
            case 2: {
                [cell setCellWithImageName:@"mine_share" labelName:@"分享赚快豆"];
            }
                break;
            default:
                break;
        }
      return cell;
    }
      break;
      case 2: {
          [cell setCellWithImageName:@"icon_buy_video" labelName:@"购买视频空间"];
          return cell;
      }
          break;
    case 3: {
      switch (indexPath.row) {
        case 0:{
          [cell setCellWithImageName:@"sevre_inactive" labelName:@"投诉与建议"];
          return cell;
        }
          break;
          case 1: {
              [cell setCellWithImageName:@"mine_copy_link" labelName:@"复制官网地址"];
              return cell;
          }
              break;
          
//        case 1:{
//          [cell setCellWithImageName:@"about_rongcloud" labelName:@"关于 SealTalk"];
//          NSString *isNeedUpdate = [[NSUserDefaults standardUserDefaults] objectForKey:@"isNeedUpdate"];
//          if ([isNeedUpdate isEqualToString:@"YES"]) {
//            [cell addRedpointImageView];
//          }
//          return cell;
//        }
//          break;
#if RCDDebugTestFunction
        case 2:{
          [cell setCellWithImageName:@"sevre_inactive" labelName:@"小能客服1"];
          return cell;
        }
          break;
        case 3:{
          [cell setCellWithImageName:@"sevre_inactive" labelName:@"小能客服2"];
          return cell;
        }
          break;
#endif
        default:
          break;
      }
    }
      break;
      
    default:
      break;
  }
  
  return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  CGFloat height;
  switch (indexPath.section) {
    case 0:{
          height = 88.f;
      }
      break;
      
    default:
      height = 44.f;
      break;
  }
  return height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  switch (indexPath.section) {
    case 0: {
      RCDMeInfoTableViewController *vc = [[RCDMeInfoTableViewController alloc] init];
      [self.navigationController pushViewController:vc animated:YES];
    }
      break;
      
    case 1: {
      switch (indexPath.row) {
        case 0: {
          RCDSettingsTableViewController *vc = [[RCDSettingsTableViewController alloc] init];
          [self.navigationController pushViewController:vc
                                               animated:YES];
        }
          break;
        /* RedPacket_FTR */ //open my wallet
          case 1: {
              //[JrmfWalletSDK openWallet];
              MyWalletViewController *walletViewController = [[UIStoryboard storyboardWithName:@"RedPacket" bundle:nil] instantiateViewControllerWithIdentifier:@"MyWallet"];
              [self.navigationController pushViewController:walletViewController animated:YES];
          }
              break;
          case 2:{
              [tableView deselectRowAtIndexPath:indexPath animated:YES];
//              self.shareView.hidden = NO;
//              [UIView animateWithDuration:0.2 animations:^{
//                  self.contentView.frame = CGRectMake(0, CGRectGetHeight([UIScreen mainScreen].bounds) - 150, CGRectGetWidth([UIScreen mainScreen].bounds), 150);
//              }];
              WCShareWebViewController *shareController = [[UIStoryboard storyboardWithName:@"Additional" bundle:nil] instantiateViewControllerWithIdentifier:@"ShareWeb"];
              [self.navigationController pushViewController:shareController animated:YES];
          }
              break;
          
        default:
          break;
      }
    }
      break;
      case 2: {
          [tableView deselectRowAtIndexPath:indexPath animated:YES];
          if ([[NSUserDefaults standardUserDefaults] floatForKey:@"VideoPrice"]) {
              KSBuyVideoView *buyView = [[KSBuyVideoView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
              [buyView show];
          } else {
              [MBProgressHUD showError:@"请检查网络" toView:self.view];
          }
          
      }
          break;
      
    case 3: {
      switch (indexPath.row) {
        case 0: {
          //[self chatWithCustomerService:SERVICE_ID];
            AppealCenterViewController *appealCenterController = [[UIStoryboard storyboardWithName:@"RedPacket" bundle:nil] instantiateViewControllerWithIdentifier:@"AppealCenter"];
            [self.navigationController pushViewController:appealCenterController animated:YES];
        }
          break;
          
        case 1: {
//          RCDAboutRongCloudTableViewController *vc = [[RCDAboutRongCloudTableViewController alloc] init];
//          [self.navigationController pushViewController:vc animated:YES];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"官网地址" message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.enabled = NO;
                textField.text = @"http://www.juicychat.cn";
                textField.textAlignment = NSTextAlignmentCenter;
            }];
            UIAlertAction *copyAction = [UIAlertAction actionWithTitle:@"复制" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = @"http://www.juicychat.cn";
                [MBProgressHUD showSuccess:@"已经复制到粘贴板" toView:self.view];
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            [alertController addAction:copyAction];
            [alertController addAction:cancelAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
          break;
#if RCDDebugTestFunction
        case 2: {
          [self chatWithCustomerService:SERVICE_ID_XIAONENG1];
        }
          break;
        case 3: {
          [self chatWithCustomerService:SERVICE_ID_XIAONENG2];
        }
          break;
#endif
        default:
          break;
      }
    }
      break;
    default:
      break;
  }
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForHeaderInSection:(NSInteger)section {
    return 15.f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}

- (void)setUserPortrait:(NSNotification *)notifycation {
  userPortrait = [notifycation object];
}

- (void)chatWithCustomerService:(NSString *)kefuId {
  RCDCustomerServiceViewController *chatService =
      [[RCDCustomerServiceViewController alloc] init];
  // live800  KEFU146227005669524   live800的客服ID
  // zhichi   KEFU146001495753714   智齿的客服ID
  chatService.conversationType = ConversationType_CUSTOMERSERVICE;

  chatService.targetId = kefuId;

  //上传用户信息，nickname是必须要填写的
  RCCustomerServiceInfo *csInfo = [[RCCustomerServiceInfo alloc] init];
  csInfo.userId = [RCIMClient sharedRCIMClient].currentUserInfo.userId;
  csInfo.nickName = @"昵称";
  csInfo.loginName = @"登录名称";
  csInfo.name = @"用户名称";
  csInfo.grade = @"11级";
  csInfo.gender = @"男";
  csInfo.birthday = @"2016.5.1";
  csInfo.age = @"36";
  csInfo.profession = @"software engineer";
  csInfo.portraitUrl =
      [RCIMClient sharedRCIMClient].currentUserInfo.portraitUri;
  csInfo.province = @"beijing";
  csInfo.city = @"beijing";
  csInfo.memo = @"这是一个好顾客!";

  csInfo.mobileNo = @"13800000000";
  csInfo.email = @"test@example.com";
  csInfo.address = @"北京市北苑路北泰岳大厦";
  csInfo.QQ = @"88888888";
  csInfo.weibo = @"my weibo account";
  csInfo.weixin = @"myweixin";

  csInfo.page = @"卖化妆品的页面来的";
  csInfo.referrer = @"客户端";
  csInfo.enterUrl = @"testurl";
  csInfo.skillId = @"技能组";
  csInfo.listUrl = @[@"用户浏览的第一个商品Url",
                      @"用户浏览的第二个商品Url"];
  csInfo.define = @"自定义信息";

  chatService.csInfo = csInfo;
  chatService.title = @"客服";

  [self.navigationController pushViewController:chatService animated:YES];
}


@end

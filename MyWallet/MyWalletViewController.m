//
//  MyWalletViewController.m
//  RCloudMessage
//
//  Created by 项小盆友 on 2017/5/18.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import "MyWalletViewController.h"
#import "SetupPayPasswordViewController.h"
#import "SecuritySettingTableViewController.h"
#import "MyRedPacketsViewController.h"
#import "LockedMoneyViewController.h"
#import "XJTransferRecordViewController.h"

#import "CheckSetPayPasswordRequest.h"
#import "FetchBalanceRequest.h"
#import "MBProgressHUD.h"
#import "RCDUtilities.h"
#import "MJRefresh.h"

#import <OpenShareHeader.h>

@interface MyWalletViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *pocketMoneyLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) BOOL isShowRecharge;

@end

@implementation MyWalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _isShowRecharge = [OpenShare isWeixinInstalled] && [OpenShare isQQInstalled];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self fetchBalance];
    }];
    
    [self fetchBalance];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)fetchBalance {
    [[FetchBalanceRequest new] request:^BOOL(id request) {
        return YES;
    } result:^(id object, NSString *msg) {
        [self.tableView.mj_header endRefreshing];
        if (object) {
            self.pocketMoneyLabel.text = [RCDUtilities amountStringFromFloat:[object[@"money"] floatValue]];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"网络错误" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
        }
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _isShowRecharge ? 4 : 3;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.imageView.image = [UIImage imageNamed:@"pic_packet"];
        cell.textLabel.text = @"我的红包";
    } else if (indexPath.row == 1) {
        cell.imageView.image = _isShowRecharge ? [UIImage imageNamed:@"icon_recharge"] : [UIImage imageNamed:@"transaction-record"];
        cell.textLabel.text = _isShowRecharge ? @"快豆充值" : @"交易记录";
    } else if (indexPath.row == 2) {
        cell.imageView.image = _isShowRecharge ? [UIImage imageNamed:@"transaction-record"] : [UIImage imageNamed:@"lock_money"];
        cell.textLabel.text = _isShowRecharge ? @"交易记录" : @"冻结快豆";
    }
    else {
        cell.imageView.image = [UIImage imageNamed:@"lock_money"];
        cell.textLabel.text = @"冻结快豆";
    }
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20.f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [UIView new];
    headerView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1];
    return headerView;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        MyRedPacketsViewController *viewController = [[UIStoryboard storyboardWithName:@"RedPacket" bundle:nil] instantiateViewControllerWithIdentifier:@"MyRedPackets"];
        [self.navigationController pushViewController:viewController animated:YES];
    } else if (indexPath.row == 1) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if (_isShowRecharge) {
            //快豆充值
        } else {
            XJTransferRecordViewController *recordControll = [[UIStoryboard storyboardWithName:@"Transfer" bundle:nil] instantiateViewControllerWithIdentifier:@"TransferRecord"];
            [self.navigationController pushViewController:recordControll animated:YES];
        }
    } else if (indexPath.row == 2) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if (_isShowRecharge) {
            XJTransferRecordViewController *recordControll = [[UIStoryboard storyboardWithName:@"Transfer" bundle:nil] instantiateViewControllerWithIdentifier:@"TransferRecord"];
            [self.navigationController pushViewController:recordControll animated:YES];
        } else {
            LockedMoneyViewController *viewController = [[UIStoryboard storyboardWithName:@"RedPacket" bundle:nil] instantiateViewControllerWithIdentifier:@"LockedMoney"];
            [self.navigationController pushViewController:viewController animated:YES];
        }
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        LockedMoneyViewController *viewController = [[UIStoryboard storyboardWithName:@"RedPacket" bundle:nil] instantiateViewControllerWithIdentifier:@"LockedMoney"];
        [self.navigationController pushViewController:viewController animated:YES];
    }
//    else {
//        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        [[CheckSetPayPasswordRequest new] request:^BOOL(id request) {
//            return YES;
//        } result:^(id object, NSString *msg) {
//            [MBProgressHUD hideHUDForView:self.view animated:YES];
//            [tableView deselectRowAtIndexPath:indexPath animated:YES];
//            if (object) {
//                if ([object[@"code"] integerValue] == 200) {
//                    SecuritySettingTableViewController *settingViewController = [[SecuritySettingTableViewController alloc] init];
//                    [self.navigationController pushViewController:settingViewController animated:YES];
//                } else if ([object[@"code"] integerValue] == 66001) {
//                    SetupPayPasswordViewController *setupPayPassword = [[UIStoryboard storyboardWithName:@"RedPacket" bundle:nil] instantiateViewControllerWithIdentifier:@"SetupPayPassword"];
//                    [self.navigationController pushViewController:setupPayPassword animated:YES];
//                } else {
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"网络错误" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
//                    [alert show];
//                }
//            }
//
//        }];
//    }
    
}
- (NSString *)countingString:(NSInteger)count {
    NSInteger yi = 0;
    NSInteger wan = 0;
    if (count / 100000000 > 0) {
        yi = count / 100000000;
        count = count - yi * 100000000;
    }
    if (count / 10000 > 0) {
        wan = count / 10000;
        count = count - wan * 10000;
    }
    NSString *countingString = @"";
    if (yi > 0) {
        countingString = [NSString stringWithFormat:@"%@%@亿", countingString, @(yi)];
    }
    if (wan > 0) {
        countingString = [NSString stringWithFormat:@"%@%@万", countingString, @(wan)];
    }
    if (count > 0) {
        countingString = [NSString stringWithFormat:@"%@%@", countingString, @(count)];
    }
    if (countingString.length < 5 && yi == 0 && wan == 0) {
        return nil;
    } else {
        return countingString;
    }
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

//
//  WCVideoFileTableViewController.m
//  SealTalk
//
//  Created by 项小盆友 on 2018/1/3.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "WCVideoFileTableViewController.h"

#import "WCVideoFileCell.h"

#import "WCVideoFileListRequest.h"
#import "WCVideoFileModel.h"
#import "MBProgressHUD+Add.h"

@interface WCVideoFileTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *emptyLabel;

@property (copy, nonatomic) NSArray *fileArray;

@end

@implementation WCVideoFileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)uploadAction:(id)sender {
}
- (IBAction)backAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)listRequest {
    [MBProgressHUD showMessag:nil toView:self.view];
    [[WCVideoFileListRequest new] request:^BOOL(id request) {
        return YES;
    } result:^(id object, NSString *msg) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (object) {
            _fileArray = [WCVideoFileModel setupWithArray:(NSArray *)object];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                if (_fileArray.count > 0) {
                    self.tableView.tableFooterView = nil;
                } else {
                    self.tableView.tableFooterView = self.emptyLabel;
                    self.emptyLabel.text = @"暂无视频文件";
                }
            });
        } else {
            [MBProgressHUD showError:msg toView:self.view];
            self.tableView.tableFooterView = self.emptyLabel;
            self.emptyLabel.text = @"网络错误";
        }
    }];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _fileArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WCVideoFileCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VideoFileCell" forIndexPath:indexPath];
    
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
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

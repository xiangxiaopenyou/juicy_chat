//
//  WCAddFriendTableViewController.m
//  SealTalk
//
//  Created by 项小盆友 on 2017/12/27.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import "WCAddFriendTableViewController.h"
#import "RCDHttpTool.h"
#import "MBProgressHUD+Add.h"

@interface WCAddFriendTableViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) UIButton *sendButton;

@end

@implementation WCAddFriendTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.sendButton];
    NSString *nameString = [[NSUserDefaults standardUserDefaults] stringForKey:@"userNickName"];
    self.textField.text = [NSString stringWithFormat:@"我是%@，想加你为好友", nameString];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.textField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)noteDidChanged:(id)sender {
    self.sendButton.enabled = self.textField.text.length > 0 ? YES : NO;
    UIColor *buttonColor = self.textField.text.length > 0 ? [UIColor whiteColor] : [UIColor grayColor];
    [self.sendButton setTitleColor:buttonColor forState:UIControlStateNormal];
}
- (void)sendAction {
    [self addFriendRequest];
}

#pragma mark - Request
- (void)addFriendRequest {
    [self.textField resignFirstResponder];
    [MBProgressHUD showMessag:@"正在发送..." toView:self.view];
    self.sendButton.enabled = NO;
    [RCDHTTPTOOL requestFriend:self.friendId note:self.textField.text complete:^(id result) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.sendButton.enabled = YES;
        if ([result boolValue]) {
            [MBProgressHUD showSuccess:@"发送成功" toView:self.view];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        } else {
            [MBProgressHUD showError:(NSString *)result toView:self.view];
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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

- (UIButton *)sendButton {
    if (!_sendButton) {
        _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendButton.frame = CGRectMake(0, 0, 40, 40);
        _sendButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_sendButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, - 10)];
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
        [_sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sendButton addTarget:self action:@selector(sendAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendButton;
}

@end

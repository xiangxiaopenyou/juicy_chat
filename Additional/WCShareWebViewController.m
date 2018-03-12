//
//  WCShareWebViewController.m
//  SealTalk
//
//  Created by 项小盆友 on 2017/10/23.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import "WCShareWebViewController.h"
#import "XLPopView.h"
#import "RequestManager.h"
#import "WCFetchShareLinkRequest.h"
#import "ShareRewardRequest.h"
#import "FetchSharePictureRequest.h"
#import "MBProgressHUD+Add.h"

#import <OpenShareHeader.h>
#import <JavaScriptCore/JavaScriptCore.h>
typedef NS_ENUM(NSInteger, WCShareType) {
    WCShareTypeInvite,
    WCShareTypeSharing
};
@interface WCShareWebViewController ()<UIWebViewDelegate, XLPopViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) XLPopView *popView;

@property (copy, nonatomic) NSString *shareLinkUrlString;
@property (copy, nonatomic) NSString *sharePictureUrlString;
@property (copy, nonatomic) NSString *titleString;
@property (copy, nonatomic) NSString *contentString;
@property (assign, nonatomic) WCShareType shareType;
@end

@implementation WCShareWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *webUrlString = @"http://121.43.184.230:7654/app/Share.aspx";
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:webUrlString]];
    [self.webView loadRequest:request];
    [self shareLinkRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backAction:(id)sender {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)shareLinkRequest {
    [MBProgressHUD showMessag:nil toView:self.view];
    [[WCFetchShareLinkRequest new] request:^BOOL(id request) {
        return YES;
    } result:^(id object, NSString *msg) {
        if (msg) {
            [MBProgressHUD showError:msg toView:self.view];
        } else {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            _shareLinkUrlString = object[@"linkUrl"];
            _sharePictureUrlString = object[@"imgUrl"];
            _titleString = object[@"title"];
            _contentString = object[@"content"];
            
        }
    }];
}
- (void)fetchShareReward {
    [[ShareRewardRequest new] request:^BOOL(id request) {
        return YES;
    } result:^(id object, NSString *msg) {
        if (object) {
            NSInteger money = [object[@"money"] integerValue];
            if (money > 0) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"分享成功，奖励%@快豆", @(money)] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"分享成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
            }
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
        }
    }];
}
//- (void)fetchSharePictureRequest {
//    [[FetchSharePictureRequest new] request:^BOOL(id request) {
//        return YES;
//    } result:^(id object, NSString *msg) {
//        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//        if (object) {
//            _commonSharePictureString = object[@"url"];
//        }
//    }];
//}

//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
//    NSString *requestString = [[[request URL] absoluteString] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    if ([requestString containsString:@""]) {
//
//        return NO;
//    } else if ([requestString containsString:@""]) {
//        return NO;
//    }
//    return YES;
//}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [webView stringByEvaluatingJavaScriptFromString:@"SharePage={};"];
    NSString *jsMethodString1 = [NSString stringWithFormat:@"SharePage.Invite();"];
    NSString *jsMethodString2 = [NSString stringWithFormat:@"SharePage.Share();"];
    [webView stringByEvaluatingJavaScriptFromString:jsMethodString1];
    [webView stringByEvaluatingJavaScriptFromString:jsMethodString2];
    JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    context[@"SharePage"][@"Invite"] = ^(){
        _shareType = WCShareTypeInvite;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.popView.viewTitle = @"邀请好友";
            self.popView.images = @[@"wechat_login", @"qq_login"];
            [self.popView show];
        });
    };
    context[@"SharePage"][@"Share"] = ^(){
        _shareType = WCShareTypeSharing;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.popView.viewTitle = @"分享到";
            self.popView.images = @[@"icon_wechat_timeline", @"icon_qq_zone"];
            [self.popView show];
        });
    };
}

#pragma mark - XLPopView delegate
- (void)didClickButton:(NSInteger)index {
    OSMessage *message = [[OSMessage alloc] init];
    message.title = _titleString;
    message.desc = _contentString;
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:_sharePictureUrlString]];
    message.image = imageData;
    message.thumbnail = imageData;
    message.link = _shareLinkUrlString;
    if (_shareType == WCShareTypeInvite) {
        if (index == 0) {
            [OpenShare shareToWeixinSession:message Success:^(OSMessage *message) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"分享成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
            } Fail:^(OSMessage *message, NSError *error) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"分享失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
            }];
        } else {
            [OpenShare shareToQQFriends:message Success:^(OSMessage *message) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"分享成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
            } Fail:^(OSMessage *message, NSError *error) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"分享失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
            }];
        }
    } else {
        if (index == 0) {
            [OpenShare shareToWeixinTimeline:message Success:^(OSMessage *message) {
                //[self fetchShareReward];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"分享成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
            } Fail:^(OSMessage *message, NSError *error) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"分享失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
            }];
        } else {
            [OpenShare shareToQQZone:message Success:^(OSMessage *message) {
                //[self fetchShareReward];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"分享成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
            } Fail:^(OSMessage *message, NSError *error) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"分享失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
            }];
        }
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
#pragma mark - Getters
- (XLPopView *)popView {
    if (!_popView) {
        _popView = [[XLPopView alloc] initWithFrame:[UIScreen mainScreen].bounds images:nil title:nil];
        _popView.delegate = self;
    }
    return _popView;
}

@end

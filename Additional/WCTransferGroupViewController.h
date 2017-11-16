//
//  WCTransferGroupViewController.h
//  SealTalk
//
//  Created by 项小盆友 on 2017/11/15.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RCDGroupInfo;

@interface WCTransferGroupViewController : UIViewController
@property (strong, nonatomic) RCDGroupInfo *groupInfo;

@property (copy, nonatomic) void (^transferBlock)(NSString *userId);

@end

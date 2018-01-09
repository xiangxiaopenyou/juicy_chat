//
//  WCVideoFileTableViewController.h
//  SealTalk
//
//  Created by 项小盆友 on 2018/1/3.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WCVideoFileModel;

@interface WCVideoFileTableViewController : UITableViewController

@property (copy, nonatomic) void (^sendBlock)(WCVideoFileModel *model);

@end

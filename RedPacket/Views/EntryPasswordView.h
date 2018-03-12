//
//  EntryPasswordView.h
//  RCloudMessage
//
//  Created by 项小盆友 on 2017/5/11.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EntryPasswordView : UIView
@property (assign, nonatomic) CGFloat amount;
@property (assign, nonatomic) CGFloat balance;

- (void)show;
- (void)closeAction;
- (void)clearPassword;

@end

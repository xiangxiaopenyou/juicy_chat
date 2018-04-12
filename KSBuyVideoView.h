//
//  KSBuyVideoView.h
//  SealTalk
//
//  Created by 项小盆友 on 2018/3/14.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KSBuyVideoView : UIView
@property (copy, nonatomic) void (^payBlock)(NSString *priceString, NSInteger number);
- (void)show;
@end

//
//  WCVideoFileMessageCell.h
//  SealTalk
//
//  Created by 项小盆友 on 2018/1/8.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>

@interface WCVideoFileMessageCell : RCMessageCell

@property(nonatomic, strong) UIImageView *bubbleBackgroundView;
@property (strong, nonatomic) UIImageView *videoImageView;
@property (strong, nonatomic) UIImageView *iconImageView;

@end

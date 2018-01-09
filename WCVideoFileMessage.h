//
//  WCVideoFileMessage.h
//  SealTalk
//
//  Created by 项小盆友 on 2018/1/8.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

static NSString *const WCVideoFileMessageTypeIdentifier = @"JC:VideoFileMsg";

@interface WCVideoFileMessage : RCMessageContent <NSCoding>
@property (copy, nonatomic) NSString *url;
@property (strong, nonatomic) NSNumber *duration;
+ (instancetype)messageWithUrl:(NSString *)url duration:(NSNumber *)duration;

@end

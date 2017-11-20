//
//  RedPacketMessage.h
//  RCloudMessage
//
//  Created by 项小盆友 on 2017/5/12.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>
static NSString *const RedPacketMessageTypeIdentifier = @"JC:RedPacketMsg";

@interface RedPacketMessage : RCMessageContent<NSCoding>
@property (copy, nonatomic) NSString *content;
@property (copy, nonatomic) NSString *redpacketId;
@property (copy, nonatomic) NSString *fromuserid;
@property (copy, nonatomic) NSString *tomemberid;
@property (copy, nonatomic) NSString *createtime;
@property (strong, nonatomic) NSNumber *state;
@property (strong, nonatomic) NSNumber *count;
@property (strong, nonatomic) NSNumber *sort;
@property (strong, nonatomic) NSNumber *money;
@property (strong, nonatomic) NSNumber *type;

+ (instancetype)messageWithContent:(NSString *)content
                       redPacketId:(NSString *)redpacketId
                        fromuserid:(NSString *)fromuserid
                        tomemberid:(NSString *)tomemberid
                        createtime:(NSString *)createtime
                             state:(NSNumber *)state
                             count:(NSNumber *)count
                              sort:(NSNumber *)sort
                             money:(NSNumber *)money
                              type:(NSNumber *)type;

@end

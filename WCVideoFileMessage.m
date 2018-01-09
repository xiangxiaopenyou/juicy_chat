//
//  WCVideoFileMessage.m
//  SealTalk
//
//  Created by 项小盆友 on 2018/1/8.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "WCVideoFileMessage.h"

@implementation WCVideoFileMessage
+ (instancetype)messageWithUrl:(NSString *)url duration:(NSNumber *)duration {
    WCVideoFileMessage *message = [[WCVideoFileMessage alloc] init];
    if (message) {
        message.url = url;
        message.duration = duration;
    }
    return message;
}
+ (RCMessagePersistent)persistentFlag {
    return MessagePersistent_ISCOUNTED | MessagePersistent_ISPERSISTED;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.url = [aDecoder decodeObjectForKey:@"url"];
        self.duration = [aDecoder decodeObjectForKey:@"duration"];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.url forKey:@"url"];
    [aCoder encodeObject:self.duration forKey:@"duration"];
}
- (NSData *)encode {
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    if (self.url) {
        [dataDict setObject:self.url forKey:@"url"];
    }
    if (self.duration) {
        [dataDict setObject:self.duration forKey:@"duration"];
    }
    if (self.senderUserInfo) {
        NSMutableDictionary *userInfoDic = [[NSMutableDictionary alloc] init];
        if (self.senderUserInfo.name) {
            [userInfoDic setObject:self.senderUserInfo.name
                 forKeyedSubscript:@"name"];
        }
        if (self.senderUserInfo.portraitUri) {
            [userInfoDic setObject:self.senderUserInfo.portraitUri
                 forKeyedSubscript:@"icon"];
        }
        if (self.senderUserInfo.userId) {
            [userInfoDic setObject:self.senderUserInfo.userId
                 forKeyedSubscript:@"id"];
        }
        [dataDict setObject:userInfoDic forKey:@"user"];
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:dataDict
                                                   options:kNilOptions
                                                     error:nil];
    return data;
}
- (void)decodeWithData:(NSData *)data {
    if (data) {
        __autoreleasing NSError *error = nil;
        
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                   options:kNilOptions
                                                                     error:&error];
        
        if (dictionary) {
            self.url = dictionary[@"url"];
            self.duration = dictionary[@"duration"];
            NSDictionary *userinfoDic = dictionary[@"user"];
            [self decodeUserInfo:userinfoDic];
        }
    }
}
/// 会话列表中显示的摘要
- (NSString *)conversationDigest {
    return @"[视频文件]";
}

///消息的类型名
+ (NSString *)getObjectName {
    return WCVideoFileMessageTypeIdentifier;
}

@end

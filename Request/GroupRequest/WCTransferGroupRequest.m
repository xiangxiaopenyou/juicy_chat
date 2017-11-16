//
//  WCTransferGroupRequest.m
//  SealTalk
//
//  Created by 项小盆友 on 2017/11/15.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import "WCTransferGroupRequest.h"

@implementation WCTransferGroupRequest
- (void)request:(ParamsBlock)paramsBlock result:(RequestResultHandler)resultHandler {
    if (!paramsBlock(self)) {
        return;
    }
    [self.params setObject:self.groupId forKey:@"groupid"];
    [self.params setObject:self.userId forKey:@"touserid"];
    [[RequestManager sharedInstance] POST:@"TransGroupLeader.aspx" parameters:self.params success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject[@"code"] integerValue] == 200) {
            !resultHandler ?: resultHandler(@(YES), nil);
        } else {
            !resultHandler ?: resultHandler(nil, responseObject[@"message"]);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !resultHandler ?: resultHandler(nil, @"请检查网络");
    }];
}

@end

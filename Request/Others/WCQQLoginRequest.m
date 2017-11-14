//
//  WCQQLoginRequest.m
//  SealTalk
//
//  Created by 项小盆友 on 2017/11/13.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import "WCQQLoginRequest.h"

@implementation WCQQLoginRequest
- (void)request:(ParamsBlock)paramsBlock result:(RequestResultHandler)resultHandler {
    if (!paramsBlock(self)) {
        return;
    }
    [self.params setObject:self.code forKey:@"qqcode"];
    [[RequestManager sharedInstance] POST:@"LoginByQQ.aspx" parameters:self.params success:^(NSURLSessionDataTask *task, id responseObject) {
        !resultHandler ?: resultHandler(responseObject, responseObject[@"message"]);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !resultHandler ?: resultHandler(nil, error.description);
    }];
}

@end

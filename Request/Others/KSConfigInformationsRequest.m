//
//  KSConfigInformationsRequest.m
//  SealTalk
//
//  Created by 项小盆友 on 2018/3/14.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "KSConfigInformationsRequest.h"

@implementation KSConfigInformationsRequest
- (void)request:(ParamsBlock)paramsBlock result:(RequestResultHandler)resultHandler {
    if (!paramsBlock(self)) {
        return;
    }
    [[RequestManager sharedInstance] POST:@"GetConfig.aspx" parameters:self.params success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject[@"code"] integerValue] == 200) {
            !resultHandler ?: resultHandler(responseObject[@"data"], nil);
        } else {
            !resultHandler ?: resultHandler(nil, responseObject[@"message"]);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !resultHandler ?: resultHandler(nil, error.description);
    }];
}

@end

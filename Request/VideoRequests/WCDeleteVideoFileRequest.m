//
//  WCDeleteVideoFileRequest.m
//  SealTalk
//
//  Created by 项小盆友 on 2018/1/3.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "WCDeleteVideoFileRequest.h"

@implementation WCDeleteVideoFileRequest
- (void)request:(ParamsBlock)paramsBlock result:(RequestResultHandler)resultHandler {
    if (!paramsBlock(self)) {
        return;
    }
    [self.params setObject:self.videoId forKey:@"videoid"];
    [[RequestManager sharedInstance] POST:@"RemoveVideo.aspx" parameters:self.params success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject[@"code"] integerValue] == 200) {
            !resultHandler ?: resultHandler(@YES, nil);
        } else {
            !resultHandler ?: resultHandler(nil, responseObject[@"message"]);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !resultHandler ?: resultHandler(nil, @"网络错误");
    }];
}

@end

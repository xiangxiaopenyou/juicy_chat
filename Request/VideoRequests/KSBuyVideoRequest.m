//
//  KSBuyVideoRequest.m
//  SealTalk
//
//  Created by 项小盆友 on 2018/3/19.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "KSBuyVideoRequest.h"

@implementation KSBuyVideoRequest
- (void)request:(ParamsBlock)paramsBlock result:(RequestResultHandler)resultHandler {
    if (!paramsBlock(self)) {
        return;
    }
    [self.params setObject:@(self.buynum) forKey:@"buynum"];
    [self.params setObject:self.buymoney forKey:@"buymoney"];
    [self.params setObject:self.paypwd forKey:@"paypwd"];
    [[RequestManager sharedInstance] POST:@"BuyVideoLimit.aspx" parameters:self.params success:^(NSURLSessionDataTask *task, id responseObject) {
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

//
//  WCUploadFileRequestManager.m
//  SealTalk
//
//  Created by 项小盆友 on 2018/1/4.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "WCUploadFileRequestManager.h"
#import "AFNetworking.h"
#import "QiniuSDK.h"
#import <RongIMKit/RongIMKit.h>

@implementation WCUploadFileRequestManager
- (instancetype)initWithConfiguration:(QNConfiguration *)config {
    QNConfiguration *qnConfig = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
    }];
    WCUploadFileRequestManager *manager = [[WCUploadFileRequestManager alloc] initWithConfiguration:qnConfig];
    return manager;
}
+ (void)uploadQNVideoFile:(NSString *)fileName fileUrl:(NSString *)fileUrl token:(NSString *)token {
    QNConfiguration *config = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
    }];
    QNUploadManager *manager = [[QNUploadManager alloc] initWithConfiguration:config];
    [manager putFile:fileUrl key:fileName token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        
    } option:nil];
}

@end

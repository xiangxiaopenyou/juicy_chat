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
+ (void)uploadQNVideoFile:(NSString *)fileName fileUrl:(NSString *)fileUrl token:(NSString *)token {
    QNUploadOption *option = [[QNUploadOption alloc] initWithMime:nil progressHandler:^(NSString *key, float percent) {
//        [_fileArray enumerateObjectsUsingBlock:^(WCVideoFileModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            if ([obj.identifier isEqualToString:tempModel.identifier]) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    WCVideoFileCell *tempCell = (WCVideoFileCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
//                    [tempCell.progressView setProgress:percent animated:YES];
//                });
//            }
//        }];
    } params:nil checkCrc:YES cancellationSignal:nil];
    QNUploadManager *manager = [[QNUploadManager alloc] init];
    [manager putFile:fileUrl key:fileName token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        
    } option:option];
}

@end

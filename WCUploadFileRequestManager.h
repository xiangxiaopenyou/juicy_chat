//
//  WCUploadFileRequestManager.h
//  SealTalk
//
//  Created by 项小盆友 on 2018/1/4.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QiniuSDK.h"

@interface WCUploadFileRequestManager : NSObject
+ (void)uploadQNVideoFile:(NSString *)fileName fileUrl:(NSString *)fileUrl token:(NSString *)token;
@end

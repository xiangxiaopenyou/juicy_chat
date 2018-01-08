//
//  WCUploadVideoRequest.h
//  SealTalk
//
//  Created by 项小盆友 on 2018/1/3.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "BaseRequest.h"

@interface WCUploadVideoRequest : BaseRequest
@property (copy, nonatomic) NSString *url;
@property (copy, nonatomic) NSString *name;
@property (strong, nonatomic) NSNumber *duration;

@end

//
//  WCTransferGroupRequest.h
//  SealTalk
//
//  Created by 项小盆友 on 2017/11/15.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import "BaseRequest.h"

@interface WCTransferGroupRequest : BaseRequest
@property (copy, nonatomic) NSString *groupId;
@property (copy, nonatomic) NSString *userId;

@end

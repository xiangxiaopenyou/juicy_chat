//
//  UnlockMoneyRequest.h
//  RCloudMessage
//
//  Created by 项小盆友 on 2017/5/21.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import "BaseRequest.h"

@interface UnlockMoneyRequest : BaseRequest
@property (copy, nonatomic) NSString *groupId;
@property (copy, nonatomic) NSArray *userIds;

@end
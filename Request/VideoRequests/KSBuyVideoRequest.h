//
//  KSBuyVideoRequest.h
//  SealTalk
//
//  Created by 项小盆友 on 2018/3/19.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "BaseRequest.h"

@interface KSBuyVideoRequest : BaseRequest
@property (copy, nonatomic) NSString *buymoney;
@property (copy, nonatomic) NSString *paypwd;
@property (assign, nonatomic) NSInteger buynum;

@end

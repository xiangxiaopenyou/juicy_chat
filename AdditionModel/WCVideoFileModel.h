//
//  WCVideoFileModel.h
//  SealTalk
//
//  Created by 项小盆友 on 2018/1/3.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "XLModel.h"

@interface WCVideoFileModel : XLModel
@property (copy, nonatomic) NSString *id;
@property (copy, nonatomic) NSString *userid;
@property (copy, nonatomic) NSString *url;
@property (copy, nonatomic) NSString<Optional> *picurl;
@property (copy, nonatomic) NSString *createtime;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString<Optional> *key;
@property (strong, nonatomic) NSNumber *duration;
@property (strong, nonatomic) NSNumber *size;
@property (copy, nonatomic) NSString<Optional> *identifier;
@property (strong, nonatomic) NSNumber<Optional> *isUploading;
@property (strong, nonatomic) NSNumber<Optional> *isCancel;

@end

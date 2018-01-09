//
//  WCVideoUploadViewController.h
//  SealTalk
//
//  Created by 项小盆友 on 2018/1/8.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WCVideoFileModel;

typedef void(^failBlock)(WCVideoFileModel *model);
typedef void(^successBlock)(WCVideoFileModel *model);
typedef void(^progressBlock)(WCVideoFileModel *model, CGFloat percent);

@interface WCVideoUploadViewController : UIViewController
+ (instancetype)sharedController;
- (void)uploadFile:(WCVideoFileModel *)model token:(NSString *)token;

@property (strong, nonatomic) NSMutableArray *fileArray;

@property (copy, nonatomic) failBlock failHandler;
@property (copy, nonatomic) successBlock successHandler;
@property (copy, nonatomic) progressBlock progressHandler;
@end

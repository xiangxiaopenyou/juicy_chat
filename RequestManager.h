//
//  RequestManager.h
//  DongDong
//
//  Created by 项小盆友 on 16/6/6.
//  Copyright © 2016年 项小盆友. All rights reserved.
//

#import "AFNetworking.h"

//#define DemoServer @"http://121.43.190.83:7654/API/"
#define DemoServer @"http://47.98.56.166:7654/API/"

@interface RequestManager : AFHTTPSessionManager
+ (instancetype)sharedInstance;

@end

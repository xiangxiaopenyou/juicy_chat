//
//  RCDRegisterViewController.h
//  RCloudMessage
//
//  Created by Liv on 15/3/10.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "WCCommonDefines.h"
#import <UIKit/UIKit.h>
@interface RCDRegisterViewController
    : UIViewController
@property (assign, nonatomic) WCRegisterType registerType;
@property (copy, nonatomic) NSDictionary *informations;

@end

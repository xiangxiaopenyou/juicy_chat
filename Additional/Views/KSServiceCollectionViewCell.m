//
//  KSServiceCollectionViewCell.m
//  SealTalk
//
//  Created by 项小盆友 on 2018/3/19.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "KSServiceCollectionViewCell.h"
#import "RCDCommonDefine.h"

@implementation KSServiceCollectionViewCell
- (void)awakeFromNib {
    [super awakeFromNib];
    self.contactButton.layer.masksToBounds = YES;
    self.contactButton.layer.cornerRadius = 4.f;
    self.contactButton.layer.borderWidth = 0.5;
    self.contactButton.layer.borderColor = HEXCOLOR(0x1A9CFC).CGColor;
    
    self.heightConstraintOfIntroduceLabel.constant = (CGRectGetHeight([UIApplication sharedApplication].keyWindow.bounds) - 211.f) / 2.0 - 164.f;
}

@end

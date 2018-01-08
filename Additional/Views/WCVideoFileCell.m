//
//  WCVideoFileCell.m
//  SealTalk
//
//  Created by 项小盆友 on 2018/1/3.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "WCVideoFileCell.h"

@implementation WCVideoFileCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.progressView.transform = CGAffineTransformMakeScale(1.0f, 4.0f);
    self.progressView.contentMode = UIViewContentModeScaleAspectFill;
    self.progressView.layer.masksToBounds = YES;
    self.progressView.layer.cornerRadius = 8.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

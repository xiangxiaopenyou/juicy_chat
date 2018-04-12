//
//  KSVideoAmountCell.m
//  SealTalk
//
//  Created by 项小盆友 on 2018/3/21.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "KSVideoAmountCell.h"

@implementation KSVideoAmountCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.textLabel.font = [UIFont systemFontOfSize:16];
        self.detailTextLabel.font = [UIFont systemFontOfSize:14];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

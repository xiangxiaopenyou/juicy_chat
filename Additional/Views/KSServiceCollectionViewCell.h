//
//  KSServiceCollectionViewCell.h
//  SealTalk
//
//  Created by 项小盆友 on 2018/3/19.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KSServiceCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *contactButton;
@property (weak, nonatomic) IBOutlet UILabel *introduceLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraintOfIntroduceLabel;

@end

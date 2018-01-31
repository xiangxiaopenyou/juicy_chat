//
//  WCVideoFileMessageCell.m
//  SealTalk
//
//  Created by 项小盆友 on 2018/1/8.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "WCVideoFileMessageCell.h"
#import "WCVideoFileMessage.h"
#import "UIImageView+WebCache.h"

#import <Photos/Photos.h>

@implementation WCVideoFileMessageCell
+ (CGSize)sizeForMessageModel:(RCMessageModel *)model withCollectionViewWidth:(CGFloat)collectionViewWidth referenceExtraHeight:(CGFloat)extraHeight {
    return CGSizeMake(collectionViewWidth, 100 + extraHeight);
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createViews];
    }
    return self;
}
- (void)createViews {
    self.bubbleBackgroundView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.messageContentView addSubview:self.bubbleBackgroundView];
    self.videoImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.videoImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.videoImageView.clipsToBounds = YES;
    [self.messageContentView addSubview:self.videoImageView];
    
    self.iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.iconImageView.image = [UIImage imageNamed:@"videofile_play"];
    [self.messageContentView addSubview:self.iconImageView];
    
    self.bubbleBackgroundView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOrderMessage:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [self.bubbleBackgroundView addGestureRecognizer:tap];
}

- (void)setDataModel:(RCMessageModel *)model {
    [super setDataModel:model];
    [self setAutoLayout];
}
- (void)setAutoLayout {
    WCVideoFileMessage *message = (WCVideoFileMessage *)self.model.content;
    [self.videoImageView sd_setImageWithURL:[NSURL URLWithString:message.picurl]];
    CGRect messageContentViewRect = self.messageContentView.frame;
    messageContentViewRect.size.width = 110;
    messageContentViewRect.size.height = 120;
    self.bubbleBackgroundView.frame = CGRectMake(0, 0, messageContentViewRect.size.width, messageContentViewRect.size.height - 20);
    if (self.messageDirection == MessageDirection_SEND) {
        CGFloat screenWidth = CGRectGetWidth(UIScreen.mainScreen.bounds);
        messageContentViewRect.origin.x = screenWidth - 166;
        UIImage *image = [RCKitUtility imageNamed:@"chat_to_bg_normal" ofBundle:@"RongCloud.bundle"];
        self.bubbleBackgroundView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.8, image.size.width * 0.2, image.size.height * 0.2, image.size.width * 0.8)];
        self.videoImageView.frame = CGRectMake(6, 5, 90, 90);
        self.iconImageView.frame = CGRectMake(35, 35, 37, 37);
    } else {
        UIImage *image = [RCKitUtility imageNamed:@"chat_from_bg_normal"ofBundle:@"RongCloud.bundle"];;
        self.bubbleBackgroundView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.8, image.size.width * 0.8, image.size.height * 0.2, image.size.width * 0.2)];
        self.videoImageView.frame = CGRectMake(13, 5, 90, 90);
        self.iconImageView.frame = CGRectMake(40, 35, 37, 37);
    }
    self.messageContentView.frame = messageContentViewRect;
    
}

- (void)tapOrderMessage:(UIGestureRecognizer *)recognizer {
    if ([self.delegate respondsToSelector:@selector(didTapMessageCell:)]) {
        [self.delegate didTapMessageCell:self.model];
    }
}

@end

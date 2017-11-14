//
//  XLPopView.m
//  SealTalk
//
//  Created by 项小盆友 on 2017/11/13.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import "XLPopView.h"

#define kScreenWidth CGRectGetWidth(UIScreen.mainScreen.bounds)
#define kScreenHeight CGRectGetHeight(UIScreen.mainScreen.bounds)
#define kWidthOfContentView kScreenWidth * 0.75
#define kHeightOfContentView kWidthOfContentView * 0.6
@interface XLPopView ()
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIButton *leftButton;
@property (strong, nonatomic) UIButton *rightButton;
@end

@implementation XLPopView
- (instancetype)initWithFrame:(CGRect)frame images:(NSArray *)imagesArray title:(NSString *)titleString {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.4 alpha:0.5];
        self.titleLabel.text = titleString;
        [self.leftButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", imagesArray[0]]] forState:UIControlStateNormal];
        [self.rightButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", imagesArray[1]]] forState:UIControlStateNormal];
        [self createContentView];
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTap)];
        [self addGestureRecognizer:tap];
    }
    return self;
}
- (void)createContentView {
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.leftButton];
    [self.contentView addSubview:self.rightButton];
}
- (void)show {
    self.alpha = 1.f;
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    //[self]
    CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    popAnimation.duration = 0.4;
    popAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9f, 0.9f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    popAnimation.keyTimes = @[@0.2f, @0.5f, @0.75f, @1.0f];
    popAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self.contentView.layer addAnimation:popAnimation forKey:nil];
}
- (void)dismiss {
    [UIView animateWithDuration:0.4 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    CAKeyframeAnimation *hideAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    hideAnimation.duration = 0.4;
    hideAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.0f)],
                             [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0f, 1.0f, 1.0f)],
                             [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.00f, 0.00f, 0.00f)]];
    hideAnimation.keyTimes = @[@0.2f, @0.5f, @0.75f];
    hideAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                      [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                      [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self.contentView.layer addAnimation:hideAnimation forKey:nil];
}


#pragma mark - Action
- (void)leftAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickButton:)]) {
        [self dismiss];
        [self.delegate didClickButton:0];
    }
}
- (void)rightAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickButton:)]) {
        [self dismiss];
        [self.delegate didClickButton:1];
    }
}
- (void)backgroundTap {
    [self dismiss];
}
- (void)contentViewTap {
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark - Getters & Setters
- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectMake((kScreenWidth - kWidthOfContentView) * 0.5, kScreenHeight * 0.5 - kHeightOfContentView * 0.6, kWidthOfContentView, kHeightOfContentView)];
        _contentView.layer.masksToBounds = YES;
        _contentView.layer.cornerRadius = 4.0;
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.userInteractionEnabled = YES;
        [_contentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentViewTap)]];
    }
    return _contentView;
}
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kWidthOfContentView * 0.5 - 100, 18, 200, 25)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:18];
        _titleLabel.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1];
    }
    return _titleLabel;
}
- (UIButton *)leftButton {
    if (!_leftButton) {
        _leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftButton.frame = CGRectMake(kWidthOfContentView * 0.5 - 79, kHeightOfContentView * 0.5 - 18, 54, 54);
        [_leftButton addTarget:self action:@selector(leftAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftButton;
}
- (UIButton *)rightButton {
    if (!_rightButton) {
        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightButton.frame = CGRectMake(kWidthOfContentView * 0.5 + 25, kHeightOfContentView * 0.5 - 18, 54, 54);
        [_rightButton addTarget:self action:@selector(rightAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightButton;
}
- (void)setImages:(NSArray *)images {
    if (images.count > 0) {
        [self.leftButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", images[0]]] forState:UIControlStateNormal];
        [self.rightButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", images[1]]] forState:UIControlStateNormal];
    }
}
- (void)setViewTitle:(NSString *)viewTitle {
    if (viewTitle) {
        self.titleLabel.text = viewTitle;
    }
}

@end

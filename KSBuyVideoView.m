//
//  KSBuyVideoView.m
//  SealTalk
//
//  Created by 项小盆友 on 2018/3/14.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "KSBuyVideoView.h"
#import "UIColor+RCColor.h"
#import "Masonry.h"

@interface KSBuyVideoView ()
@property (nonatomic, strong) UIView *viewOfContent;
@property (nonatomic, strong) UITextField *amountTextField;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UILabel *balanceLabel;
@property (nonatomic, strong) UIButton *payButton;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIButton *closeButton;
@end

@implementation KSBuyVideoView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.5];
        [self.viewOfContent addSubview:self.closeButton];
        [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.top.equalTo(self.viewOfContent);
            make.size.mas_offset(CGSizeMake(35, 35));
        }];
        
        [self.viewOfContent addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.viewOfContent.mas_top).with.mas_offset(20);
            make.centerX.equalTo(self.viewOfContent);
        }];
        
        UILabel *label1 = [[UILabel alloc] init];
        label1.text = @"购买数量:";
        label1.textColor = [UIColor colorWithHexString:@"333333" alpha:1];
        label1.font = [UIFont systemFontOfSize:14];
        [self.viewOfContent addSubview:label1];
        [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.viewOfContent.mas_leading).with.mas_offset(20);
            make.top.equalTo(self.viewOfContent.mas_top).with.mas_offset(75);
        }];
        
        UIView *viewOfText = [[UIView alloc] init];
        viewOfText.backgroundColor = [UIColor colorWithHexString:@"f1f1f1" alpha:1];
        viewOfText.layer.masksToBounds = YES;
        viewOfText.layer.cornerRadius = 4;
        [self.viewOfContent addSubview:viewOfText];
        [viewOfText mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.viewOfContent.mas_top).with.mas_offset(61);
            make.leading.equalTo(label1.mas_trailing).with.mas_offset(5);
            make.trailing.equalTo(self.viewOfContent.mas_trailing).with.mas_offset(- 20);
            make.height.mas_offset(43);
        }];
        
        [viewOfText addSubview:self.amountTextField];
        [self.amountTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_offset(UIEdgeInsetsMake(4, 5, 4, 5));
        }];
        
        UILabel *label2 = [[UILabel alloc] init];
        label2.text = @"支付快豆:";
        label2.font = [UIFont systemFontOfSize:14];
        label2.textColor = [UIColor colorWithHexString:@"333333" alpha:1];
        [self.viewOfContent addSubview:label2];
        [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.viewOfContent.mas_leading).with.mas_offset(20);
            make.top.equalTo(label1.mas_bottom).with.mas_offset(40);
        }];
        
        [self.viewOfContent addSubview:self.priceLabel];
        [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(label2.mas_trailing).with.mas_offset(5);
            make.top.equalTo(label1.mas_bottom).with.mas_offset(40);
        }];
        
        [self.viewOfContent addSubview:self.payButton];
        [self.payButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.viewOfContent);
            make.bottom.equalTo(self.viewOfContent.mas_bottom).with.mas_offset(- 20);
            make.size.mas_offset(CGSizeMake(238, 39));
        }];
        
    }
    return self;
}
- (void)show {
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [self addSubview:self.viewOfContent];
    [self.amountTextField becomeFirstResponder];
    CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    popAnimation.duration = 0.4;
    popAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.05f, 1.05f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.95f, 0.95f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    popAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self.viewOfContent.layer addAnimation:popAnimation forKey:nil];
    
}
- (void)closeAction {
    [self removeFromSuperview];
}
- (void)amountChanged:(UITextField *)textField {
    self.payButton.enabled = textField.text.integerValue > 0 ? YES : NO;
    CGFloat priceFloat = [[NSUserDefaults standardUserDefaults] floatForKey:@"VideoPrice"];
    NSString *priceString = textField.text.integerValue > 0 ? [NSString stringWithFormat:@"%.2f", priceFloat * textField.text.integerValue] : nil;
    self.priceLabel.text = priceString;
    NSString *payString = textField.text.integerValue > 0 ? [NSString stringWithFormat:@"确认支付%@", priceString] : @"确认支付";
    [self.payButton setTitle:payString forState:UIControlStateNormal];
    
}
- (void)payAction {
    if (self.payBlock) {
        self.payBlock(self.priceLabel.text, self.amountTextField.text.integerValue);
        [self closeAction];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
#pragma mark - Getters
- (UIView *)viewOfContent {
    if (!_viewOfContent) {
        _viewOfContent = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(UIScreen.mainScreen.bounds) / 2.0 - 134, 120, 268, 240)];
        _viewOfContent.backgroundColor = [UIColor whiteColor];
        _viewOfContent.clipsToBounds = YES;
        _viewOfContent.layer.masksToBounds = YES;
        _viewOfContent.layer.cornerRadius = 4.0;
    }
    return _viewOfContent;
}
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:16];
        _titleLabel.textColor = [UIColor colorWithHexString:@"333333" alpha:1];
        _titleLabel.text = @"购买视频空间";
    }
    return _titleLabel;
}
- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"btn_exit"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}
-(UILabel *)balanceLabel {
    if (!_balanceLabel) {
        _balanceLabel = [[UILabel alloc] init];
        _balanceLabel.font = [UIFont systemFontOfSize:14];
        _balanceLabel.textColor = [UIColor colorWithHexString:@"999999" alpha:1];
    }
    return _balanceLabel;
}
- (UILabel *)priceLabel {
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] init];
        _priceLabel.font = [UIFont systemFontOfSize:14];
        _priceLabel.textColor = [UIColor colorWithHexString:@"ff8400" alpha:1];
    }
    return _priceLabel;
}
- (UITextField *)amountTextField {
    if (!_amountTextField) {
        _amountTextField = [[UITextField alloc] init];
        _amountTextField.layer.masksToBounds = YES;
        _amountTextField.layer.cornerRadius = 4;
        _amountTextField.placeholder = @"输入购买数量";
        _amountTextField.textAlignment = NSTextAlignmentRight;
        _amountTextField.font = [UIFont systemFontOfSize:14];
        _amountTextField.textColor = [UIColor colorWithHexString:@"333333" alpha:1];
        _amountTextField.keyboardType = UIKeyboardTypeNumberPad;
        [_amountTextField addTarget:self action:@selector(amountChanged:) forControlEvents:UIControlEventEditingChanged];
    }
    return _amountTextField;
}
- (UIButton *)payButton {
    if (!_payButton) {
        _payButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _payButton.layer.masksToBounds = YES;
        _payButton.layer.cornerRadius = 4.f;
        [_payButton setBackgroundImage:[UIColor imageWithColor:[UIColor colorWithHexString:@"0099ff" alpha:1]] forState:UIControlStateNormal];
        //[_payButton setBackgroundImage:[UIColor imageWithColor:[UIColor grayColor]] forState:UIControlStateNormal];
        [_payButton setTitle:@"确认支付" forState:UIControlStateNormal];
        _payButton.titleLabel.font = [UIFont systemFontOfSize:16];
        _payButton.enabled = NO;
        [_payButton addTarget:self action:@selector(payAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _payButton;
}
@end

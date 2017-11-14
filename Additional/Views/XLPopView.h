//
//  XLPopView.h
//  SealTalk
//
//  Created by 项小盆友 on 2017/11/13.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol XLPopViewDelegate<NSObject>
- (void)didClickButton:(NSInteger)index;
@end

@interface XLPopView : UIView
@property (copy, nonatomic) NSString *viewTitle;
@property (copy, nonatomic) NSArray *images;
@property (weak, nonatomic) id<XLPopViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame images:(NSArray *)imagesArray title:(NSString *)titleString;
- (void)show;
- (void)dismiss;
@end

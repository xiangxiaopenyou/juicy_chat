//
//  KSRechargeViewController.m
//  SealTalk
//
//  Created by 项小盆友 on 2018/3/19.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "KSRechargeViewController.h"
#import "KSServiceCollectionViewCell.h"
#import "UIColor+RCColor.h"

#define kKSScreenWidth CGRectGetWidth([UIApplication sharedApplication].keyWindow.bounds)
#define kKSServeceCollectionCellWidth (CGRectGetWidth([UIApplication sharedApplication].keyWindow.bounds) - 45.f) / 2.0
#define kKSServeceCollectionCellHeight (CGRectGetHeight([UIApplication sharedApplication].keyWindow.bounds) - 211.f) / 2.0

@interface KSRechargeViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewOfVipRecharge;
@property (strong, nonatomic) UIButton *refreshServiceButton;
@end

@implementation KSRechargeViewController
#pragma mark - Controller life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.collectionViewOfVipRecharge registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"CollectionFooterView"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Action
//换一批充值客服
- (void)refreshServiceAction {
    
}

#pragma mark - Collection view data source
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 4;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    KSServiceCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"KSServiceCollectionView" forIndexPath:indexPath];
    return cell;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"CollectionFooterView" forIndexPath:indexPath];
        [footerView addSubview:self.refreshServiceButton];
        return footerView;
    } else {
        return nil;
    }
}


#pragma mark - Collection view delegate flow layout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(kKSServeceCollectionCellWidth, kKSServeceCollectionCellHeight);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(15, 15, 15, 15);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 15.f;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 15.f;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return (CGSize){kKSScreenWidth, 57.f};
}

#pragma mark - Collection view delegate


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (UIButton *)refreshServiceButton {
    if (!_refreshServiceButton) {
        _refreshServiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _refreshServiceButton.frame = CGRectMake(15, 10, kKSScreenWidth - 30, 36);
        [_refreshServiceButton setTitle:@"换一批" forState:UIControlStateNormal];
        [_refreshServiceButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_refreshServiceButton setBackgroundImage:[UIColor imageWithColor:[UIColor colorWithHexString:@"1A9CFC" alpha:1]] forState:UIControlStateNormal];
        _refreshServiceButton.layer.masksToBounds = YES;
        _refreshServiceButton.layer.cornerRadius = 4.f;
        [_refreshServiceButton addTarget:self action:@selector(refreshServiceAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _refreshServiceButton;
}

@end

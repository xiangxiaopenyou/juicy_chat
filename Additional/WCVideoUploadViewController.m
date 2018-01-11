//
//  WCVideoUploadViewController.m
//  SealTalk
//
//  Created by 项小盆友 on 2018/1/8.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "WCVideoUploadViewController.h"
#import "WCVideoFileModel.h"
#import "QiniuSDK.h"

#import <Photos/Photos.h>

static NSString *const kWCFileBaseURL = @"http://img.juicychat.cn/";

@interface WCVideoUploadViewController ()
@property (strong, nonatomic) NSMutableArray *cancelStatusArray;
@end

@implementation WCVideoUploadViewController
+ (instancetype)sharedController {
    static dispatch_once_t onceToken;
    static WCVideoUploadViewController *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)uploadFile:(WCVideoFileModel *)model token:(NSString *)token {
    [self.fileArray insertObject:model atIndex:0];
    QNUploadManager *manager = [[QNUploadManager alloc] init];
    QNUploadOption *option = [[QNUploadOption alloc] initWithMime:nil progressHandler:^(NSString *key, float percent) {
        if (self.progressHandler) {
            self.progressHandler(model, percent);
        }
    } params:nil checkCrc:YES cancellationSignal:^BOOL{
        __block BOOL isCancel = NO;
        NSArray *tempArray = [self.fileArray copy];
        [tempArray enumerateObjectsUsingBlock:^(WCVideoFileModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.identifier isEqualToString:model.identifier]) {
                isCancel = obj.isCancel.boolValue;
                if (isCancel) {
                    [self.fileArray removeObject:obj];
                }
            }
        }];
        return isCancel;
    }];
    [manager putFile:model.url key:model.key token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        if (info.ok) {
            [self.fileArray removeObject:model];
            NSString *urlString = [[NSString stringWithFormat:@"%@%@", kWCFileBaseURL, key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            model.url = urlString;
            //上传成功
            if (self.successHandler) {
                self.successHandler(model);
            }
            //删除上传数据model
        } else {
            //上传失败
            if (self.failHandler) {
                self.failHandler(model);
            }
        }
    } option:option];
}
- (void)cancelStatusRefresh:(WCVideoFileModel *)model {
    [self.fileArray enumerateObjectsUsingBlock:^(WCVideoFileModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.identifier isEqualToString:model.identifier]) {
            obj.isCancel = model.isCancel;
        }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (NSMutableArray *)fileArray {
    if (!_fileArray) {
        _fileArray = [[NSMutableArray alloc] init];
    }
    return _fileArray;
}
- (NSMutableArray *)cancelStatusArray {
    if (!_cancelStatusArray) {
        _cancelStatusArray = [[NSMutableArray alloc] init];
    }
    return _cancelStatusArray;
}

@end

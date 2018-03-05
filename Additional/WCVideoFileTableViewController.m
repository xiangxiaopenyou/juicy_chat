//
//  WCVideoFileTableViewController.m
//  SealTalk
//
//  Created by 项小盆友 on 2018/1/3.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "WCVideoFileTableViewController.h"
#import "WCVideoUploadViewController.h"

#import "WCVideoFileCell.h"

#import "WCVideoFileListRequest.h"
#import "WCUploadVideoRequest.h"
#import "WCVideoLimitRequest.h"
#import "WCVideoLimitRequest.h"
#import "WCDeleteVideoFileRequest.h"
#import "WCVideoFileModel.h"
#import "MBProgressHUD+Add.h"
#import "AFHttpTool.h"
#import "UIImageView+WebCache.h"
#import <RongIMKit/RongIMKit.h>
#import <Photos/Photos.h>
static NSString *const kWCFileBaseURL = @"http://img.juicychat.cn/";

@interface WCVideoFileTableViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *emptyLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightItem;

@property (strong, nonatomic) NSMutableArray *fileArray;
@property (assign, nonatomic) NSInteger maxCount;
@property (assign, nonatomic) NSInteger maxSize;

@end

@implementation WCVideoFileTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    _rightItem.enabled = NO;
    [WCVideoUploadViewController sharedController].failHandler = ^(WCVideoFileModel *model) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@文件上传失败", model.name] toView:self.view];
        });
    };
    [WCVideoUploadViewController sharedController].successHandler = ^(WCVideoFileModel *model) {
        [self uploadRequest:model];
    };
    [WCVideoUploadViewController sharedController].progressHandler = ^(WCVideoFileModel *model, CGFloat percent) {
        [_fileArray enumerateObjectsUsingBlock:^(WCVideoFileModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.identifier isEqualToString:model.identifier]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    WCVideoFileCell *tempCell = (WCVideoFileCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
                    [tempCell.progressView setProgress:percent animated:YES];
                });
            }
        }];
    };
    [self limitRequest];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)uploadAction:(id)sender {
    if (self.fileArray.count >= self.maxCount) {
        [MBProgressHUD showError:[NSString stringWithFormat:@"上传视频最多不能超过%@个", @(self.maxCount)] toView:self.view];
        return;
    }
    if ([WCVideoUploadViewController sharedController].fileArray.count >= 3) {
        [MBProgressHUD showError:@"最多同时上传3个视频" toView:self.view];
        return;
    }
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerController.mediaTypes = @[(NSString *)kUTTypeMovie ];
    pickerController.videoMaximumDuration = 100;
    pickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;
    pickerController.delegate = self;
    [self presentViewController:pickerController animated:YES completion:nil];
}
- (IBAction)backAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Requests
- (void)listRequest {
    self.fileArray = [[WCVideoUploadViewController sharedController].fileArray mutableCopy];
    [[WCVideoFileListRequest new] request:^BOOL(id request) {
        return YES;
    } result:^(id object, NSString *msg) {
        if (object) {
            NSArray *resultArray = [[WCVideoFileModel setupWithArray:(NSArray *)object] copy];
            [_fileArray addObjectsFromArray:resultArray];
            dispatch_async(dispatch_get_main_queue(), ^{
                _rightItem.enabled = YES;
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self.tableView reloadData];
                if (_fileArray.count > 0) {
                    self.emptyLabel.hidden = YES;
                } else {
                    self.emptyLabel.hidden = NO;
                    self.emptyLabel.text = @"暂无视频文件";
                }
            });
        } else {
            [MBProgressHUD showError:msg toView:self.view];
            self.emptyLabel.hidden = NO;
            self.emptyLabel.text = @"网络错误";
        }
    }];
}
- (void)uploadRequest:(WCVideoFileModel *)model {
    [[WCUploadVideoRequest new] request:^BOOL(WCUploadVideoRequest *request) {
        request.url = model.url;
        request.name = model.name;
        request.picurl = model.picurl;
        request.duration =@([self videoDurationWithPath:model.url]);
        return YES;
    } result:^(id object, NSString *msg) {
        if (object) {
            WCVideoFileModel *resultModel = [[WCVideoFileModel alloc] initWithDictionary:(NSDictionary *)object error:nil];
            NSArray *tempArray = [self.fileArray copy];
            [tempArray enumerateObjectsUsingBlock:^(WCVideoFileModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.identifier isEqualToString:model.identifier]) {
                    [self.fileArray replaceObjectAtIndex:idx withObject:resultModel];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                }
            }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@文件上传失败", model.name] toView:self.view];
                [self listRequest];
            });
        }
    }];
}
- (void)limitRequest {
    [[WCVideoLimitRequest new] request:^BOOL(id request) {
        return YES;
    } result:^(id object, NSString *msg) {
        if (object) {
            self.maxCount = [object[@"maxCount"] integerValue];
            self.maxSize = [object[@"maxSize"] integerValue];
            [self listRequest];
        } else {
            [MBProgressHUD showError:msg toView:self.view];
            self.emptyLabel.hidden = NO;
            self.emptyLabel.text = @"网络错误";
        }
    }];
}

#pragma mark - Private methods
- (NSString *)videoDurationWithTime:(NSInteger)time {
    //format of hour
    NSString *str_hour = [NSString stringWithFormat:@"%02ld",time/3600];
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(time % 3600) / 60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02ld",time % 60];
    //format of time
    NSString *format_time = [NSString stringWithFormat:@"%@:%@", str_minute, str_second];
    if (str_hour.integerValue > 0) {
        format_time = [NSString stringWithFormat:@"%@:%@", str_hour, format_time];
    }
    
    return format_time;
}
- (NSInteger)videoDurationWithPath:(NSString *)path {
    AVURLAsset * asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:path]];
    CMTime  time = [asset duration];
    NSInteger seconds = time.value / time.timescale;
    return seconds;
}

/**
 获取视频文件
 @param asset 相册选择的视频asset
 */
- (void)fetchVideoPathFromPhAsset:(PHAsset *)asset {
    NSArray *assetResources = [PHAssetResource assetResourcesForAsset:asset];
    PHAssetResource *resource;
    for (PHAssetResource *assetRes in assetResources) {
        if (assetRes.type == PHAssetResourceTypePairedVideo || assetRes.type == PHAssetResourceTypeVideo) {
            resource = assetRes;
        }
    }
    
    //判断视频格式
    NSString *typeString = [resource.originalFilename substringFromIndex:resource.originalFilename.length - 3];
    if (!([typeString isEqualToString:@"mp4"] ||[typeString isEqualToString:@"MP4"])) {
        [MBProgressHUD showError:@"只能上传mp4格式的视频" toView:self.view];
        return;
    }
    NSString *fileName = resource.originalFilename;
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        NSString *PATH_MOVIE_FILE = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
        [[NSFileManager defaultManager] removeItemAtPath:PATH_MOVIE_FILE error:nil];
        NSData *fileData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:PATH_MOVIE_FILE]];
        if (fileData.length / 1024 / 1024 > self.maxSize) {
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@", @(self.maxSize)] toView:self.view];
            return;
        }
        [[PHAssetResourceManager defaultManager] writeDataForAssetResource:resource
                                                                    toFile:[NSURL fileURLWithPath:PATH_MOVIE_FILE]
                                                                   options:nil
                                                         completionHandler:^(NSError * _Nullable error) {
                                                             if (error) {
                                                                 //失败
                                                                 [MBProgressHUD showError:[NSString stringWithFormat:@"%@文件上传失败", fileName] toView:self.view];
                                                             } else {
                                                                 [AFHttpTool getUploadImageTokensuccess:^(id response) {
                                                                     if ([response[@"code"] integerValue] == 200) {
                                                                         [self uploadFile:fileName url:PATH_MOVIE_FILE token:response[@"data"][@"qiniutoken"]];
                                                                     } else {
                                                                         //获取上传token失败
                                                                         [MBProgressHUD showError:[NSString stringWithFormat:@"%@文件上传失败", fileName] toView:self.view];
                                                                     }
                                                                 } failure:^(NSError *err) {
                                                                     //获取上传token失败
                                                                     [MBProgressHUD showError:[NSString stringWithFormat:@"%@文件上传失败", fileName] toView:self.view];
                                                                 }];
                                                             }
                                                         }];
    } else {//类型不正确
        [MBProgressHUD showError:@"视频格式不正确" toView:self.view];
    }
}
- (void)uploadFile:(NSString *)fileName url:(NSString *)fileUrl token:(NSString *)token {
    WCVideoFileModel *tempModel = [[WCVideoFileModel alloc] init];
    tempModel.name = fileName;
    //获取系统当前的时间戳
    NSDate *dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now = [dat timeIntervalSince1970] * 1000;
    NSString *timeString = [NSString stringWithFormat:@"%f", now];
    timeString = [timeString stringByReplacingOccurrencesOfString:@"." withString:@""];
    NSString *key = [NSString stringWithFormat:@"i_%@", timeString];
    tempModel.key = key;
    tempModel.identifier = timeString;
    tempModel.url = fileUrl;
    tempModel.isUploading = @YES;
    [_fileArray insertObject:tempModel atIndex:0];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    [[WCVideoUploadViewController sharedController] uploadFile:tempModel token:token];
}

#pragma mark - Image picker controller delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (info[UIImagePickerControllerReferenceURL]) {
        NSURL *videoUrl = info[UIImagePickerControllerReferenceURL];
        PHFetchResult *fetchResult = [PHAsset fetchAssetsWithALAssetURLs:@[videoUrl] options:nil];
        PHAsset *asset = fetchResult.firstObject;
        [self fetchVideoPathFromPhAsset:asset];
    }
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _fileArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WCVideoFileCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VideoFileCell" forIndexPath:indexPath];
    WCVideoFileModel *model = _fileArray[indexPath.row];
    cell.videoNameLabel.text = model.name;
    [cell.videoImageView sd_setImageWithURL:[NSURL URLWithString:model.picurl]];
    cell.videoDurationLabel.text = [self videoDurationWithTime:model.duration.integerValue];
    cell.progressView.hidden = !model.isUploading.boolValue;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WCVideoFileModel *model = _fileArray[indexPath.row];
    if (!model.isUploading.boolValue) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"确定要发送%@吗？", model.name] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"发送" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (self.sendBlock) {
                self.sendBlock(model);
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        [MBProgressHUD showError:@"视频上传完成才能发送" toView:self.view];
    }
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        WCVideoFileModel *model = _fileArray[indexPath.row];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"确定要删除%@吗？", model.name] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            if (model.isUploading.boolValue) {
                model.isCancel = @YES;
                [[WCVideoUploadViewController sharedController] cancelStatusRefresh:model];
                [self.fileArray removeObject:model];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            } else {
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [[WCDeleteVideoFileRequest new] request:^BOOL(WCDeleteVideoFileRequest *request) {
                    request.videoId = model.id;
                    return YES;
                } result:^(id object, NSString *msg) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    if (object) {
                        [self.fileArray removeObject:model];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                        });
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [MBProgressHUD showError:msg toView:self.view];
                        });
                    }
                }];
            }
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

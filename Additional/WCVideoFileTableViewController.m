//
//  WCVideoFileTableViewController.m
//  SealTalk
//
//  Created by 项小盆友 on 2018/1/3.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "WCVideoFileTableViewController.h"

#import "WCVideoFileCell.h"

#import "WCVideoFileListRequest.h"
#import "WCUploadVideoRequest.h"
#import "WCVideoLimitRequest.h"
#import "WCUploadFileRequestManager.h"
#import "WCVideoFileModel.h"
#import "MBProgressHUD+Add.h"
#import "AFHttpTool.h"
#import <RongIMKit/RongIMKit.h>
#import <Photos/Photos.h>
static NSString *const kWCFileBaseURL = @"http://img.juicychat.cn/";

@interface WCVideoFileTableViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *emptyLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightItem;

@property (strong, nonatomic) NSMutableArray *fileArray;

@end

@implementation WCVideoFileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    _rightItem.enabled = NO;
    [self listRequest];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)uploadAction:(id)sender {
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerController.mediaTypes = @[(NSString *)kUTTypeMovie, (NSString *)kUTTypeVideo, (NSString *)kUTTypeMPEG4];
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
    [[WCVideoFileListRequest new] request:^BOOL(id request) {
        return YES;
    } result:^(id object, NSString *msg) {
        if (object) {
            _fileArray = [[WCVideoFileModel setupWithArray:(NSArray *)object] mutableCopy];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                for (WCVideoFileModel *tempModel in _fileArray) {
                    tempModel.firstImage = [self firstFrameWithVideoURL:[NSURL URLWithString:tempModel.url] size:CGSizeMake(70, 70)];
                }
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
        request.duration = model.duration;
        return YES;
    } result:^(id object, NSString *msg) {
        if (object) {
            [self listRequest];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showError:msg toView:self.view];
            });
        }
    }];
}

#pragma mark - Private methods
- (UIImage *)firstFrameWithVideoURL:(NSURL *)url size:(CGSize)size {
    NSDictionary *opts = @{AVURLAssetPreferPreciseDurationAndTimingKey : @NO};
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:url options:opts];
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    generator.appliesPreferredTrackTransform = YES;
    generator.maximumSize = size;
    NSError *error = nil;
    CGImageRef img = [generator copyCGImageAtTime:CMTimeMake(0, 10) actualTime:NULL error:&error];
    if (img) {
        return [UIImage imageWithCGImage:img];
    }
    return nil;
}
- (NSString *)videoDurationWithTime:(NSInteger)time {
    //format of hour
    NSString *str_hour = [NSString stringWithFormat:@"%02ld",time/3600];
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(time%3600)/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02ld",time%60];
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

- (void)fetchVideoPathFromPhAsset:(PHAsset *)asset {
    NSArray *assetResources = [PHAssetResource assetResourcesForAsset:asset];
    PHAssetResource *resource;
    for (PHAssetResource *assetRes in assetResources) {
        if (assetRes.type == PHAssetResourceTypePairedVideo || assetRes.type == PHAssetResourceTypeVideo) {
            resource = assetRes;
        }
    }
    NSString *fileName = resource.originalFilename;
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        NSString *PATH_MOVIE_FILE = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
        [[NSFileManager defaultManager] removeItemAtPath:PATH_MOVIE_FILE error:nil];
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
                                                                         
                                                                         //[WCUploadFileRequestManager uploadQNVideoFile:fileName fileUrl:PATH_MOVIE_FILE token:response[@"data"][@"qiniutoken"]];
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
    tempModel.url = fileUrl;
    tempModel.duration = @([self videoDurationWithPath:fileUrl]);
    tempModel.isUploading = @YES;
    //获取系统当前的时间戳
    NSDate *dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now = [dat timeIntervalSince1970] * 1000;
    NSString *timeString = [NSString stringWithFormat:@"%f", now];
    tempModel.identifier = timeString;
    [_fileArray insertObject:tempModel atIndex:0];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    QNUploadManager *manager = [[QNUploadManager alloc] init];
    QNUploadOption *option = [[QNUploadOption alloc] initWithMime:nil progressHandler:^(NSString *key, float percent) {
        [_fileArray enumerateObjectsUsingBlock:^(WCVideoFileModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.identifier isEqualToString:tempModel.identifier]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    WCVideoFileCell *tempCell = (WCVideoFileCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
                    [tempCell.progressView setProgress:percent animated:YES];
                });
            }
        }];
    } params:nil checkCrc:YES cancellationSignal:nil];
    [manager putFile:fileUrl key:fileName token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        if (info.ok) {
            WCVideoFileModel *model = [[WCVideoFileModel alloc] init];
            model.name = fileName;
            NSString *urlString = [[NSString stringWithFormat:@"%@%@", kWCFileBaseURL, key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            model.url = urlString;
            model.duration = @([self videoDurationWithPath:fileUrl]);
            [self uploadRequest:model];
        } else {
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@文件上传失败", fileName] toView:self.view];
        }
    } option:option];
}

#pragma mark - Image picker controller delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (info[UIImagePickerControllerReferenceURL]) {
        NSURL *videoUrl = info[UIImagePickerControllerReferenceURL];
        PHFetchResult *fetchResult = [PHAsset fetchAssetsWithALAssetURLs:@[videoUrl] options:nil];
        PHAsset *asset = fetchResult.firstObject;
        NSLog(@"xainglinping");
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
    cell.videoImageView.image = model.firstImage;
    cell.videoDurationLabel.text = [self videoDurationWithTime:model.duration.integerValue];
    cell.progressView.hidden = !model.isUploading.boolValue;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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

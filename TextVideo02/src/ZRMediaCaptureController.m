//
//  ZRVideoCaptureViewController.m
//  TakeVideos
//
//  Created by VictorZhang on 14/08/2017.
//  Copyright © 2017 Victor Studio. All rights reserved.
//

#import "ZRMediaCaptureController.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "ZRMediaCaptureView.h"
#import "ZRVideoPlayerController.h"

@interface ZRMediaCaptureController()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, ZRMediaCaptureDelegate, ZRVideoPlayerDelegate>

@property (nonatomic, assign) ZRMediaCaptureType captureType;
@property (nonatomic, copy) ZRMediaCaptureCompletion captureCompletion;
@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic, weak) ZRMediaCaptureView *mediaCaptureView;

@end

@implementation ZRMediaCaptureController

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (instancetype)initWithViewController:(UIViewController *)viewController {
    self = [super init];
    if (self) {
        _viewController = viewController;
        _captureType = ZRMediaCaptureTypeDefault;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - ZRVideoPlayerDelegate
- (void)videoPlayerWithRetakingVideo {
    [self.mediaCaptureView showCameraSwitch];
}

- (void)videoPlayerWithChoseVideo:(NSURL *)url videoInterval:(NSTimeInterval)videoInterval {
    
    if (self.captureCompletion) {
        self.captureCompletion(0, nil, url, videoInterval);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ZRMediaCaptureDelegate
- (void)cameraDeviceAlternativelyRearOrFront {
    if (self.cameraDevice == UIImagePickerControllerCameraDeviceFront) {
        self.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    } else {
        self.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    }
}

- (void)startCapture {
    [self.mediaCaptureView showDismissButton:NO];
    [self startVideoCapture];
}

- (void)stopCapture {
    [self.mediaCaptureView showDismissButton:YES];
    [self stopVideoCapture];
}

- (void)closeCaptureView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

+ (void)videoCompressWithSourceURL:(NSURL*)sourceURL completion:(void(^)(int statusCode, NSString *outputVideoURL))completion {
    
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:sourceURL options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    NSString *resultQuality = AVAssetExportPreset960x540;
    
    if ([compatiblePresets containsObject:resultQuality]) {
        int random = arc4random() % 1000000;
        NSString* resultPath = [NSHomeDirectory() stringByAppendingFormat:@"/tmp/%d.mp4", random];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:resultPath]) {
            [fileManager removeItemAtPath:resultPath error:nil];
        }
        
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:resultQuality];
        exportSession.outputURL = [NSURL fileURLWithPath:resultPath];
        exportSession.outputFileType = AVFileTypeQuickTimeMovie;
        exportSession.shouldOptimizeForNetworkUse = YES;
        [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
         {
             switch (exportSession.status) {
                 case AVAssetExportSessionStatusUnknown:
                     NSLog(@"AVAssetExportSessionStatusUnknown");
                     break;
                 case AVAssetExportSessionStatusWaiting:
                     NSLog(@"AVAssetExportSessionStatusWaiting");
                     break;
                 case AVAssetExportSessionStatusExporting:
                     NSLog(@"AVAssetExportSessionStatusExporting");
                     break;
                 case AVAssetExportSessionStatusCompleted:
                     NSLog(@"AVAssetExportSessionStatusCompleted");
                     if(completion)
                         completion(0, resultPath);
                     break;
                 case AVAssetExportSessionStatusFailed:
                     NSLog(@"AVAssetExportSessionStatusFailed");
                     if(completion)
                         completion(1, nil);
                     break;
                 case AVAssetExportSessionStatusCancelled:
                     NSLog(@"AVAssetExportSessionStatusCancelled");
                     if(completion)
                         completion(1, nil);
                     break;
             }
         }];
    }
}

- (void)dealloc
{
    NSLog(@"ZRMediaCaptureController has been deallocated!");
}

@end

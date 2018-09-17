//
//  TestPreviewerVideoViewController.m
//  TakeVideos
//
//  Created by Sangxiedong on 2018/9/10.
//  Copyright © 2018年 Victor Studio. All rights reserved.
//

#import "TestPreviewerVideoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ZRMediaCaptureController.h"
#import "ZRVideoPlayerController.h"
#import "ZRAssetExportSession.h"
#import "ZRCircleProgress.h"
#import "ZRWaterPrintComposition.h"

@interface TestPreviewerVideoViewController ()

@property (nonatomic, strong) UIButton *button;

@end

@implementation TestPreviewerVideoViewController

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self createUI];
    
    [self calculateFizeSize];
    
}

- (void)createUI {
    
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    self.button.frame = CGRectMake(0, 0, 150, 50);
    self.button.center = self.view.center;
    [self.button setTitle:@"播放视频" forState:UIControlStateNormal];
    [self.button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button];
}

- (void)calculateFizeSize {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError * error;
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    int random = arc4random() % 10000001;
    NSString *filename = [NSString stringWithFormat:@"%@/%d.mp4", path, random];
    
    BOOL success = [fileManager copyItemAtURL:self.playURL toURL:[NSURL fileURLWithPath:filename isDirectory:NO] error:&error];
    if (!success) {
        success = [fileManager copyItemAtPath:self.playURL.absoluteString toPath:filename error:&error];
    }
    NSDictionary *fileAttr = [fileManager attributesOfItemAtPath:filename error:&error];
    long fileSize = [[fileAttr objectForKey:NSFileSize] longValue];
    NSString *bytes = [NSByteCountFormatter stringFromByteCount:fileSize countStyle:NSByteCountFormatterCountStyleFile];
    float fileMB = fileSize / 1024.0 / 1024.0;
    NSLog(@"压缩前视频文件大小 fileMB = %lf   bytes=%@", fileMB, bytes);
}


- (void)buttonAction {
    [self previewVideoByURL:self.playURL];
}

- (void)previewVideoByURL:(NSURL *)url {
    ZRVideoPlayerController *moviePlayer = [[ZRVideoPlayerController alloc] initWithURL:url];
    moviePlayer.playVideOnly = YES;
    [self presentViewController:moviePlayer animated:NO completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

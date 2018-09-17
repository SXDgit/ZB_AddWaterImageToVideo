//
//  ViewController.m
//  TextVideo02
//
//  Created by Sangxiedong on 2018/9/10.
//  Copyright © 2018年 ZB. All rights reserved.
//

#import "ViewController.h"
#import "ZRVideoCaptureViewController.h"
#import "TestPreviewerVideoViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 150, 50);
    button.center = self.view.center;
    [button setTitle:@"进入相机" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
}

- (void)previewVideo:(NSURL *)url interval:(NSTimeInterval)interval useFirstCompression:(BOOL)useFirstCompression {
    dispatch_async(dispatch_get_main_queue(), ^{
        TestPreviewerVideoViewController *preview = [[TestPreviewerVideoViewController alloc]init];
        preview.useFirstCompression = useFirstCompression;
        preview.playURL = url;
        preview.videoInterval = interval;
        [self.navigationController pushViewController:preview animated:YES];
    });
    
}

- (void)buttonAction {
    ZRVideoCaptureViewController *videoCapture = [[ZRVideoCaptureViewController alloc] init];
    videoCapture.maxTime = 15;
    [videoCapture setCaptureCompletion:^(int statusCode, NSString *errorMessage, NSURL *videoURL, NSTimeInterval videoInterval) {
        NSLog(@"视频地址：%@", videoURL.absoluteString);
        
        if (errorMessage.length) {
            NSLog(@"拍摄视频失败 %@", errorMessage);
        } else {
            [self previewVideo:videoURL interval:videoInterval useFirstCompression:YES];
        }
    }];
    [self presentViewController:videoCapture animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

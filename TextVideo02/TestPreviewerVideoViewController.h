//
//  TestPreviewerVideoViewController.h
//  TakeVideos
//
//  Created by Sangxiedong on 2018/9/10.
//  Copyright © 2018年 Victor Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestPreviewerVideoViewController : UIViewController

@property (nonatomic, strong) NSURL *playURL;

@property (nonatomic, assign) NSTimeInterval videoInterval;

@property (nonatomic, assign) BOOL useFirstCompression;

@end

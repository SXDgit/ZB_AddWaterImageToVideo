//
//  ZRMediaCaptureView.m
//  TakeVideos
//
//  Created by VictorZhang on 14/08/2017.
//  Copyright © 2017 Victor Studio. All rights reserved.
//

#import "ZRMediaCaptureView.h"
#import "HProgressView.h"

@interface ZRMediaCaptureView() <UIGestureRecognizerDelegate> {
    BOOL _isBegan;
}

@property (nonatomic, assign, getter=isCapturing) BOOL capture;
@property (nonatomic, strong) UIButton *captureButton;
@property (nonatomic, strong) UIButton *cameraBtnSwitch;
@property (nonatomic, strong) UIButton *flashLightBtn;
@property (nonatomic, strong) UIButton *dismissButton;
@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) HProgressView *progressView;

@end

@implementation ZRMediaCaptureView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.frame = [UIScreen mainScreen].bounds;
        
        //切换前/后摄像头
        UIButton *btnSwitch = [[UIButton alloc] init];
        btnSwitch.frame = CGRectMake(self.frame.size.width - 100, 44, 80, 30);
        [btnSwitch setImage:[UIImage imageNamed:@"btn_video_flip_camera@2x.png"] forState:UIControlStateNormal];
        [btnSwitch addTarget:self action:@selector(cameraSwitchAlternativelyRearOrFront) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnSwitch];
        self.cameraBtnSwitch = btnSwitch;
        _isBegan = NO;
        UIImageView *cameraSwitch = [[UIImageView alloc] init];
        cameraSwitch.translatesAutoresizingMaskIntoConstraints = NO;
        [btnSwitch addSubview:cameraSwitch];
        
        //关闭按钮
        UIButton *cancelBtn = [[UIButton alloc] init];
        cancelBtn.frame = CGRectMake(40, self.frame.size.height - 90, 40, 20);
        [cancelBtn setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(cancelTakingVideo) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancelBtn];
        _dismissButton = cancelBtn;
        
        UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
        bgView.backgroundColor = [UIColor lightTextColor];
        bgView.layer.cornerRadius = 50;
        bgView.layer.masksToBounds = YES;
        bgView.hidden = YES;
        [self addSubview:bgView];
        
        //拍摄按钮
        UIButton *takeVideoBtn = [[UIButton alloc] init];
        takeVideoBtn.frame = CGRectMake((self.frame.size.width - 50) / 2, self.frame.size.height - 110, 50, 50);
        takeVideoBtn.backgroundColor = [UIColor whiteColor];
        takeVideoBtn.layer.cornerRadius = 25;
        takeVideoBtn.layer.masksToBounds = YES;
        [self addSubview:takeVideoBtn];
        self.captureButton = takeVideoBtn;
  
        HProgressView *progressView = [[HProgressView alloc]init];
        progressView.backgroundColor = [UIColor clearColor];
        progressView.frame = CGRectMake(0, 0, 100, 100);
        progressView.layer.cornerRadius = progressView.frame.size.width / 2;
        [self addSubview:progressView];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(LongPressProgressView:)];
        longPress.minimumPressDuration = 0.5;
        [progressView addGestureRecognizer:longPress];
        
        __weak typeof(self) weakSelf = self;
        progressView.timeOverBlock = ^{
            weakSelf.bgView.hidden = YES;
            if ([weakSelf.mediaCaptureDelegate respondsToSelector:@selector(stopCapture)]) {
                [weakSelf.mediaCaptureDelegate stopCapture];
            }
        };
        
        progressView.center = takeVideoBtn.center;
        bgView.center = takeVideoBtn.center;
        self.progressView = progressView;
        self.bgView = bgView;
        
    }
    return self;
}

- (void)flashLightClick {
    
}

- (void)cameraSwitchAlternativelyRearOrFront {
    if ([self.mediaCaptureDelegate respondsToSelector:@selector(cameraDeviceAlternativelyRearOrFront)]) {
        [self.mediaCaptureDelegate cameraDeviceAlternativelyRearOrFront];
    }
}

- (void)cancelTakingVideo {
    if ([self.mediaCaptureDelegate respondsToSelector:@selector(closeCaptureView)]) {
        [self.mediaCaptureDelegate closeCaptureView];
    }
}

- (void)LongPressProgressView:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self startCapture];
    }else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if ([self.mediaCaptureDelegate respondsToSelector:@selector(stopCapture)]) {
            self.capture = NO;
            self.bgView.hidden = YES;
            [self.mediaCaptureDelegate stopCapture];
            [self.progressView clearProgress];
        }
    }
    
}

- (void)startCapture {
    if ([self.mediaCaptureDelegate respondsToSelector:@selector(startCapture)]) {
        self.capture = YES;
        self.bgView.hidden = NO;
        [self.mediaCaptureDelegate startCapture];
        self.progressView.timeMax = self.maxTime;
    }
}

- (void)showCameraSwitch {
    self.cameraBtnSwitch.hidden = NO;
}

- (void)showDismissButton:(BOOL)showDismiss {
    self.dismissButton.hidden = !showDismiss;
}

- (void)dealloc {
    NSLog(@"ZRMediaCaptureView has been deallocated!");
}

@end
 

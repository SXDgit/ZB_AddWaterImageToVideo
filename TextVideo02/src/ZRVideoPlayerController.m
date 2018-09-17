//
//  ZRMoviePlayerController.m
//  TakeVideos
//
//  Created by VictorZhang on 20/08/2017.
//  Copyright © 2017 Victor Studio. All rights reserved.
//

#import "ZRVideoPlayerController.h"
#import <AVFoundation/AVFoundation.h>
#import "ZRAssetExportSession.h"
#import "ZRWaterPrintComposition.h"
#import "ZRCircleProgress.h"
#import "VideoEditView.h"
#import "AddTextDetailView.h"
#import "FWTextView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

#define ZRVideoPlayerButtonDiameter           70
#define ZRVideoPlayerButtonCircleDiameter     (ZRVideoPlayerButtonDiameter + 2)

@interface ZRVideoPlayerController () <FWTextViewDelegate> {
    NSMutableArray *_labelViewArray;
    FWTextView *_selectedLabelView;
    NSString *_labelString;
    NSInteger _tag;
    UIImage *_snapshotImage;
}

@property (nonatomic,strong) AVPlayer *player;    //播放器对象
@property (nonatomic, strong) UIImageView *playingImg;
@property (nonatomic, assign) NSTimeInterval videoTotalLength; //视频总长度
@property (nonatomic, strong) id periodicTimeObserver;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) VideoEditView *editView;
@property (nonatomic, strong) AddTextDetailView *textDetailView;

@end

@implementation ZRVideoPlayerController

- (instancetype)initWithURL:(NSURL *)url
{
    self = [super init];
    if (self) {
        _url = url;
    }
    return self;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _tag = 99;
    _labelViewArray = [NSMutableArray arrayWithCapacity:0];
    [self calculateVideoSize];
    [self setupPlayer];
    [self setupUI];
}

- (void)nextPlayer {
    [self removeObservers];
    [self removeNotification];
    [self.player seekToTime:CMTimeMakeWithSeconds(0, _player.currentItem.duration.timescale)];
    [self.player replaceCurrentItemWithPlayerItem:[self getAVPlayerItem]];
    [self addAVPlayerNtf:self.player.currentItem];
    if (self.player.rate == 0) {
        [self.player play];
    }
}

- (void)setupPlayer {
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.frame = self.view.frame;
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.view.layer addSublayer:playerLayer];
    if (self.player.rate == 0) {
        [self.player play];
    }
    [self addNotification];
    [self addProgressObserver];
}

- (AVPlayer *)player {
    if (!_player) {
        _player = [AVPlayer playerWithPlayerItem:[self getAVPlayerItem]];
        [self addAVPlayerNtf:_player.currentItem];
    }
    return _player;
}

- (AVPlayerItem *)getAVPlayerItem {
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:self.url];
    return playerItem;
}

- (void)addAVPlayerNtf:(AVPlayerItem *)playerItem {
    //监控状态属性
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监控网络加载情况属性
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}

- (void)replaceCurrentPlayerItem:(NSURL *)replacedUrl {
    
}

- (void)setupUI {
    CGRect viewFrame = self.view.frame;
    //背景
    CGFloat btViewHeight = 120;
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, viewFrame.size.height - btViewHeight, viewFrame.size.width, btViewHeight)];
    self.bottomView.backgroundColor = [UIColor clearColor];
    self.bottomView.hidden = YES;
    [self.view addSubview:self.bottomView];
    
    CGFloat btnWidth = ZRVideoPlayerButtonDiameter;
    CGFloat btnHeight = btnWidth;
    CGFloat leftMargin = (viewFrame.size.width - (btnWidth * 3)) / 4;
    CGFloat topMargin = 10;
    CGFloat btnX = leftMargin;
    
    //重拍
    UIView *retakeBtn = [self getButtonWithFrame:CGRectMake(btnX, topMargin, btnWidth, btnHeight) image:@"icon_cancel" type:1];
    [retakeBtn addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(retakeVideo)]];
    [self.bottomView addSubview:retakeBtn];
    
    
    if (!self.playVideOnly) {
        //编辑
        btnX = leftMargin * 2 + btnWidth;
        UIView *editBtn = [self getButtonWithFrame:CGRectMake(btnX, topMargin, btnWidth, btnHeight) image:@"zr_video_play" type:2];
        [editBtn addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editBtnAction)]];
        [self.bottomView addSubview:editBtn];
        
        //确定
        btnX = leftMargin * 3 + btnWidth * 2;
        UIView *okBtn = [self getButtonWithFrame:CGRectMake(btnX, topMargin, btnWidth, btnHeight) image:@"icon_confirm" type:3];
        [okBtn addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(choseVideo)]];
        [self.bottomView addSubview:okBtn];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.bottomView.hidden = NO;
    });
    
    self.editView = [[VideoEditView alloc]init];
    self.editView.hidden = YES;
    __weak typeof(self) weakSelf = self;
    self.editView.cancelButtonBlock = ^{
        [weakSelf deleteTextView];
    };
    self.editView.confirmButtonBlock = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf -> _selectedLabelView.isOnFirst = NO;
        [weakSelf syntheticVideo];
    };
    self.editView.addTextButtonBlock = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf -> _selectedLabelView.isOnFirst = NO;
        [weakSelf showAddTextDetailView];
    };
    [self.view addSubview:self.editView];
}

- (void)deleteTextView {
    for (FWTextView *textView in _labelViewArray) {
        [textView removeFromSuperview];
    }
    
    _selectedLabelView.isOnFirst = NO;
    self.bottomView.hidden = NO;
}

- (void)syntheticVideo {
    self.editView.hidden = YES;
    _snapshotImage = [self nomalSnapshotImage];
    [self addWaterImage];
}

- (UIImage *)nomalSnapshotImage {
    UIGraphicsBeginImageContextWithOptions(self.view.frame.size, NO, [UIScreen mainScreen].scale);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return snapshotImage;
}

- (void)showAddTextDetailView {
    self.textDetailView = [[AddTextDetailView alloc]init];
    __weak typeof(self) weakSelf = self;
    self.textDetailView.cancelEditBlock = ^{
        weakSelf.editView.hidden = NO;
    };
    self.textDetailView.confirmEditBlock = ^(NSString *text) {
        _labelString = text;
        [weakSelf showTextViewWithString:text];
    };
    [self.view addSubview:self.textDetailView];
}

- (void)showTextViewWithString:(NSString *)text {
    self.editView.hidden = NO;
    UILabel *label = [[UILabel alloc]init];
    label.font = [UIFont systemFontOfSize:24];
    label.numberOfLines = 0;
    label.text = text;
    CGFloat height = 24;
    CGFloat width = [label sizeThatFits:CGSizeMake(MAXFLOAT, height)].width;
    if (width > [UIScreen mainScreen].bounds.size.width - 30) {
        width = [UIScreen mainScreen].bounds.size.width - 30;
        height = [label sizeThatFits:CGSizeMake(width, MAXFLOAT)].height;
    }
    
    _selectedLabelView.isOnFirst = NO;
    _tag ++;
    FWTextView *labelView = [[FWTextView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    labelView.currentStr = text;
    labelView.tag = _tag;
    labelView.delegate = self;
    labelView.lineColor = [UIColor whiteColor];
    labelView.textColor = [UIColor whiteColor];
    labelView.textAlpha = 1;
    [self.view addSubview:labelView];
    labelView.center = self.view.center;
    _selectedLabelView = labelView;
    _selectedLabelView.isOnFirst = YES;
    [_labelViewArray addObject:labelView];
}

- (UIView *)getButtonWithFrame:(CGRect)frame image:(NSString *)imageName type:(int)type {
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.layer.cornerRadius = 35;
    
    CGRect subFrame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    
    if ([[UIDevice currentDevice].systemVersion floatValue] > 8.0) {
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        effectView.frame = subFrame;
        effectView.layer.cornerRadius = 35;
        effectView.layer.masksToBounds = YES;
        [view addSubview:effectView];

        if (type == 3) {
            UIView *bg = [[UIView alloc] initWithFrame:subFrame];
            bg.backgroundColor = [UIColor whiteColor];
            bg.layer.cornerRadius = 35;
            bg.alpha = 0.5f;
            [view addSubview:bg];
        }
    } else {
        UIView *bg = [[UIView alloc] initWithFrame:subFrame];
        if (type == 1 || type == 3) {
            bg.backgroundColor = [UIColor whiteColor];
        } else {
            bg.backgroundColor = [UIColor blackColor];
        }
        bg.layer.cornerRadius = 35;
        bg.alpha = 0.6f;
        [view addSubview:bg];
    }
    
    UIImageView *img = [[UIImageView alloc] initWithFrame:subFrame];
    img.image = [UIImage imageNamed:imageName];
    img.layer.cornerRadius = 35;
    [view addSubview:img];
    
    if (type == 2) {
        self.playingImg = img;
    }
    
    return view;
}

- (void)editBtnAction {
    self.bottomView.hidden = YES;
    self.editView.hidden = NO;
}

- (void)retakeVideo {
    [self videoPausedWhenPlaying];
    
    [self dismissViewControllerAnimated:NO completion:nil];
    
    if ([self.videoPlayerDelegate respondsToSelector:@selector(videoPlayerWithRetakingVideo)]) {
        [self.videoPlayerDelegate videoPlayerWithRetakingVideo];
    }
}

- (void)playVideo { 
    if (self.player.rate == 0) {
        [self.player play];
    } else {
        [self videoPausedWhenPlaying];
    }
}

- (void)choseVideo {
    [self videoPausedWhenPlaying];
    [self dismissViewControllerAnimated:NO completion:nil];
    
    __block NSString *createdAssetID = nil;
    NSError *error = nil;
    // 保存视频到相册
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        createdAssetID = [PHAssetCreationRequest creationRequestForAssetFromVideoAtFileURL:self.url].placeholderForCreatedAsset.localIdentifier;
    } error:&error];
    if ([self.videoPlayerDelegate respondsToSelector:@selector(videoPlayerWithChoseVideo:videoInterval:)]) {
        [self.videoPlayerDelegate videoPlayerWithChoseVideo:self.url videoInterval:self.videoTotalLength];
    }
    
}

- (void)addWaterImage {
    ZRCircleProgress *circleProgress = [[ZRCircleProgress alloc] init];
    [self.view addSubview:circleProgress];
    
    NSURL *outputFileURL = [NSURL fileURLWithPath:[ZRAssetExportSession generateAVAssetTmpPath]];
    ZRAssetExportSession *encoder = [ZRAssetExportSession.alloc initWithAsset:[AVAsset assetWithURL:self.url]];
    encoder.outputFileType = AVFileTypeMPEG4;
    encoder.outputURL = outputFileURL;
    [encoder exportAsynchronouslyWithProgressing:^(float progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [circleProgress startWithProgressing:progress];
        });
    }];
    [encoder exportAsynchronouslyWithCompletionHandler:^
     {
         if (encoder.status == AVAssetExportSessionStatusCompleted)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [circleProgress dismiss];
             });
             
             AVAssetTrack *videoTrack = nil;
             AVURLAsset *asset = (AVURLAsset *)[AVAsset assetWithURL:encoder.outputURL];
             NSArray *videoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
             videoTrack = [videoTracks firstObject];
             float frameRate = [videoTrack nominalFrameRate];
             float bps = [videoTrack estimatedDataRate];
             NSLog(@"Frame rate == %f",frameRate);
             NSLog(@"bps rate == %f",bps/(1024.0 * 1024.0));
             NSLog(@"Video export succeeded");
             // encoder.outputURL <- this is what you want!!
             
             NSFileManager *fileManager = [NSFileManager defaultManager];
             NSError * error;
             NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
             int random = arc4random() % 10000001;
             NSString *filename = [NSString stringWithFormat:@"%@/%d.mp4", path, random];
             
             BOOL success = [fileManager copyItemAtURL:encoder.outputURL toURL:[NSURL fileURLWithPath:filename isDirectory:NO] error:&error];
             if (!success) {
                 success = [fileManager copyItemAtPath:encoder.outputURL.absoluteString toPath:filename error:&error];
             }
             NSDictionary *fileAttr = [fileManager attributesOfItemAtPath:filename error:&error];
             long fileSize = [[fileAttr objectForKey:NSFileSize] longValue];
             NSString *bytes = [NSByteCountFormatter stringFromByteCount:fileSize countStyle:NSByteCountFormatterCountStyleFile];
             float fileMB = fileSize / 1024.0 / 1024.0;
             NSLog(@"压缩后视频文件大小 fileMB = %lf   bytes=%@", fileMB, bytes);
             
             self.url = [NSURL fileURLWithPath:filename];
             
             [[ZRWaterPrintComposition new] addVideoWaterprintAtURL:self.url WithWaterprintImage:_snapshotImage completionHandler:^(int status, NSString *errorMsg, NSURL *finishedVideoURL) {
                 if (status == 0) {
                     self.url = finishedVideoURL;
                     
                     [self nextPlayer];
                     self.editView.hidden = YES;
                     self.bottomView.hidden = NO;
                     for (FWTextView *label in _labelViewArray) {
                         [label removeFromSuperview];
                     }
                     
                 } else {
                     NSLog(@"%@", errorMsg);
                 }
             }];
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 self.url = [NSURL fileURLWithPath:filename];
             });
             
         }
         else if (encoder.status == AVAssetExportSessionStatusCancelled)
         {
             NSLog(@"Video export cancelled");
         }
         else
         {
             NSLog(@"Video export failed with error: %@ (%ld)", encoder.error.localizedDescription, encoder.error.code);
         }
     }];
}

- (void)videoPausedWhenPlaying {
    [self.player pause];
}

// 给播放器添加进度更新
- (void)addProgressObserver{
    
    __weak typeof(self) SELF = self;
    self.periodicTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float current = CMTimeGetSeconds(time);
        float total = CMTimeGetSeconds([SELF.player.currentItem duration]);
        float rate = current / total;
        NSLog(@"当前已经播放:%.5fs  播放比例:%.5fs.",current, rate);
    }];
}

#pragma mark - FWTextViewDelegate
- (void)showEditContentViewWith:(NSString *)placeHoldString {
    self.textDetailView.hidden = NO;
    self.textDetailView.textString = _selectedLabelView.contentLab.text;
    [_selectedLabelView removeFromSuperview];
    
}
- (void)makePasterBecomeFirstRespondWith:(NSInteger)tag {
    for (FWTextView *labelView in _labelViewArray) {
        if (labelView.tag == tag) {
            if (labelView == _selectedLabelView) {
                return;
            }else {
                _selectedLabelView.isOnFirst = NO;
                _selectedLabelView = labelView;
                _selectedLabelView.isOnFirst = YES;
            }
        }
    }
}

#pragma mark - Notification
- (void)playbackFinished:(NSNotification *)notification{
    NSLog(@"视频播放完成.");
    [self.player seekToTime:CMTimeMake(0, 1)];
    [self.player play];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}

- (void)removeNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)removeObservers {
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    [self.player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    
    if (self.periodicTimeObserver) {
        [self.player removeTimeObserver:self.periodicTimeObserver];
        self.periodicTimeObserver = nil;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    AVPlayerItem *playerItem = object;
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status = [[change objectForKey:@"new"] intValue];
        if(status == AVPlayerStatusReadyToPlay){
            NSLog(@"视频总长度:%.5f", CMTimeGetSeconds(playerItem.duration));
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSArray *array = playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
        self.videoTotalLength = totalBuffer;
        NSLog(@"视频共缓冲：%.2f",totalBuffer);
    }
}

- (void)calculateVideoSize {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError * error;
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    int random = arc4random() % 10000001;
    NSString *filename = [NSString stringWithFormat:@"%@/%d.mp4", path, random];
    
    BOOL success = [fileManager copyItemAtURL:self.url toURL:[NSURL fileURLWithPath:filename isDirectory:NO] error:&error];
    if (!success) {
        success = [fileManager copyItemAtPath:self.url.absoluteString toPath:filename error:&error];
    }
    NSDictionary *fileAttr = [fileManager attributesOfItemAtPath:filename error:&error];
    long fileSize = [[fileAttr objectForKey:NSFileSize] longValue];
    NSString *bytes = [NSByteCountFormatter stringFromByteCount:fileSize countStyle:NSByteCountFormatterCountStyleFile];
    float fileMB = fileSize / 1024.0 / 1024.0;
    NSLog(@"fileMB = %lf   bytes=%@", fileMB, bytes);
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _selectedLabelView.isOnFirst = NO;
    _selectedLabelView  = nil;
}

- (void)dealloc
{
    [self removeObservers];
    [self removeNotification];
    NSLog(@"ZRVideoPlayerController has been deallocated!");
}

@end

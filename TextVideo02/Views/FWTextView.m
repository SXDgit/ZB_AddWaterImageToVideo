//
//  FWTextView.m
//  Foowwphone
//
//  Created by Sangxiedong on 2018/7/25.
//  Copyright © 2018年 Fooww. All rights reserved.
//

#import "FWTextView.h"

#define FLEX_SLIDE          15.0
#define BT_SLIDE            30.0
#define BORDER_LINE_WIDTH   1.0
@interface FWTextView () <UIGestureRecognizerDelegate> {
    CGFloat _deltaAngle;
    CGPoint _prevPoint;
    CGPoint _touchStart;
    CGSize  _prevSize;
}
@property (nonatomic, strong) UIView *borderView;
@property (nonatomic, assign) CGFloat totalScale;
@property (nonatomic, assign) CGFloat MaxScale;
@property (nonatomic, assign) CGFloat MinScale;
@property (nonatomic, strong) CAShapeLayer *border;

@end


@implementation FWTextView
- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _prevSize = frame.size;
        [self setupWithBGFrame:frame];
        self.totalScale = 1.0;
        self.MaxScale = 544 / (float)self.frame.size.width;
        self.MinScale = 50 / (float)self.frame.size.height;
        [self addSubview:self.borderView];
        [self addSubview:self.contentLab];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _border.path = [UIBezierPath bezierPathWithRect:_borderView.bounds].CGPath;
    _border.frame = _borderView.bounds;
}

- (void)setCurrentStr:(NSString *)currentStr{
    _currentStr = currentStr;
    self.contentLab.text = _currentStr;
}

- (void)setIsOnFirst:(BOOL)isOnFirst {
    _isOnFirst = isOnFirst;
    if (isOnFirst) {
        _border.strokeColor = self.lineColor.CGColor;
    }else {
        _border.strokeColor = [UIColor clearColor].CGColor;
    }
}

- (void)setupWithBGFrame:(CGRect)bgFrame {
    self.backgroundColor = [UIColor redColor];
    self.frame = bgFrame ;
    self.userInteractionEnabled = YES ;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)] ;
    [self addGestureRecognizer:tapGesture] ;
    UIPinchGestureRecognizer *pincheGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)] ;
    pincheGesture.delegate = self;
    [self addGestureRecognizer:pincheGesture] ;
    UIRotationGestureRecognizer *rotateGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)] ;
    [self addGestureRecognizer:rotateGesture] ;
    _deltaAngle = atan2(self.frame.origin.y+self.frame.size.height - self.center.y,
                        self.frame.origin.x+self.frame.size.width - self.center.x) ;
    
}

- (void)tap:(UITapGestureRecognizer *)tapGesture {
    if (!self.isOnFirst) {
        if ([self.delegate respondsToSelector:@selector(makePasterBecomeFirstRespondWith:)]) {
            [self.delegate makePasterBecomeFirstRespondWith:self.tag];
        }
    }else {
        if ([self.delegate respondsToSelector:@selector(showEditContentViewWith:)]) {
            [self.delegate showEditContentViewWith:self.contentLab.text];
        }
    }
}

- (void)handlePinch:(UIPinchGestureRecognizer *)pinchGesture {
    if (pinchGesture.state == UIGestureRecognizerStateBegan) {
        _prevPoint = [pinchGesture locationInView:self];
        pinchGesture.scale = 1;
    }
    if (pinchGesture.state == UIGestureRecognizerStateChanged) {
        if (pinchGesture.scale > 1.0) {
            if (self.totalScale > self.MaxScale) {
                return;
            }
        }
        if (pinchGesture.scale < 1.0) {
            if (self.totalScale < self.MinScale) {
                return;
            }
        }
        
        self.transform = CGAffineTransformScale(self.transform, pinchGesture.scale, pinchGesture.scale);
        self.totalScale *= pinchGesture.scale;
        pinchGesture.scale = 1;
        
        [self setNeedsDisplay];
    }
    if (pinchGesture.state == UIGestureRecognizerStateEnded) {
        NSLog(@"缩放%f", self.totalScale);
    }
}

- (void)handleRotation:(UIRotationGestureRecognizer *)rotateGesture {
    self.transform = CGAffineTransformRotate(self.transform, rotateGesture.rotation) ;
    rotateGesture.rotation = 0 ;
}

- (void)translateUsingTouchLocation:(CGPoint)touchPoint {
    CGPoint newCenter = CGPointMake(self.center.x + touchPoint.x - _touchStart.x,
                                    self.center.y + touchPoint.y - _touchStart.y) ;
    CGFloat midPointX = CGRectGetMidX(self.bounds) ;
    if (newCenter.x > self.superview.bounds.size.width + midPointX - 40) {
        newCenter.x = self.superview.bounds.size.width + midPointX - 40;
    }
    if (newCenter.x < 0 - midPointX + 40)  {
        newCenter.x = -midPointX + 40;
    }
    CGFloat midPointY = CGRectGetMidY(self.bounds);
    if (newCenter.y > self.superview.bounds.size.height + midPointY - 40) {
        newCenter.y = self.superview.bounds.size.height + midPointY - 40;
    }
    if (newCenter.y < -midPointY + 40) {
        newCenter.y = -midPointY + 40;
    }
    self.center = newCenter;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    _touchStart = [touch locationInView:self.superview];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchMove = [touch locationInView:self.superview];
    if (fabs(touchMove.x - _touchStart.x) > 2 || fabs(touchMove.y - _touchStart.y) > 2) {
        if ([self.delegate respondsToSelector:@selector(makePasterBecomeFirstRespondWith:)]) {
            [self.delegate makePasterBecomeFirstRespondWith:self.tag];
        }
    }
    [self translateUsingTouchLocation:touchMove];
    _touchStart = touchMove;
}

#pragma mark -- Properties
- (void)setisOnFirst:(BOOL)isOnFirst {
    _isOnFirst = isOnFirst ;
    _border.strokeColor = isOnFirst ? [UIColor whiteColor].CGColor : [UIColor clearColor].CGColor;
    
    if (isOnFirst) {
        //        NSLog(@"pasterID : %d is On",self.pasterID) ;
    }
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    self.contentLab.textColor = textColor;
}

- (void)setTextAlpha:(CGFloat)textAlpha {
    _textAlpha = textAlpha;
    self.contentLab.alpha = _textAlpha;
}

- (UILabel *)contentLab {
    if (!_contentLab) {
        _contentLab = [[UILabel alloc]init];
        _contentLab.frame = CGRectMake(0, 0, _prevSize.width, _prevSize.height);
        _contentLab.textAlignment = NSTextAlignmentCenter;
        _contentLab.font = [UIFont systemFontOfSize:24];
        _contentLab.textColor = [UIColor clearColor];
        _contentLab.numberOfLines = 0;
        _contentLab.userInteractionEnabled = YES;
        _contentLab.adjustsFontSizeToFitWidth = YES;
    }
    return  _contentLab;
}

- (UIView *)borderView {
    if (!_borderView) {
        _borderView = [[UIView alloc]init];
        _borderView.frame = CGRectMake(0, 0, _prevSize.width, _prevSize.height);
        _borderView.backgroundColor = [UIColor clearColor];
        
        _border = [CAShapeLayer layer];
        _border.strokeColor = [UIColor whiteColor].CGColor;
        _border.fillColor = [UIColor clearColor].CGColor;
        _border.path = [UIBezierPath bezierPathWithRect:_borderView.bounds].CGPath;
        _border.frame = _borderView.bounds;
        _border.lineWidth = BORDER_LINE_WIDTH;
        //虚线的间隔
        _border.lineDashPattern = @[@8, @4];
        [_borderView.layer addSublayer:_border];
    }
    return _borderView;
}

@end

//
//  VideoEditView.m
//  TextVideo02
//
//  Created by Sangxiedong on 2018/9/11.
//  Copyright © 2018年 ZB. All rights reserved.
//

#import "VideoEditView.h"

@interface VideoEditView ()

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *bottomView;

@end

@implementation VideoEditView

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        self.frame = [UIScreen mainScreen].bounds;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        [self addGestureRecognizer:tap];
        [self configUI];
    }
    return self;
}

- (void)configUI {
    UIButton *cancelBtn = [self createButtonWithTitle:@"取消" AndFrame:CGRectMake(15, 20, 50, 40)];
//    [cancelBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:cancelBtn];
    
    UIButton *confirmBtn = [self createButtonWithTitle:@"完成" AndFrame:CGRectMake(self.frame.size.width - 65, 20, 50, 40)];
    [confirmBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [confirmBtn addTarget:self action:@selector(confirmButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:confirmBtn];
    [self addSubview:self.topView];
    
    UIButton *addTextBtn = [self createButtonWithTitle:@"文字" AndFrame:CGRectMake(15, 0, 50, 40)];
    [addTextBtn addTarget:self action:@selector(addTextButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:addTextBtn];
    [self addSubview:self.bottomView];
}

#pragma mark -Action
- (void)tapAction:(UITapGestureRecognizer *)tap {
    self.topView.hidden = !self.topView.hidden;
    self.bottomView.hidden = !self.bottomView.hidden;
}

- (void)cancelButtonAction {
    self.hidden = YES;
    if (self.cancelButtonBlock) {
        self.cancelButtonBlock();
    }
}

- (void)confirmButtonAction {
    
    if (self.confirmButtonBlock) {
        self.confirmButtonBlock();
    }
}

- (void)addTextButtonAction {
    self.hidden = YES;
    if (self.addTextButtonBlock) {
        self.addTextButtonBlock();
    }
}

- (UIButton *)createButtonWithTitle:(NSString *)title AndFrame:(CGRect)frame {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    return button;
}

- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 60)];
        _topView.backgroundColor = [UIColor clearColor];
    }
    return _topView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height - 40, self.frame.size.width, 40)];
        _bottomView.backgroundColor = [UIColor clearColor];
    }
    return _bottomView;
}

@end

//
//  AddTextDetailView.m
//  TextVideo02
//
//  Created by Sangxiedong on 2018/9/11.
//  Copyright © 2018年 ZB. All rights reserved.
//

#import "AddTextDetailView.h"

@interface AddTextDetailView () <UITextViewDelegate>

@property (nonatomic, strong) UITextView *textView;

@end

@implementation AddTextDetailView

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        self.frame = [UIScreen mainScreen].bounds;
        [self configUI];
    }
    return self;
}

- (void)configUI {
    UIButton *cancelBtn = [self createButtonWithTitle:@"取消" AndFrame:CGRectMake(15, 20, 50, 40)];
    [cancelBtn addTarget:self action:@selector(cancelButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelBtn];
    
    UIButton *confirmBtn = [self createButtonWithTitle:@"完成" AndFrame:CGRectMake(self.frame.size.width - 65, 20, 50, 40)];
    [confirmBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [confirmBtn addTarget:self action:@selector(confirmButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:confirmBtn];
    
    self.textView = [[UITextView alloc]initWithFrame:CGRectMake(15, 80, self.frame.size.width - 30, 200)];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.delegate = self;
    self.textView.font = [UIFont systemFontOfSize:20];
    self.textView.textColor = [UIColor redColor];
    [self addSubview:self.textView];
    [self.textView becomeFirstResponder];
}

-(void)setTextString:(NSString *)textString {
    _textString = textString;
    self.textView.text = _textString;
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.textView.text = textView.text;
}

#pragma mark - Action
- (void)cancelButtonAction {
    [self.textView resignFirstResponder];
    self.hidden = YES;
    if (self.cancelEditBlock) {
        self.cancelEditBlock();
    }
}

- (void)confirmButtonAction {
    [self.textView resignFirstResponder];
    self.hidden = YES;
    if (self.confirmEditBlock) {
        self.confirmEditBlock(self.textView.text);
    }
}

- (UIButton *)createButtonWithTitle:(NSString *)title AndFrame:(CGRect)frame {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    return button;
}


@end

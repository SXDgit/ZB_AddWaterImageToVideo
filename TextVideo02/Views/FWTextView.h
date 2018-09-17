//
//  FWTextView.h
//  Foowwphone
//
//  Created by Sangxiedong on 2018/7/25.
//  Copyright © 2018年 Fooww. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FWTextViewDelegate <NSObject>
- (void)showEditContentViewWith:(NSString *)placeHoldString;
- (void)makePasterBecomeFirstRespondWith:(NSInteger)tag;
@end

@interface FWTextView : UIView

@property (nonatomic, strong) UILabel *contentLab;
@property (nonatomic, strong) NSString *currentStr;
@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, assign) CGFloat textAlpha;
@property (nonatomic, assign) BOOL isOnFirst;
@property (nonatomic, weak) id <FWTextViewDelegate> delegate;

@end

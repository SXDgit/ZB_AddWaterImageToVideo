//
//  HProgressView.h
//  Join
//
//  Created by 黄克瑾 on 2017/2/2.
//  Copyright © 2017年 huangkejin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TimeOverBlock)(void);
@interface HProgressView : UIView

@property (nonatomic, assign) NSInteger timeMax;
@property (nonatomic, copy) TimeOverBlock timeOverBlock;

- (void)clearProgress;

@end

//
//  VideoEditView.h
//  TextVideo02
//
//  Created by Sangxiedong on 2018/9/11.
//  Copyright © 2018年 ZB. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CancelButtonBlock)(void);
typedef void(^ConfirmButtonBlock)(void);
typedef void(^AddTextButtonBlock)(void);
@interface VideoEditView : UIView

@property (nonatomic, copy) CancelButtonBlock cancelButtonBlock;
@property (nonatomic, copy) ConfirmButtonBlock confirmButtonBlock;
@property (nonatomic, copy) AddTextButtonBlock addTextButtonBlock;

@end

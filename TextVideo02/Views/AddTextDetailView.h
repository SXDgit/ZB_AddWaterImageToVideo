//
//  AddTextDetailView.h
//  TextVideo02
//
//  Created by Sangxiedong on 2018/9/11.
//  Copyright © 2018年 ZB. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CancelEditBlock)(void);
typedef void(^ConfirmEditBlock)(NSString *);

@interface AddTextDetailView : UIView

@property (nonatomic, strong) NSString *textString;

@property (nonatomic, copy) CancelEditBlock cancelEditBlock;
@property (nonatomic, copy) ConfirmEditBlock confirmEditBlock;

@end

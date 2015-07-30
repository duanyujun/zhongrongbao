//
//  BIDCustomKeyboard.h
//  zhongrongbao
//
//  Created by mal on 14-8-21.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum FUNCTION_TYPE
{
    FUNCTION_RECHARGE,
    FUNCTION_WITHDRAWAL
}FUNCTION_TYPE;

@protocol BIDCustomKeyboardDelegate <NSObject>

/**
 *键盘消失
 */
- (void)dismissKeyboard;
/**
 *充值或提现
 */
- (void)rechargeOrWithdrawal;

@end

@interface BIDCustomKeyboard : UIView<UIInputViewAudioFeedback>
{
    IBOutlet UIButton *_functionBtn;
}

@property (nonatomic,assign) id<UITextInput>textInputDelegate;

/**
 *自定义键盘的右下角按钮显示的文字
 */
@property (copy, nonatomic) NSString *functionBtnTitle;

@property (assign, nonatomic) id<BIDCustomKeyboardDelegate> delegate;

@property (assign, nonatomic) UITextField *textField;

- (void)initView;

@end

//
//  BIDBottomView.h
//  zhongrongbao
//
//  Created by mal on 14-8-15.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BIDCustomTextField.h"

@protocol BIDBottomViewDelegate <NSObject>

- (void)toTenderWithAmount:(NSString*)strAmount password:(NSString*)strPassword;

@end

@interface BIDBottomView : UIView
{
    /**
     *账户余额
     */
    IBOutlet UILabel *_leftAmountLabel;
    /**
     *投标
     */
    IBOutlet UIButton *_tenderBtn;
    /**
     *
     */
    IBOutlet UIView *_myView;
    /**
     *金额输入框
     */
    IBOutlet UITextField *_amountTextField;
    /**
     *金额输入框键盘辅助视图
     */
    UIToolbar *_keyboardToolBar;
    /**
     *密码输入框
     */
    IBOutlet BIDCustomTextField *_passwordTF;
}
/**
 *是否为集团标
 */
@property (assign, nonatomic) BOOL isGroupTender;
/**可投余额*/
@property (copy, nonatomic) NSString *leftAmount;
/**输入的金额*/
@property (copy, nonatomic) NSString *inputAmount;
/**输入的密码*/
@property (copy, nonatomic) NSString *password;
/***/
@property (assign, nonatomic)id<BIDBottomViewDelegate> delegate;
/**
 *新标预告中的预计开标时间label
 */
@property (strong, nonatomic) IBOutlet UILabel *predictTimeLabel;

/**
 *投标
 */
- (IBAction)tenderBtnHandler:(id)sender;

- (void)initView;

- (void)closeKeyboard;

- (void)setCanInvestAmt:(NSString*)strAmount leftAmt:(NSString*)strLeftAmt;

- (void)disableTenderBtn;
/**
 *清空已经填写的金额、密码内容
 */
- (void)clearData;
/**
 *添加遮罩层
 */
- (void)addMaskView;
/**
 *去掉遮罩层
 */
- (void)removeMaskView;

@end

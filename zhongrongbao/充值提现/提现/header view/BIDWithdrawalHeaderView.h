//
//  BIDWithdrawalHeaderView.h
//  zhongrongbao
//
//  Created by mal on 14-9-2.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BIDCustomKeyboard;

@protocol BIDWithdrawalHeaderViewDelegate <NSObject>

- (void)toWithdrawalWithAmount:(NSString*)strAmount;
- (void)toBindingBankCard;

@end

@interface BIDWithdrawalHeaderView : UIView
{
    BIDCustomKeyboard *_customKeyboard;
    IBOutlet UIButton *_withdrawalBtn;
    IBOutlet UIButton *_bindingBankBtn;
    IBOutlet UILabel *_label1;
    IBOutlet UILabel *_label2;
}

/**
 *可用余额
 */
@property (strong, nonatomic) IBOutlet UILabel *availableBalanceLabel;
/**
 *提现金额
 */
@property (strong, nonatomic) IBOutlet UITextField *withdrawalAmountTF;

@property (assign, nonatomic) id<BIDWithdrawalHeaderViewDelegate> delegate;

- (void)initView;

- (IBAction)withdrawalBtnHandler:(id)sender;
/**
 *绑定银行卡
 */
- (IBAction)bindingBankBtnHandler:(id)sender;
/**
 *未绑定银行卡则显示需要绑定银行卡
 */
- (void)isShowBindingBankView:(BOOL)bShow;

@end

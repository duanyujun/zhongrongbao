//
//  BIDWithdrawalHeaderView.m
//  zhongrongbao
//
//  Created by mal on 14-9-2.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDWithdrawalHeaderView.h"
#import "BIDCustomKeyboard.h"
#import "BIDCommonMethods.h"

@interface BIDWithdrawalHeaderView()<BIDCustomKeyboardDelegate>
{
}

@end

@implementation BIDWithdrawalHeaderView
@synthesize availableBalanceLabel;
@synthesize withdrawalAmountTF;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)initView
{
    //
    _bindingBankBtn.layer.borderWidth = 1;
    _bindingBankBtn.layer.borderColor = [UIColor colorWithRed:20.0f/255.0f green:134.0f/255.0f blue:224.0f/255.0f alpha:1.0f].CGColor;
    //
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [label setText:@"元"];
    [label setTextColor:[UIColor whiteColor]];
    [label setTextColor:[UIColor lightGrayColor]];
    [label setFont:[UIFont systemFontOfSize:12.0f]];
    withdrawalAmountTF.rightView = label;
    withdrawalAmountTF.rightViewMode = UITextFieldViewModeAlways;
    //withdrawalAmountTF.layer.borderWidth = 1;
    //withdrawalAmountTF.layer.borderColor = [UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0f].CGColor;
    //
    _customKeyboard = (BIDCustomKeyboard*)[[[NSBundle mainBundle] loadNibNamed:@"BIDCustomKeyboard" owner:self options:nil] lastObject];
    [_customKeyboard initView];
    _customKeyboard.delegate = self;
    _customKeyboard.functionBtnTitle = @"提现";
    _customKeyboard.textField = withdrawalAmountTF;
    withdrawalAmountTF.inputView = _customKeyboard;
    //
    [BIDCommonMethods setImgForBtn:_withdrawalBtn imgForNormal:@"blueBtnBgNormal.png" imgForPress:@"blueBtnBgPress.png" inset:UIEdgeInsetsMake(10, 10, 11, 11)];
}

- (void)isShowBindingBankView:(BOOL)bShow
{
    if(bShow)
    {
        _label1.hidden = YES;
        _label2.hidden = YES;
        _withdrawalBtn.hidden = YES;
        withdrawalAmountTF.hidden = YES;
        availableBalanceLabel.hidden = YES;
        _bindingBankBtn.hidden = NO;
    }
    else
    {
        _label1.hidden = NO;
        _label2.hidden = NO;
        _withdrawalBtn.hidden = NO;
        withdrawalAmountTF.hidden = NO;
        availableBalanceLabel.hidden = NO;
        _bindingBankBtn.hidden = YES;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)bindingBankBtnHandler:(id)sender
{
    [delegate toBindingBankCard];
}
- (IBAction)withdrawalBtnHandler:(id)sender
{
    [delegate toWithdrawalWithAmount:withdrawalAmountTF.text];
}

#pragma mark BIDCustomKeyboardDelegate

- (void)dismissKeyboard
{
    [withdrawalAmountTF resignFirstResponder];
}

/**
 *提现
 */
- (void)rechargeOrWithdrawal
{
    [delegate toWithdrawalWithAmount:withdrawalAmountTF.text];
}

@end

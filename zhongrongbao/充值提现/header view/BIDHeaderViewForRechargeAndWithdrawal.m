//
//  BIDHeaderViewForRechargeAndWithdrawal.m
//  zhongrongbao
//
//  Created by mal on 14-8-18.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDHeaderViewForRechargeAndWithdrawal.h"
#import "BIDCustomKeyboard.h"
#import "BIDCommonMethods.h"

@interface BIDHeaderViewForRechargeAndWithdrawal()<BIDCustomKeyboardDelegate>
{}
@end

@implementation BIDHeaderViewForRechargeAndWithdrawal

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
    [self setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:240.0f/255.0f blue:241.0f/255.0f alpha:1.0f]];
    //
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [label setText:@"元"];
    [label setTextColor:[UIColor whiteColor]];
    [label setTextColor:[UIColor lightGrayColor]];
    [label setFont:[UIFont systemFontOfSize:12.0f]];
    _amountTF.rightView = label;
    _amountTF.rightViewMode = UITextFieldViewModeAlways;
    _amountTF.layer.borderWidth = 1;
    _amountTF.layer.borderColor = [UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0f].CGColor;
    _customKeyboard = (BIDCustomKeyboard*)[[[NSBundle mainBundle] loadNibNamed:@"BIDCustomKeyboard" owner:self options:nil] lastObject];
    [_customKeyboard initView];
    _customKeyboard.delegate = self;
    _customKeyboard.textField = _amountTF;
    _amountTF.inputView = _customKeyboard;
    [_segmentedControl addTarget:self action:@selector(segmentedControlValueChangedHandler:) forControlEvents:UIControlEventValueChanged];
    //
    [_bgView setBackgroundColor:[UIColor colorWithRed:39.0f/255.0f green:149.0f/255.0f blue:205.0f/255.0f alpha:1.0f]];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)segmentedControlValueChangedHandler:(UISegmentedControl*)segmentedControl
{
    if(segmentedControl.selectedSegmentIndex == 0)
    {
        //充值
        [_label1 setText:@"请输入充值金额"];
        [_label2 setText:@"充值金额为100的倍数"];
        [_customKeyboard setFunctionBtnTitle:@"充值"];
    }
    else
    {
        //提现
        [_label1 setText:@"请输入提现金额"];
        [_label2 setText:@"提现金额为100的倍数"];
        [_customKeyboard setFunctionBtnTitle:@"提现"];
    }
}

- (void)closeKeyboardHandler
{
    [_amountTF resignFirstResponder];
}

#pragma mark BIDCustomKeyboardDelegate

- (void)dismissKeyboard
{
    [_amountTF resignFirstResponder];
}

/**
 *充值或提现
 */
- (void)rechargeOrWithdrawal
{
    NSString *msg = @"";
    if(_segmentedControl.selectedSegmentIndex == 0)
    {
        //充值
        msg = @"充值";
    }
    else
    {
        //提现
        msg = @"提现";
    }
    [BIDCommonMethods showAlertView:@"" buttonTitle:msg delegate:nil tag:0];
}

@end

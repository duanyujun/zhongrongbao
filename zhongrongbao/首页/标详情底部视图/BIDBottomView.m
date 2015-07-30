//
//  BIDBottomView.m
//  zhongrongbao
//
//  Created by mal on 14-8-15.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDBottomView.h"
#import "BIDCustomKeyboard.h"

@interface BIDBottomView()<BIDCustomKeyboardDelegate>
{
    BIDCustomKeyboard *_customKeyboard;
    UIView *_maskView;
}

@end

@implementation BIDBottomView
@synthesize delegate;
@synthesize isGroupTender;
@synthesize leftAmount;
@synthesize predictTimeLabel;

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
    _inputAmount = @"";
    _password = @"";
    CGSize toolBarSize = CGSizeMake(320, 30);
    CGRect toolBarFrame = CGRectMake(0, 0, toolBarSize.width, toolBarSize.height);
    _keyboardToolBar = [[UIToolbar alloc] initWithFrame:toolBarFrame];
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"关闭键盘" style:UIBarButtonItemStyleBordered target:self action:@selector(closeKeyboardHandler)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [_keyboardToolBar setItems:[[NSArray alloc] initWithObjects:item2, item1, nil]];
    _keyboardToolBar.barStyle = UIBarStyleBlack;
    _keyboardToolBar.translucent = YES;
    _customKeyboard = (BIDCustomKeyboard*)[[[NSBundle mainBundle] loadNibNamed:@"BIDCustomKeyboard" owner:self options:nil] lastObject];
    [_customKeyboard initView];
    _customKeyboard.functionBtnTitle = @"投标";
    _customKeyboard.delegate = self;
    _customKeyboard.textField = _amountTextField;
    _amountTextField.inputView = _customKeyboard;
    //
    _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    [_maskView setBackgroundColor:[UIColor colorWithWhite:0.1f alpha:0.8f]];
    //
    if(isGroupTender)
    {
        _passwordTF.inputAccessoryView = _keyboardToolBar;
    }
}

- (void)closeKeyboardHandler
{
    if(isGroupTender)
    {
        self.password = _passwordTF.text;
        [_passwordTF resignFirstResponder];
    }
    self.inputAmount = _amountTextField.text;
    [_amountTextField resignFirstResponder];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    _myView.layer.cornerRadius = 5;
    _myView.clipsToBounds = YES;
    if(isGroupTender)
    {
        _passwordTF.layer.cornerRadius = 5;
        _passwordTF.layer.borderWidth = 1.0f;
        _passwordTF.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
}

- (void)setCanInvestAmt:(NSString *)strAmount leftAmt:(NSString *)strLeftAmt
{
    _leftAmountLabel.text = [[NSString alloc] initWithFormat:@"可投金额: %@, 可用余额: %@", strAmount, strLeftAmt];
}

- (void)setInputAmount:(NSString *)inputAmount
{
    _inputAmount = inputAmount;
}

- (void)disableTenderBtn
{
    if(isGroupTender)
    {
        _passwordTF.enabled = NO;
    }
    _amountTextField.enabled = NO;
    _tenderBtn.enabled = NO;
    [_tenderBtn setBackgroundColor:[UIColor lightGrayColor]];
}

- (IBAction)tenderBtnHandler:(id)sender
{
    [delegate toTenderWithAmount:_amountTextField.text password:_passwordTF.text];
}

- (void)closeKeyboard
{
    if(isGroupTender)
    {
        [_passwordTF resignFirstResponder];
        [_amountTextField resignFirstResponder];
    }
    else
    {
        [_amountTextField resignFirstResponder];
    }
}

- (void)clearData
{
    if(isGroupTender)
    {
        [_passwordTF setText:@""];
    }
    [_amountTextField setText:@""];
}
/**
 *添加遮罩层
 */
- (void)addMaskView
{
    [self addSubview:_maskView];
}
/**
 *去掉遮罩层
 */
- (void)removeMaskView
{
    [_maskView removeFromSuperview];
}

#pragma mark BIDCustomKeyboardDelegate

- (void)dismissKeyboard
{
    [_amountTextField resignFirstResponder];
}
/**
 *投标
 */
- (void)rechargeOrWithdrawal
{
    NSString *strContent = _amountTextField.text;
    if([strContent rangeOfString:@"."].location!=NSNotFound && [strContent rangeOfString:@"."].location==strContent.length-1)
    {
        NSRange range = [strContent rangeOfString:@"."];
        strContent = [strContent stringByReplacingCharactersInRange:range withString:@""];
        _amountTextField.text = strContent;
    }
    [delegate toTenderWithAmount:_amountTextField.text password:_passwordTF.text];
}

@end

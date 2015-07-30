//
//  BIDCustomKeyboard.m
//  zhongrongbao
//
//  Created by mal on 14-8-21.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDCustomKeyboard.h"

@implementation BIDCustomKeyboard
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {

    }
    return self;
}

- (void)initView
{
    for(int i=1; i<15; i++)
    {
        UIButton *btn = (UIButton*)[self viewWithTag:i];
        btn.layer.cornerRadius = 3;
        btn.layer.shadowColor = [UIColor blackColor].CGColor;
        btn.layer.shadowOffset = CGSizeMake(22, -22);
        btn.layer.shadowRadius = 10;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(btn.frame)-1, CGRectGetWidth(btn.frame), 1)];
        label.layer.cornerRadius = 3;
        label.layer.masksToBounds = YES;
        [label setBackgroundColor:[UIColor lightGrayColor]];
        [btn addSubview:label];
    }
    //设置功能按钮背景图片
    [_functionBtn setBackgroundImage:[UIImage imageNamed:@"functionBtnBg.png"] forState:UIControlStateNormal];
    [_functionBtn setBackgroundImage:[UIImage imageNamed:@"functionBtnBgPress.png"] forState:UIControlStateHighlighted];
    [_functionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_functionBtn.titleLabel setFont:[UIFont fontWithName:@"Arial Rounded MT Bold" size:21.0f]];
    [_functionBtn setTitle:@"充值" forState:UIControlStateNormal];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (id<UITextInput>)textInputDelegate {
    return _textField;
}

- (void)setTextField:(UITextField *)textField {
    _textField = textField;
    _textField.inputView = self;
}
/**
 *设置功能按钮文本
 */
- (void)setFunctionBtnTitle:(NSString *)functionBtnTitle
{
    [_functionBtn setTitle:functionBtnTitle forState:UIControlStateNormal];
}

/**
 *数字按钮事件
 */
- (IBAction)digitalBtnTouchUpInsideHandler:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    NSString *strContent = _textField.text;
    if(btn.tag==11)//小数点不能作为第一位数字
    {
        if(strContent.length>0 && [strContent rangeOfString:@"."].location==NSNotFound)
        {
            [self.textInputDelegate insertText:@"."];
        }
    }
    else if(btn.tag==10)//0不能作为第一位数字
    {
        if(strContent.length>0)
        {
            [self.textInputDelegate insertText:@"0"];
        }
    }
    else
    {
        if([strContent rangeOfString:@"."].location!=NSNotFound && strContent.length-[strContent rangeOfString:@"."].location>2)
        {}
        else
        {
            [self.textInputDelegate insertText:[[NSString alloc] initWithFormat:@"%d", btn.tag%10]];
        }
    }
    [[UIDevice currentDevice] playInputClick];
}

/**
 *键盘消失按钮
 */
- (IBAction)dismissBtnTouchUpInsideHandler:(id)sender
{
    [delegate dismissKeyboard];
}

/**
 *功能按钮事件
 */
- (IBAction)functionBtnTouchUpInsideHandler:(id)sender
{
    [delegate dismissKeyboard];
    NSString *strContent = _textField.text;
    if([strContent rangeOfString:@"."].location!=NSNotFound && [strContent rangeOfString:@"."].location==strContent.length-1)
    {
        NSRange range = [strContent rangeOfString:@"."];
        strContent = [strContent stringByReplacingCharactersInRange:range withString:@""];
        _textField.text = strContent;
    }
    [delegate rechargeOrWithdrawal];
}

/**
 *退格按钮事件
 */
- (IBAction)backspaceBtnTouchUpInsideHandler:(id)sender
{
    [self.textInputDelegate deleteBackward];
    [[UIDevice currentDevice] playInputClick];
}

#pragma mark - UIInputViewAudioFeedback delegate

- (BOOL)enableInputClicksWhenVisible
{
    return YES;
}

@end

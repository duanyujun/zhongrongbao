//
//  BIDTenderAmountView.m
//  zhongrongbao
//
//  Created by mal on 15/7/5.
//  Copyright (c) 2015年 cnsoft. All rights reserved.
//

#import "BIDTenderAmountView.h"
#import "BIDCustomKeyboard.h"
#import "BIDCommonMethods.h"
#import "BIDActivityListView.h"

@interface BIDTenderAmountView()<BIDCustomKeyboardDelegate, BIDActivityListViewDelegate>
{
    BIDCustomKeyboard *_customKeyboard;
    //红包或体验金id
    NSString *_redPacketId;
    NSString *_tiYanJinId;
    //投标密码
    NSString *_tenderPwd;
    //
    UIToolbar *_toolBar;
}
@end

@implementation BIDTenderAmountView
@synthesize delegate;
@synthesize leftAmount;
@synthesize canInvestAmt;

- (void)awakeFromNib
{
//    UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, CGRectGetHeight(_amountTF.frame))];
//    leftLabel.text = @"投资";
//    [self setLabelAttribute:leftLabel];
//    UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, CGRectGetHeight(_amountTF.frame))];
//    rightLabel.text = @"元";
//    [self setLabelAttribute:rightLabel];
//    _amountTF.leftView = leftLabel;
//    _amountTF.leftViewMode = UITextFieldViewModeAlways;
//    _amountTF.rightView = rightLabel;
//    _amountTF.rightViewMode = UITextFieldViewModeAlways;
    //
    canInvestAmt = -10000.f;
    leftAmount = 0.f;
    _tenderPwd = @"";
    _redPacketId = @"";
    _tiYanJinId = @"";
    //
    _cancelBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _cancelBtn.layer.borderWidth = 1.0f;
    //
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, 30)];
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"关闭键盘" style:UIBarButtonItemStyleBordered target:self action:@selector(closeKeyboardHandler)];
    item1.tintColor = [UIColor whiteColor];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [_toolBar setItems:[[NSArray alloc] initWithObjects:item2, item1, nil]];
    _toolBar.barStyle = UIBarStyleBlack;
    _toolBar.translucent = YES;
    _pwdTF.inputAccessoryView = _toolBar;
    //
    _customKeyboard = (BIDCustomKeyboard*)[[[NSBundle mainBundle] loadNibNamed:@"BIDCustomKeyboard" owner:self options:nil] lastObject];
    [_customKeyboard initView];
    _customKeyboard.functionBtnTitle = @"投标";
    _customKeyboard.delegate = self;
    _customKeyboard.textField = _amountTF;
    _amountTF.inputView = _customKeyboard;
    //
    self.layer.cornerRadius = 5;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)closeKeyboardHandler
{
    [_pwdTF resignFirstResponder];
}

- (void)setLeftAmount:(CGFloat)leftAmount1
{
    _leftAmountLabel.text = [[NSString alloc] initWithFormat:@"账户余额:%.2f元", leftAmount1];
    leftAmount = leftAmount1;
}

- (void)setCanInvestAmt:(CGFloat)canInvestAmt1
{
    _canInvestAmtLabel.text = [[NSString alloc] initWithFormat:@"可投金额:%.2f元", canInvestAmt1];
    canInvestAmt = canInvestAmt1;
}

- (void)setLabelAttribute:(UILabel*)label
{
    label.font = [UIFont systemFontOfSize:15.0f];
    label.textColor = [UIColor colorWithRed:151.0f/255.0f green:151.0f/255.0f blue:151.0f/255.0f alpha:1.0f];
}

- (void)toTender
{
    if(_amountTF.text.length==0)
    {
        [BIDCommonMethods showAlertView:@"请输入投标金额" buttonTitle:@"关闭" delegate:nil tag:0];
        return;
    }
    NSString *strContent = _amountTF.text;
    if([strContent rangeOfString:@"."].location!=NSNotFound && [strContent rangeOfString:@"."].location==strContent.length-1)
    {
        NSRange range = [strContent rangeOfString:@"."];
        strContent = [strContent stringByReplacingCharactersInRange:range withString:@""];
        _amountTF.text = strContent;
    }
    _amountTF.text = @"";
    CGFloat inputAmount = [strContent floatValue];
    if(inputAmount > leftAmount)
    {
        [BIDCommonMethods showAlertView:@"账户余额不足" buttonTitle:@"关闭" delegate:nil tag:0];
        return;
    }
    else if(inputAmount<10)
    {
        [BIDCommonMethods showAlertView:@"投标金额不能低于10元" buttonTitle:@"关闭" delegate:nil tag:0];
        return;
    }
    else if(canInvestAmt!=-10000 && canInvestAmt<inputAmount)
    {
        [BIDCommonMethods showAlertView:@"可投金额不足" buttonTitle:@"关闭" delegate:nil tag:0];
        return;
    }
    _tenderPwd = _pwdTF.text;
    NSString *strActivityIds = @"[]";
    if(_redPacketId.length>0 && _tiYanJinId.length>0)
    {
        strActivityIds = [[NSString alloc] initWithFormat:@"[\"%@\", \"%@\"]", _redPacketId, _tiYanJinId];
    }
    else
    {
        if(_redPacketId.length>0)
        {
            strActivityIds = [[NSString alloc] initWithFormat:@"[\"%@\"]", _redPacketId];
        }
        if(_tiYanJinId.length>0)
        {
            strActivityIds = [[NSString alloc] initWithFormat:@"[\"%@\"]", _tiYanJinId];
        }
    }
    _redPacketId = @"";
    _tiYanJinId = @"";
    [delegate toTenderWithAmount:strContent password:_tenderPwd activityId:strActivityIds];
    [_amountTF resignFirstResponder];
}

- (IBAction)cancelBtnHandler:(id)sender
{
    _amountTF.text = @"";
    [delegate cancelTender];
    [self removeFromSuperview];
}
//去投标
- (IBAction)confirmBtnHandler:(id)sender
{
    [self toTender];
}

- (void)showOrHideRedPacketOption:(BOOL)bShow
{
    CGRect frame;
    CGRect ownFrame = self.frame;
    if(bShow)
    {
        if([_redPacketTF isHidden])
        {
            _redPacketTF.hidden = NO;
            _maskForRedPacketBtn.hidden = NO;
            frame = _redPacketTF.frame;
            frame.size.height = 45;
            _redPacketTF.frame = frame;
            _maskForRedPacketBtn.frame = frame;
            ownFrame.size.height += (45+8);
            self.frame = ownFrame;
        }
    }
    else
    {
        if(![_redPacketTF isHidden])
        {
            _redPacketTF.hidden = YES;
            _maskForRedPacketBtn.hidden = YES;
            frame = _redPacketTF.frame;
            frame.size.height = 0;
            _redPacketTF.frame = frame;
            _maskForRedPacketBtn.frame = frame;
            ownFrame.size.height -= (45+8);
            self.frame = ownFrame;
        }
    }
}

- (void)showOrHideTiYanJinOption:(BOOL)bShow
{
    CGRect frame;
    CGRect ownFrame = self.frame;
    if(bShow)
    {
        if([_tiyanjinTF isHidden])
        {
            _tiyanjinTF.hidden = NO;
            _maskForTiYanJinBtn.hidden = NO;
            frame = _tiyanjinTF.frame;
            frame.size.height = 45;
            _tiyanjinTF.frame = frame;
            _maskForTiYanJinBtn.frame = frame;
            ownFrame.size.height += (45+8);
            self.frame = ownFrame;
        }
    }
    else
    {
        if(![_tiyanjinTF isHidden])
        {
            _tiyanjinTF.hidden = YES;
            _maskForTiYanJinBtn.hidden = YES;
            frame = _tiyanjinTF.frame;
            frame.size.height = 0;
            _tiyanjinTF.frame = frame;
            _maskForTiYanJinBtn.frame = frame;
            ownFrame.size.height -= (45+8);
            self.frame = ownFrame;
        }
    }
}

- (void)showOrHidePasswordOption:(BOOL)bShow
{
    CGRect frame;
    CGRect ownFrame = self.frame;
    if(bShow)
    {
        if([_bgViewForPwd isHidden])
        {
            _bgViewForPwd.hidden = NO;
            frame = _bgViewForPwd.frame;
            frame.size.height = 45;
            _bgViewForPwd.frame = frame;
            ownFrame.size.height += (45+8);
            self.frame = ownFrame;
        }
    }
    else
    {
        if(![_bgViewForPwd isHidden])
        {
            _bgViewForPwd.hidden = YES;
            frame = _bgViewForPwd.frame;
            frame.size.height = 0;
            _bgViewForPwd.frame = frame;
            ownFrame.size.height -= (45+8);
            self.frame = ownFrame;
        }
    }
}

- (IBAction)btnDownHandler:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    [delegate showActivityList:btn.frame type:btn.tag];
}

- (void)setRedPacket:(NSString *)strActName
{
    _redPacketTF.text = strActName;
}

- (void)setTiYanJin:(NSString *)strActName
{
    _tiyanjinTF.text = strActName;
}

- (void)clearActivityId
{
    _redPacketId = @"";
    _tiYanJinId = @"";
}

#pragma mark BIDCustomKeyboardDelegate

- (void)dismissKeyboard
{
    [_amountTF resignFirstResponder];
}
/**
 *投标
 */
- (void)rechargeOrWithdrawal
{
    [self toTender];
}

#pragma mark - BIDActivityListViewDelegate
- (void)selectActivityForRedPacketWithName:(NSString *)actName activityId:(NSString *)activityId
{
    _redPacketTF.text = actName;
    _redPacketId = activityId;
}
- (void)selectActivityForTiYanJinWithName:(NSString *)actName activityId:(NSString *)activityId
{
    _tiyanjinTF.text = actName;
    _tiYanJinId = activityId;
}

@end

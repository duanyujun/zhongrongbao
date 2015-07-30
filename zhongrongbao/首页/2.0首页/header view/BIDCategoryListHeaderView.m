//
//  BIDCategoryListHeaderView.m
//  zhongrongbao
//
//  Created by mal on 15/6/25.
//  Copyright (c) 2015年 cnsoft. All rights reserved.
//

#import "BIDCategoryListHeaderView.h"

@implementation BIDCategoryListHeaderView
@synthesize delegate;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setAccount:(NSString *)strAccount
{
    _accountLabel.text = strAccount;
}

- (void)setBalance:(NSString *)strBalance
{
    _balanceLabel.text = strBalance;
}

- (void)setIncome:(NSString *)strIncome
{
    _incomeLabel.text = strIncome;
}

//0未登录 1已登录
- (void)setViewState:(int)state
{
    if(state==0)
    {
        _btn.hidden = NO;
        _accountLabel.hidden = YES;
    }
    else
    {
        _btn.hidden = YES;
        _accountLabel.hidden = NO;
    }
}

- (IBAction)btnDownHandler:(id)sender
{
    [delegate toLogin];
}

@end

//
//  BIDTenderDetailHeaderView.m
//  zhongrongbao
//
//  Created by mal on 15/7/1.
//  Copyright (c) 2015年 cnsoft. All rights reserved.
//

#import "BIDTenderDetailHeaderView.h"

@implementation BIDTenderDetailHeaderView
@synthesize creditLabel;
@synthesize creditLimitLabel;
@synthesize borrowNameLabel;
@synthesize borrowAmtLabel;
@synthesize canInvestAmtLabel;
@synthesize dateLabel;
@synthesize deadLineLabel;
@synthesize yearRateLabel;
@synthesize progressLabel;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)initView
{
    _flagView1.layer.cornerRadius = 5;
    _flagView1.clipsToBounds = YES;
    _flagView2.layer.cornerRadius = 5;
    _flagView2.clipsToBounds = YES;
    progressLabel.layer.cornerRadius = 5;
    progressLabel.clipsToBounds = YES;
}

@end

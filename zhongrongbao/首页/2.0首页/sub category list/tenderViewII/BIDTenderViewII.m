//
//  BIDTenderViewII.m
//  zhongrongbao
//
//  Created by mal on 15/6/30.
//  Copyright (c) 2015年 cnsoft. All rights reserved.
//

#import "BIDTenderViewII.h"

@implementation BIDTenderViewII
@synthesize borrowNameLabel;
@synthesize borrowAmtLabel;
@synthesize flagLabel;
@synthesize yearRateLabel;
@synthesize deadLineLabel;
@synthesize statusLabel;

@synthesize row;
@synthesize delegate;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)awakeFromNib
{
    flagLabel.layer.cornerRadius = 3;
    flagLabel.clipsToBounds = YES;
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
    [statusLabel addGestureRecognizer:tapGR];
}

- (void)tapGestureHandler:(UITapGestureRecognizer*)gr
{
    [delegate toTenderAtIndex:row];
}

- (void)setLabelStatus:(TENDER_STATUS)tenderStatus text:(NSString *)statusText
{
    UIColor *redColor = [UIColor colorWithRed:255.0f/255.0f green:57.0f/255.0f blue:66.0f/255.0f alpha:1.0f];
    UIColor *blueColor = [UIColor colorWithRed:38.0f/255.0f green:156.0f/255.0f blue:248.0f/255.0f alpha:1.0f];
    UIColor *grayColor = [UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f];
    NSString *strText = @"";
    UIColor *bgColor = nil;
    switch(tenderStatus)
    {
        case STATUS_TENDERRING:
        {
            //投标中
            strText = @"立即投标";
            bgColor = redColor;
        }
            break;
        case STATUS_FULL:
        {
            //满标中
            strText = @"满标";
            bgColor = blueColor;
        }
            break;
        case STATUS_REPAY:
        {
            //还款中
            strText = @"还款中";
            bgColor = blueColor;
        }
            break;
        case STATUS_REPAID:
        {
            //已还完
            strText = @"已完成";
            bgColor = grayColor;
        }
            break;
        case STATUS_READY:
        {
            //准备中
            strText = statusText;
            bgColor = redColor;
        }
            break;
        case STATUS_DISCARD:
        {
            //废弃
            strText = @"废弃";
            bgColor = grayColor;
        }
            break;
        case STATUS_LIUBIAO:
        {
            //流标
            strText = @"流标";
            bgColor = grayColor;
        }
            break;
        default:
        {}
    }
    statusLabel.text = strText;
    [statusLabel setBackgroundColor:bgColor];
}

@end

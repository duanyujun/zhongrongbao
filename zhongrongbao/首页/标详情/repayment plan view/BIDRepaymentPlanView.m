//
//  BIDRepaymentPlanView.m
//  zhongrongbao
//
//  Created by mal on 14-9-12.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDRepaymentPlanView.h"

/**
 *标题所在Label的宽度
 */
const CGFloat kTitleWidth = 100.0f;

@implementation BIDRepaymentPlanView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)initViewWithTitles:(NSArray *)titleArr infoArr:(NSArray *)infoArr
{
    int rows = titleArr.count;
    int columns = infoArr.count > 0?infoArr.count+1:5;
    CGFloat labelHeight = 21.0f;
    CGFloat labelWidth = 130.0f;
    UIColor *textColor = [UIColor colorWithRed:80.0f/255.0f green:96.0f/255.0f blue:109.0f/255.0f alpha:1.0f];
    CGRect labelFrame;
    UIFont *font = [UIFont systemFontOfSize:11.0f];
    CGFloat contentWidth = 0.0f;
    if(infoArr.count==0)
    {
        contentWidth = kTitleWidth + 4*labelWidth;
    }
    else
    {
        contentWidth = kTitleWidth + infoArr.count*labelWidth;
    }
    _myScrollView.scrollsToTop = NO;
    _myScrollView.showsHorizontalScrollIndicator = NO;
    [_myScrollView setContentSize:CGSizeMake(contentWidth, CGRectGetHeight(_myScrollView.frame))];
    for(int i=0; i<columns; i++)
    {
        for(int j=0; j<rows; j++)
        {
            UILabel *label = [[UILabel alloc] init];
            label.textAlignment = NSTextAlignmentCenter;
            [label setFont:font];
            [label setTextColor:textColor];
            if(i==0)
            {
                //第一列
                [label setText:titleArr[j]];
                [label setBackgroundColor:[UIColor colorWithRed:229.0f/255.0f green:231.0f/255.0f blue:230.0f/255.0f alpha:1.0f]];
                labelFrame = CGRectMake(0, j*labelHeight, kTitleWidth, labelHeight);
            }
            else
            {
                //其余列
                NSDictionary *dictionary = nil;
                if(infoArr.count>0)
                {
                    dictionary = infoArr[i-1];
                }
                
                NSString *strText = @"";
                if(dictionary!=nil)
                {
                    switch(j)
                    {
                        case 0:
                        {
                            //规定还款日期
                            strText = [dictionary objectForKey:@"repayDate"];
                        }
                            break;
                        case 1:
                        {
                            //实际还款日期
                            strText = [dictionary objectForKey:@"realRepayDate"];
                        }
                            break;
                        case 2:
                        {
                            //还款状态
                            strText = [dictionary objectForKey:@"repayStatusName"];
                        }
                            break;
                        case 3:
                        {
                            //还款类型
                            strText = [dictionary objectForKey:@"repayTypeName"];
                        }
                            break;
                        case 4:
                        {
                            //还款金额
                            strText = [[NSString alloc] initWithFormat:@"%@", [dictionary objectForKey:@"repayAmt"]];
                        }
                            break;
                        case 5:
                        {
                            //是否逾期
                            strText = [dictionary objectForKey:@"isLateName"];
                        }
                            break;
                        case 6:
                        {
                            //罚金
                            strText = [[NSString alloc] initWithFormat:@"%@", [dictionary objectForKey:@"receivableFine"]];
                        }
                            break;
                    }
                }
                [label setText:strText];
                labelFrame = CGRectMake(kTitleWidth+(i-1)*labelWidth, j*labelHeight, labelWidth, labelHeight);
            }
            label.frame = labelFrame;
            [_myScrollView addSubview:label];
        }
    }
    //添加分隔线
    for(int i=0; i<rows+1; i++)
    {
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, i*labelHeight, contentWidth, 1)];
        [lineLabel setBackgroundColor:[UIColor colorWithRed:216.0f/255.0f green:221.0f/255.0f blue:222.0f/255.0f alpha:1.0f]];
        [_myScrollView addSubview:lineLabel];
    }
}

@end

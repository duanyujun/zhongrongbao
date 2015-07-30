//
//  BIDRepaymentPlanView.m
//  zhongrongbao
//
//  Created by mal on 14-9-12.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDRepaymentPlanView.h"

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
    int columns = infoArr.count + 1;
    CGFloat labelHeight = 21.0f;
    CGFloat labelWidth = 112.0f;
    UIColor *textColor = [UIColor colorWithRed:80.0f/255.0f green:96.0f/255.0f blue:109.0f/255.0f alpha:1.0f];
    CGRect labelFrame;
    UIFont *font = [UIFont systemFontOfSize:13.0f];
    CGFloat contentWidth = 80 + infoArr.count*labelWidth;
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
                labelFrame = CGRectMake(0, j*labelHeight, 80.0f, labelHeight);
            }
            else
            {
                //其余列
                //NSDictionary *dictionary = infoArr[i-1];
                NSString *strText = @"";
                switch(j)
                {
                    case 0:
                    {
                        //序号
                        strText = @"1/2";
                    }
                        break;
                    case 1:
                    {
                        //还款日期
                        strText = @"2014-09-14";
                    }
                        break;
                    case 2:
                    {
                        //已还本息
                        strText = @"0.00";
                    }
                        break;
                    case 3:
                    {
                        //待还本息
                        strText = @"1000.00";
                    }
                        break;
                    case 4:
                    {
                        //已付罚息
                        strText = @"0.00";
                    }
                        break;
                    case 5:
                    {
                        //待还罚息
                        strText = @"0.00";
                    }
                        break;
                    case 6:
                    {
                        //状态
                        strText = @"未偿还";
                    }
                        break;
                }
                [label setText:strText];
                labelFrame = CGRectMake(80+(i-1)*labelWidth, j*labelHeight, labelWidth, labelHeight);
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

//
//  BIDFinancialStatusView.m
//  zhongrongbao
//
//  Created by mal on 14-9-11.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDFinancialStatusView.h"

@implementation BIDFinancialStatusView

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

/**
 *
 */
- (void)initViewWithArr:(NSArray*)arr
{
    int count = 10;
    CGFloat contentWidth = 90 + (count-1)*60;
    CGFloat labelHeight = 21.0f;
    UIColor *textColor = [UIColor colorWithRed:80.0f/255.0f green:96.0f/255.0f blue:109.0f/255.0f alpha:1.0f];
    UIFont *font = [UIFont systemFontOfSize:13.0f];
    [_myScrollView setContentSize:CGSizeMake(contentWidth, CGRectGetHeight(_myScrollView.frame))];
    _myScrollView.showsHorizontalScrollIndicator = NO;
    //创建label
    for(int i=0; i<arr.count; i++)
    {
        //
        for(int j=0; j<count; j++)
        {
            if(j==0)
            {
                //第一列
                UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, i*labelHeight, 90, labelHeight)];
                titleLabel.text = [[NSString alloc] initWithFormat:@"   %@", arr[i]];
                [titleLabel setFont:font];
                [titleLabel setTextColor:textColor];
                [titleLabel setBackgroundColor:[UIColor colorWithRed:229.0f/255.0f green:231.0f/255.0f blue:230.0f/255.0f alpha:1.0f]];
                [titleLabel setTextAlignment:NSTextAlignmentLeft];
                [_myScrollView addSubview:titleLabel];
            }
            else
            {
                UILabel *label;
                //最后一行
                if(i==arr.count-1)
                {
                    label = [[UILabel alloc] initWithFrame:CGRectMake(90, i*labelHeight, (count-1)*60, labelHeight)];
                    [label setText:@"   截止到7月底"];
                    [label setTextAlignment:NSTextAlignmentLeft];
                    [label setFont:font];
                    [label setTextColor:textColor];
                    [_myScrollView addSubview:label];
                    break;
                }
                else
                {
                    CGRect labelFrame;
                    label = [[UILabel alloc] init];
                    if(j==1)
                    {
                        labelFrame = CGRectMake(90, i*labelHeight, 60, labelHeight);
                    }
                    else
                    {
                        labelFrame = CGRectMake(90+(j-1)*60, i*labelHeight, 60, labelHeight);
                    }
                    label.frame = labelFrame;
                    [label setTextAlignment:NSTextAlignmentCenter];
                    if(i==0)
                    {
                        [label setText:[[NSString alloc] initWithFormat:@"%d", 2014-j+1]];
                    }
                    else
                    {
                        [label setText:@"1788"];
                    }
                }
                [label setFont:font];
                [label setTextColor:textColor];
                [_myScrollView addSubview:label];
            }
        }
    }
    //添加直线
    for(int i=0; i<arr.count+1; i++)
    {
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, i*labelHeight, contentWidth, 1)];
        [lineLabel setBackgroundColor:[UIColor colorWithRed:216.0f/255.0f green:221.0f/255.0f blue:222.0f/255.0f alpha:1.0f]];
        [_myScrollView addSubview:lineLabel];
    }
}

@end

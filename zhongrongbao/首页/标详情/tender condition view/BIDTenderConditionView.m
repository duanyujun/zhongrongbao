//
//  BIDTenderConditionView.m
//  zhongrongbao
//
//  Created by mal on 14-10-14.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDTenderConditionView.h"

@implementation BIDTenderConditionView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)initViewWithTitles:(NSArray *)titleArr infoArr:(NSArray *)infoArr
{
    NSArray *fieldsArr = @[@"investTime", @"userId", @"investAmt"];
    CGFloat topSpacing = 10.0f;
    CGFloat bottomSpacing = 10.0f;
    CGFloat leftSpacing = 10.0f;
    CGFloat rightSpacing = 10.0f;
    CGFloat firstColumnLabelWidth = 120.0f;
    CGFloat labelWidth = ([UIScreen mainScreen].bounds.size.width - leftSpacing - rightSpacing -firstColumnLabelWidth)/(titleArr.count-1);
    CGFloat lineWidth = [UIScreen mainScreen].bounds.size.width - leftSpacing - rightSpacing;
    CGFloat labelHeight = 21.0f;
    UIFont *titleFont = [UIFont systemFontOfSize:13.0f];
    UIFont *textFont = [UIFont systemFontOfSize:11.0f];
    UIColor *bgColor = [UIColor colorWithRed:229.0f/255.0f green:231.0f/255.0f blue:231.0f/255.0f alpha:1.0f];
    UIColor *viewBgColor = [UIColor colorWithRed:236.0f/255.0f green:240.0f/255.0f blue:241.0f/255.0f alpha:1.0f];
    UIColor *lineBgColor = [UIColor colorWithRed:214.0f/255.0f green:216.0f/255.0f blue:216.0f/255.0f alpha:1.0f];
    [self setBackgroundColor:viewBgColor];
    int rows = infoArr.count + 1;
    int columns = titleArr.count;
    for(int i=0; i<rows; i++)
    {
        for(int j=0; j<columns; j++)
        {
            UILabel *label = [[UILabel alloc] init];
            [self addSubview:label];
            [label setTextAlignment:NSTextAlignmentCenter];
            if(j==0)
            {
                label.frame = CGRectMake(leftSpacing, topSpacing+i*labelHeight, firstColumnLabelWidth, labelHeight);
            }
            else
            {
                label.frame = CGRectMake(leftSpacing+firstColumnLabelWidth+(j-1)*labelWidth, topSpacing+i*labelHeight, labelWidth, labelHeight);
            }
            if(i==0)
            {
                label.text = titleArr[j];
                label.font = titleFont;
            }
            else
            {
                NSDictionary *dictionary = infoArr[i-1];
                NSString *strField = fieldsArr[j];
                label.text = [dictionary objectForKey:strField];
                label.font = textFont;
            }
            if(i%2==0)
            {
                [label setBackgroundColor:bgColor];
                if(j==columns-1)
                {
                    UILabel *line1 = [[UILabel alloc] init];
                    line1.frame = CGRectMake(leftSpacing, CGRectGetMinY(label.frame), lineWidth, 1.0f);
                    UILabel *line2 = [[UILabel alloc] init];
                    line2.frame = CGRectMake(leftSpacing, CGRectGetMaxY(label.frame), lineWidth, 1.0f);
                    [line1 setBackgroundColor:lineBgColor];
                    [line2 setBackgroundColor:lineBgColor];
                    [self addSubview:line1];
                    [self addSubview:line2];
                }
            }
            else
            {
                [label setBackgroundColor:[UIColor clearColor]];
            }
        }
    }
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, topSpacing+bottomSpacing+(infoArr.count+1)*labelHeight);
}

@end

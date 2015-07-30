//
//  BIDCustomLabel.m
//  zhongrongbao
//
//  Created by mal on 15/6/29.
//  Copyright (c) 2015年 cnsoft. All rights reserved.
//

#import "BIDCustomLabel.h"

@implementation BIDCustomLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
{
    return CGRectMake(10, 0, bounds.size.width-10, bounds.size.height);
}

@end

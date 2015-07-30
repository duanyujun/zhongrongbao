//
//  BIDCustomTextField.m
//  zhongrongbao
//
//  Created by mal on 14-8-18.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDCustomTextField.h"

@implementation BIDCustomTextField

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

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectMake(10, 0, bounds.size.width-10, bounds.size.height);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectMake(10, 0, bounds.size.width-10, bounds.size.height);
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds
{
    return CGRectMake(10, 0, bounds.size.width-10, bounds.size.height);
}

@end

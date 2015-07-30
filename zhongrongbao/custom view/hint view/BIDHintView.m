//
//  BIDHintView.m
//  mashangban
//
//  Created by mal on 14-8-11.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDHintView.h"

@implementation BIDHintView
@synthesize msg;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor colorWithWhite:0.3 alpha:0.5]];
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [_label setTextAlignment:NSTextAlignmentCenter];
        [_label setFont:[UIFont systemFontOfSize:12.0f]];
        [_label setTextColor:[UIColor whiteColor]];
        [self addSubview:_label];
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

- (void)setMsg:(NSString *)msg1
{
    _label.text = msg1;
}

@end

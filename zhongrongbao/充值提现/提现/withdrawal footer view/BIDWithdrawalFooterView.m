//
//  BIDWithdrawalFooterView.m
//  zhongrongbao
//
//  Created by mal on 14-9-2.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDWithdrawalFooterView.h"
#import "BIDCommonMethods.h"

@implementation BIDWithdrawalFooterView
@synthesize hintLabel;

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
- (void)refreshFooterView:(NSString *)strHint
{
    CGFloat labelHeight = [BIDCommonMethods getHeightWithString:strHint font:hintLabel.font constraintSize:CGSizeMake(CGRectGetWidth(hintLabel.frame), MAXFLOAT)];
    hintLabel.numberOfLines = 0;
    CGRect labelFrame = hintLabel.frame;
    labelFrame.size.height = labelHeight;
    hintLabel.frame = labelFrame;
    hintLabel.text = strHint;
    CGRect frame = self.frame;
    frame.size.height = CGRectGetMaxY(hintLabel.frame) + 8;
    self.frame = frame;
}

@end

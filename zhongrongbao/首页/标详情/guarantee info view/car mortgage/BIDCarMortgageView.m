//
//  BIDCarMortgageView.m
//  zhongrongbao
//
//  Created by mal on 14-9-11.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDCarMortgageView.h"

@implementation BIDCarMortgageView
@synthesize vehicleTypeLabel;
@synthesize boughtDateLabel;
@synthesize assessedValueLabel;
@synthesize referenceValueLabel;

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

- (void)initView
{
    _titleLabel.layer.cornerRadius = 3;
}

@end

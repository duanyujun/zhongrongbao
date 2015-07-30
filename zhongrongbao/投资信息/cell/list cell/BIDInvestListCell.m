//
//  BIDInvestListCell.m
//  zhongrongbao
//
//  Created by mal on 14-10-15.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDInvestListCell.h"

@implementation BIDInvestListCell
@synthesize titleLabel;
@synthesize amountLabel;
@synthesize dateLabel;
@synthesize flagLabel;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

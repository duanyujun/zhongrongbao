//
//  BIDCustomCell.m
//  zhongrongbao
//
//  Created by mal on 14-9-10.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDCustomCell.h"

@implementation BIDCustomCell
@synthesize titleLabel;
@synthesize contentLabel;
@synthesize lineLabel;

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

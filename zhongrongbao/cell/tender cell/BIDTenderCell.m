//
//  BIDTenderCell.m
//  zhongrongbao
//
//  Created by mal on 14-8-14.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDTenderCell.h"

@implementation BIDTenderCell

@synthesize myContentView;

- (void)awakeFromNib
{
    // Initialization code
    myContentView.layer.cornerRadius = 5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

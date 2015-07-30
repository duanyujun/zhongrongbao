//
//  BIDCategoryCell.m
//  zhongrongbao
//
//  Created by mal on 15/6/25.
//  Copyright (c) 2015年 cnsoft. All rights reserved.
//

#import "BIDCategoryCell.h"

@implementation BIDCategoryCell
@synthesize bgColor;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    [self.contentView setBackgroundColor:bgColor];
}
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    [self.contentView setBackgroundColor:bgColor];
}

@end

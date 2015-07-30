//
//  BIDMsgCell.m
//  zhongrongbao
//
//  Created by mal on 14/12/26.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDMsgCell.h"

@implementation BIDMsgCell
@synthesize imgView;
@synthesize titleLabel;
@synthesize dateLabel;
@synthesize contentLabel;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

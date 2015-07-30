//
//  BIDBankCardInfoView.m
//  zhongrongbao
//
//  Created by mal on 15/6/28.
//  Copyright (c) 2015年 cnsoft. All rights reserved.
//

#import "BIDBankCardInfoView.h"

@implementation BIDBankCardInfoView
@synthesize delegate;
@synthesize row;
@synthesize bankImgView;
@synthesize bankCardNumberLabel;
@synthesize removeBindingBtn;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)btnDownHandler:(id)sender
{
    [delegate removeBinding:self.row];
}

@end

//
//  BIDPreviewImgView.m
//  zhongrongbao
//
//  Created by mal on 15/7/3.
//  Copyright (c) 2015年 cnsoft. All rights reserved.
//

#import "BIDPreviewImgView.h"
#import "BIDScrollViewWithImage.h"

@implementation BIDPreviewImgView
@synthesize scrollViewWithImg;
@synthesize spinnerView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        scrollViewWithImg = [[BIDScrollViewWithImage alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        [self addSubview:scrollViewWithImg];
        spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        spinnerView.center = CGPointMake(self.center.x, self.center.y);
        spinnerView.hidesWhenStopped = YES;
        [spinnerView startAnimating];
        [self addSubview:spinnerView];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

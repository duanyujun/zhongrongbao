//
//  BIDGuaranteeInfoView.m
//  zhongrongbao
//
//  Created by mal on 14-9-11.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDGuaranteeInfoView.h"
#import "BIDCarMortgageView.h"
#import "BIDRoomMortgageView.h"

@implementation BIDGuaranteeInfoView
@synthesize securedPartyLabel;
@synthesize guaranteeLabel;
@synthesize doubleGuaranteeLabel;
@synthesize btn;
@synthesize imgView;
@synthesize delegate;

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
    _carMortgageView = (BIDCarMortgageView*)[[[NSBundle mainBundle] loadNibNamed:@"BIDCarMortgageView" owner:self options:nil] lastObject];
    [_carMortgageView initView];
    _roomMortgageView = (BIDRoomMortgageView*)[[[NSBundle mainBundle] loadNibNamed:@"BIDRoomMortgageView" owner:self options:nil] lastObject];
    [_roomMortgageView initView];
    //
    CGRect frame = CGRectMake(0, CGRectGetMaxY(btn.frame), CGRectGetWidth(_carMortgageView.frame), CGRectGetHeight(_carMortgageView.frame));
    _carMortgageView.frame = frame;
    //
    frame = CGRectMake(0, CGRectGetMaxY(_carMortgageView.frame), CGRectGetWidth(_roomMortgageView.frame), CGRectGetHeight(_roomMortgageView.frame));
    _roomMortgageView.frame = frame;
}

- (IBAction)btnDownHandler:(id)sender
{
    if(!_bExpanded)
    {
        //展开
        _bExpanded = YES;
        [btn setTitle:@"收起" forState:UIControlStateNormal];
        imgView.transform = CGAffineTransformMakeRotation(M_PI);

        [self addSubview:_carMortgageView];
        //

        [self addSubview:_roomMortgageView];
        //
        CGRect ownFrame = self.frame;
        ownFrame.size.height += CGRectGetHeight(_carMortgageView.frame) + CGRectGetHeight(_roomMortgageView.frame);
        self.frame = ownFrame;
    }
    else
    {
        //收起
        _bExpanded = NO;
        [btn setTitle:@"更多担保信息" forState:UIControlStateNormal];
        imgView.transform = CGAffineTransformMakeRotation(M_PI*2);
        [_carMortgageView removeFromSuperview];
        [_roomMortgageView removeFromSuperview];
        CGRect ownFrame = self.frame;
        ownFrame.size.height -= (CGRectGetHeight(_carMortgageView.frame) + CGRectGetHeight(_roomMortgageView.frame));
        self.frame = ownFrame;
    }
    CGRect lineLabelFrame = _lineLabel.frame;
    lineLabelFrame.origin.y = self.frame.size.height - 1;
    _lineLabel.frame = lineLabelFrame;
    [delegate refreshGuaranteeInfoView];
}

@end

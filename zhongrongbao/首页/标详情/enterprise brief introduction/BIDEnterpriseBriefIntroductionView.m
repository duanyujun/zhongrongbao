//
//  BIDEnterpriseBriefIntroductionView.m
//  zhongrongbao
//
//  Created by mal on 14-9-10.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDEnterpriseBriefIntroductionView.h"
#import "BIDCommonMethods.h"

@interface BIDEnterpriseBriefIntroductionView()
{
    BOOL _bExpanded;
}

@end

@implementation BIDEnterpriseBriefIntroductionView
@synthesize contentLabel;
@synthesize imgView;
@synthesize btn;
@synthesize delegate;
@synthesize lineLabel;
@synthesize section;
@synthesize row;

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

- (void)setEnterpriseBriefIntroduction:(NSString *)enterpriseBriefIntroduction
{
    [lineLabel setBackgroundColor:[UIColor colorWithRed:24.0f/255.0f green:152.0f/255.0f blue:214.0f/255.0f alpha:1.0f]];
    _wholeIntroduction = enterpriseBriefIntroduction;
    _partialIntroduction = enterpriseBriefIntroduction;
    contentLabel.numberOfLines = 0;
    if(enterpriseBriefIntroduction.length>200)
    {
        _partialIntroduction = [[NSString alloc] initWithFormat:@"%@...", [enterpriseBriefIntroduction substringWithRange:NSMakeRange(0, 200)]];
        contentLabel.text = _partialIntroduction;
    }
    else
    {
        contentLabel.text = _wholeIntroduction;
    }
    [self setLayout];
}

- (IBAction)btnDownHandler:(id)sender
{
    //没有展开
    if(!_bExpanded)
    {
        _bExpanded = YES;
        [btn setTitle:@"收起" forState:UIControlStateNormal];
        imgView.transform = CGAffineTransformMakeRotation(M_PI);
        contentLabel.text = _wholeIntroduction;
    }
    else
    {
        _bExpanded = NO;
        [btn setTitle:@"展开全部" forState:UIControlStateNormal];
        imgView.transform = CGAffineTransformMakeRotation(M_PI*2);
        contentLabel.text = _partialIntroduction;
    }
    [self setLayout];
    [delegate refreshEnterpriseBriefIntroduction:section row:row];
}

/**
 *根据内容多少调整视图布局
 */
- (void)setLayout
{
    NSString *str = contentLabel.text;
    CGFloat labelHeight = [BIDCommonMethods getHeightWithString:str font:contentLabel.font constraintSize:CGSizeMake(self.frame.size.width-28, MAXFLOAT)];
    CGRect labelFrame = contentLabel.frame;
    labelFrame.size.height = labelHeight;
    contentLabel.frame = labelFrame;
    CGRect btnFrame = btn.frame;
    btnFrame.origin.y = CGRectGetMaxY(contentLabel.frame)+15.0f;
    btn.frame = btnFrame;
    imgView.center = CGPointMake(imgView.center.x, btn.center.y);
    CGRect ownFrame = self.frame;
    ownFrame.size.height = CGRectGetMaxY(btn.frame) + 15;
    self.frame = ownFrame;
//    CGRect lineFrame = lineLabel.frame;
//    lineFrame.origin.y = ownFrame.size.height-1;
//    lineLabel.frame = lineFrame;
}

@end

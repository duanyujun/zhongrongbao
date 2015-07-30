//
//  BIDEnterpriseInfoView.m
//  zhongrongbao
//
//  Created by mal on 14-9-10.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDEnterpriseInfoView.h"
#import "BIDCommonMethods.h"

@implementation BIDEnterpriseInfoView
@synthesize registerYearsLabel;
@synthesize registerCapitalLabel;
@synthesize netAssetValueLabel;
@synthesize industryLabel;
@synthesize cashInflowsLabel;
@synthesize operatingConditionLabel;
@synthesize lawsuitConditionLabel;
@synthesize creditRegistriesLabel;
@synthesize lineLabel;
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

/**
 *经营情况
 */
- (void)setOperatingCondition:(NSString *)operatingCondition
{
    [lineLabel setBackgroundColor:[UIColor colorWithRed:24.0f/255.0f green:152.0f/255.0f blue:214.0f/255.0f alpha:1.0f]];
    _wholeOperatingCondition = operatingCondition;
    operatingConditionLabel.numberOfLines = 0;
    if(operatingCondition.length>200)
    {
        _partialOperatingCondition = [[NSString alloc] initWithFormat:@"%@...", [operatingCondition substringWithRange:NSMakeRange(0, 200)]];
        operatingConditionLabel.text = _partialOperatingCondition;
    }
    else
    {
        operatingConditionLabel.text = _wholeOperatingCondition;
    }
    //
    NSString *str = operatingConditionLabel.text;
    CGFloat labelHeight = [BIDCommonMethods getHeightWithString:str font:operatingConditionLabel.font constraintSize:CGSizeMake(self.frame.size.width-14*2, MAXFLOAT)];
    CGRect labelFrame = operatingConditionLabel.frame;
    labelFrame.size.height = labelHeight;
    operatingConditionLabel.frame = labelFrame;
}
/**
 *涉诉情况
 */
- (void)setLawsuitCondition:(NSString *)lawsuitCondition
{
    _lawsuitCondition = lawsuitCondition;
    self.lawsuitConditionLabel.text = lawsuitCondition;
    self.lawsuitConditionLabel.numberOfLines = 0;
    //
    CGFloat labelHeight = [BIDCommonMethods getHeightWithString:lawsuitCondition font:lawsuitConditionLabel.font constraintSize:CGSizeMake(self.frame.size.width-14*2, MAXFLOAT)];
    CGRect labelFrame = lawsuitConditionLabel.frame;
    labelFrame.size.height = labelHeight;
    lawsuitConditionLabel.frame = labelFrame;
}
/**
 *征信记录
 */
- (void)setCreditRegistries:(NSString *)creditRegistries
{
    _creditRegistries = creditRegistries;
    self.creditRegistriesLabel.text = creditRegistries;
    self.creditRegistriesLabel.numberOfLines = 0;
    //
    CGFloat labelHeight = [BIDCommonMethods getHeightWithString:creditRegistries font:creditRegistriesLabel.font constraintSize:CGSizeMake(self.frame.size.width-14*2, MAXFLOAT)];
    CGRect labelFrame = creditRegistriesLabel.frame;
    labelFrame.size.height = labelHeight;
    creditRegistriesLabel.frame = labelFrame;
}

- (IBAction)btnDownHandler:(id)sender
{
    //没有展开
    if(!_bExpanded)
    {
        _bExpanded = YES;
        [btn setTitle:@"收起" forState:UIControlStateNormal];
        imgView.transform = CGAffineTransformMakeRotation(M_PI);
        operatingConditionLabel.text = _wholeOperatingCondition;
    }
    else
    {
        _bExpanded = NO;
        [btn setTitle:@"展开全部" forState:UIControlStateNormal];
        imgView.transform = CGAffineTransformMakeRotation(M_PI*2);
        operatingConditionLabel.text = _partialOperatingCondition;
    }
    NSString *str = operatingConditionLabel.text;
    CGFloat labelHeight = [BIDCommonMethods getHeightWithString:str font:operatingConditionLabel.font constraintSize:CGSizeMake(self.frame.size.width-14*2, MAXFLOAT)];
    CGRect labelFrame = operatingConditionLabel.frame;
    labelFrame.size.height = labelHeight;
    operatingConditionLabel.frame = labelFrame;
    //
    [self setLayout];
    [delegate refreshEnterpriseInfo];
}

/**
 *调整view布局
 */
- (void)setLayout
{
    CGRect btnFrame = btn.frame;
    btnFrame.origin.y = CGRectGetMaxY(operatingConditionLabel.frame) + 15.0f;
    btn.frame = btnFrame;
    imgView.center = CGPointMake(imgView.center.x, btn.center.y);
    //涉诉情况
    CGRect titleLabelFrame = _lawsuitTitleLabel.frame;
    titleLabelFrame.origin.y = CGRectGetMaxY(btn.frame) + 15.0f;
    _lawsuitTitleLabel.frame = titleLabelFrame;
    CGRect labelFrame = lawsuitConditionLabel.frame;
    labelFrame.origin.y = CGRectGetMaxY(_lawsuitTitleLabel.frame) + 5.0f;
    lawsuitConditionLabel.frame = labelFrame;
    //征信记录
    titleLabelFrame = _creditTitleLabel.frame;
    titleLabelFrame.origin.y = CGRectGetMaxY(lawsuitConditionLabel.frame) + 15.0f;
    _creditTitleLabel.frame = titleLabelFrame;
    labelFrame = creditRegistriesLabel.frame;
    labelFrame.origin.y = CGRectGetMaxY(_creditTitleLabel.frame) + 5.0f;
    creditRegistriesLabel.frame = labelFrame;
    //视图高度
    CGRect ownFrame = self.frame;
    ownFrame.size.height = CGRectGetMaxY(creditRegistriesLabel.frame) + 20.0f;
    self.frame = ownFrame;
    //分隔线
    CGRect lineLabelFrame = lineLabel.frame;
    lineLabelFrame.origin.y = ownFrame.size.height;
    lineLabel.frame = lineLabelFrame;
}

@end

//
//  BIDTenderView.m
//  zhongrongbao
//
//  Created by mal on 14-8-14.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDTenderView.h"

@implementation BIDTenderView
@synthesize tenderProgress;
@synthesize tenderProgressLabel;
@synthesize tenderStateLabel;
@synthesize financingAmountLabel;
@synthesize amountNameLable;
@synthesize incomeRateLabel;
@synthesize deadLineLabel;
@synthesize rightTopImgView;
@synthesize rightBottomImgView;
@synthesize companyNameLabel;
@synthesize creditLabel;
@synthesize bInPayment;
@synthesize amountUnitsLabel;
@synthesize publishTenderDateLabel;
@synthesize tenderStatus;
@synthesize tenderStatusLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // 不同屏幕有不同的值
    CGFloat radius = 48.5f;
    CGFloat lineWidth = 8.0f;
    CGPoint centerPt = CGPointMake(78.5f, 77.5f);
    CGPoint leftTopPt = CGPointMake(26.0f, 25.0f);
    if([UIScreen mainScreen].bounds.size.height>=568)
    {
        radius = 48.5f;
        lineWidth = 8.0f;
        centerPt = CGPointMake(78.5f, 77.5f);
        leftTopPt = CGPointMake(26.0f, 25.0f);
    }
    else
    {
        radius = 39.0f;
        lineWidth = 8.0f;
        centerPt = CGPointMake(71.5f, 62.0f);
        leftTopPt = CGPointMake(28.5f, 19.0f);
    }
    //
    UIColor *blueColor = [UIColor colorWithRed:52.0f/255.0f green:152.0f/255.0f blue:219.0f/255.0f alpha:1.0f];
    UIColor *grayColor = [UIColor colorWithRed:236.0f/255.0f green:240.0f/255.0f blue:241.0f/255.0f alpha:1.0f];
    //UIColor *redColor = [UIColor colorWithRed:231.0f/255.0f green:76.0f/255.0f blue:60.0f/255.0f alpha:1.0f];
    CGContextRef context = UIGraphicsGetCurrentContext();
    switch(tenderStatus)
    {
        case STATUS_TENDERRING:
        {
            //投标中
            CGContextSetLineWidth(context, lineWidth);
            CGContextSetStrokeColorWithColor(context, grayColor.CGColor);
            CGContextAddEllipseInRect(context, CGRectMake(leftTopPt.x, leftTopPt.y, (radius+lineWidth/2)*2, (radius+lineWidth/2)*2));
            CGContextStrokePath(context);
            CGContextSetLineWidth(context, lineWidth);
            CGContextSetStrokeColorWithColor(context, blueColor.CGColor);
            CGContextAddArc(context, centerPt.x, centerPt.y, radius+lineWidth/2, -M_PI_2, 2*M_PI*tenderProgress-M_PI_2, 0);
            CGContextStrokePath(context);
        }
            break;
        case STATUS_REPAID:
        case STATUS_TRANSFER:
        case STATUS_REPAY:
        case STATUS_FULL:
        case STATUS_PUBLISHING:
        {
            //满标
            CGContextSetLineWidth(context, 1);
            CGContextSetStrokeColorWithColor(context, blueColor.CGColor);
            CGContextAddEllipseInRect(context, CGRectMake(leftTopPt.x-lineWidth/2, leftTopPt.y-lineWidth/2, (radius+lineWidth)*2, (radius+lineWidth)*2));
            CGContextAddEllipseInRect(context, CGRectMake(leftTopPt.x+lineWidth/2, leftTopPt.y+lineWidth/2, radius*2, radius*2));
            CGContextStrokePath(context);
            //
            CGContextSetFillColorWithColor(context, blueColor.CGColor);
            CGContextAddEllipseInRect(context, CGRectMake(leftTopPt.x+lineWidth/2, leftTopPt.y+lineWidth/2, radius*2, radius*2));
            CGContextFillPath(context);
        }
            break;
//        case STATUS_REPAY:
//        {
//            //还款中
//            CGContextSetLineWidth(context, lineWidth);
//            CGContextSetStrokeColorWithColor(context, blueColor.CGColor);
//            CGContextAddEllipseInRect(context, CGRectMake(leftTopPt.x, leftTopPt.y, (radius+lineWidth/2)*2, (radius+lineWidth/2)*2));
//            CGContextStrokePath(context);
//            //
//            CGPoint startPt = CGPointMake(cos(M_PI/6)*radius+centerPt.x, sin(M_PI/6)*radius+centerPt.y);
//            CGPoint endPt = CGPointMake(cos(M_PI*5/6)*radius+centerPt.x, sin(M_PI*5/6)*radius+centerPt.y);
//            CGPoint cpt1 = CGPointMake(startPt.x-25, startPt.y+20);
//            CGPoint cpt2 = CGPointMake(endPt.x+25, endPt.y-20);
//            CGPoint cpt3 = CGPointMake(centerPt.x, centerPt.y+radius+radius/6*5);
//            CGContextSetLineWidth(context, 1);
//            CGContextSetFillColorWithColor(context, blueColor.CGColor);
//            CGContextMoveToPoint(context, startPt.x, startPt.y);
//            CGContextAddCurveToPoint(context, cpt1.x, cpt1.y, cpt2.x, cpt2.y, endPt.x, endPt.y);
//            CGContextAddQuadCurveToPoint(context, cpt3.x, cpt3.y, startPt.x, startPt.y);
//            CGContextFillPath(context);
//        }
//            break;
//        case STATUS_TRANSFER:
//        {
//            //债权转让中
//            CGContextSetLineWidth(context, lineWidth);
//            CGContextSetStrokeColorWithColor(context, redColor.CGColor);
//            CGContextAddEllipseInRect(context, CGRectMake(leftTopPt.x, leftTopPt.y, (radius+lineWidth/2)*2, (radius+lineWidth/2)*2));
//            CGContextStrokePath(context);
//            //
//            CGPoint startPt = CGPointMake(cos(M_PI/6)*radius+centerPt.x, sin(M_PI/6)*radius+centerPt.y);
//            CGPoint endPt = CGPointMake(cos(M_PI*5/6)*radius+centerPt.x, sin(M_PI*5/6)*radius+centerPt.y);
//            CGPoint cpt1 = CGPointMake(startPt.x-25, startPt.y+20);
//            CGPoint cpt2 = CGPointMake(endPt.x+25, endPt.y-20);
//            CGPoint cpt3 = CGPointMake(centerPt.x, centerPt.y+radius+radius/6*5);
//            CGContextSetLineWidth(context, 1);
//            CGContextSetFillColorWithColor(context, redColor.CGColor);
//            CGContextMoveToPoint(context, startPt.x, startPt.y);
//            CGContextAddCurveToPoint(context, cpt1.x, cpt1.y, cpt2.x, cpt2.y, endPt.x, endPt.y);
//            CGContextAddQuadCurveToPoint(context, cpt3.x, cpt3.y, startPt.x, startPt.y);
//            CGContextFillPath(context);
//        }
//            break;
//        case STATUS_REPAID:
//        {
//            //已还完
//            CGContextSetLineWidth(context, 1);
//            CGContextSetStrokeColorWithColor(context, blueColor.CGColor);
//            CGContextAddEllipseInRect(context, CGRectMake(leftTopPt.x-lineWidth/2, leftTopPt.y-lineWidth/2, (radius+lineWidth)*2, (radius+lineWidth)*2));
//            CGContextAddEllipseInRect(context, CGRectMake(leftTopPt.x+lineWidth/2, leftTopPt.y+lineWidth/2, radius*2, radius*2));
//            CGContextStrokePath(context);
//            //
//            CGContextSetFillColorWithColor(context, blueColor.CGColor);
//            CGContextAddEllipseInRect(context, CGRectMake(leftTopPt.x+lineWidth/2, leftTopPt.y+lineWidth/2, radius*2, radius*2));
//            CGContextFillPath(context);
//        }
//            break;
    }
}

- (void)refresh
{
    if([UIScreen mainScreen].bounds.size.height>=568.0f)
    {
        [self setNeedsDisplayInRect:CGRectMake(17, 17, 123, 123)];
    }
    else
    {
        [self setNeedsDisplayInRect:CGRectMake(10, 10, 123, 123)];
    }
}

- (void)initView
{
    _bgView.layer.cornerRadius = 3;
    _bgView.layer.masksToBounds = YES;
    _flagLabel1.layer.cornerRadius = 3;
    _flagLabel2.layer.cornerRadius = 3;
}

- (void)setMortgageFlag:(NSString *)strType
{
     _flagLabel1.hidden = NO;
    if([strType isEqualToString:@"01"])
    {
        //个人经营贷
        _flagLabel1.text = @"个人";
        [_flagLabel1 setBackgroundColor:[UIColor colorWithRed:52.0f/255.0f green:152.0f/255.0f blue:219.0f/255.0f alpha:1.0f]];
    }
    else if([strType isEqualToString:@"02"])
    {
        //房产抵押贷
        _flagLabel1.text = @"房押";
        [_flagLabel1 setBackgroundColor:[UIColor colorWithRed:231.0f/255.0f green:76.0f/255.0f blue:60.0f/255.0f alpha:1.0f]];
    }
    else if([strType isEqualToString:@"03"])
    {
        //车辆抵押贷
        _flagLabel1.text = @"车押";
        [_flagLabel1 setBackgroundColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
    }
    else if([strType isEqualToString:@"04"])
    {
        //车房押
        _flagLabel1.text = @"车*房";
        [_flagLabel1 setBackgroundColor:[UIColor colorWithRed:52.0f/255.0f green:152.0f/255.0f blue:219.0f/255.0f alpha:1.0f]];
    }
    else if([strType isEqualToString:@"05"])
    {
        //其他
        _flagLabel1.text = @"其他";
        [_flagLabel1 setBackgroundColor:[UIColor colorWithRed:52.0f/255.0f green:152.0f/255.0f blue:219.0f/255.0f alpha:1.0f]];
    }
    else
    {
        //其他贷款
        _flagLabel1.hidden = YES;
    }
}

@end

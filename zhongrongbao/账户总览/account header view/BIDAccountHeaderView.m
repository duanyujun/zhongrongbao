//
//  BIDAccountHeaderView.m
//  zhongrongbao
//
//  Created by mal on 14-8-26.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDAccountHeaderView.h"
#import "BIDAttachedView.h"

@interface BIDAccountHeaderView()
{
    BIDAttachedView *_attachedView;
}
@end

@implementation BIDAccountHeaderView
@synthesize usernameLabel;
@synthesize accountLabel;

@synthesize totalAssetsLabel;
@synthesize balanceLabel;
@synthesize frozenLabel;
@synthesize totalAccountLabel;
@synthesize totalAccountFlagLabel;
@synthesize descriptionLabel;
@synthesize accumulatedTenderLabel;
@synthesize accumulatedIncomeLabel;
@synthesize rate;
@synthesize totalAmount;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)initView
{
    CGFloat cornerRadius = _flagLabel1.frame.size.width/2;
    _flagLabel1.layer.cornerRadius = cornerRadius;
    _flagLabel2.layer.cornerRadius = cornerRadius;
    _flagLabel3.layer.cornerRadius = cornerRadius;
    _flagLabel4.layer.cornerRadius = cornerRadius;
    _flagLabel5.layer.cornerRadius = cornerRadius;
    
    _attachedView = [[BIDAttachedView alloc] init];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
    totalAccountLabel.userInteractionEnabled = YES;
    [totalAccountLabel addGestureRecognizer:tapGesture];
}

- (void)tapGestureHandler:(UITapGestureRecognizer*)gestureRecognizer
{
    [_attachedView setContent:totalAmount textColor:[UIColor darkGrayColor]];
    _attachedView.center = CGPointMake(totalAccountLabel.center.x, 0);
    CGRect frame = _attachedView.frame;
    frame.origin.y = CGRectGetMaxY(totalAccountLabel.frame);
    _attachedView.frame = frame;
    _attachedView.alpha = 1.0f;
    [self addSubview:_attachedView];
    [UIView animateWithDuration:2.0f animations:^{
        _attachedView.alpha = 0.0f;
    } completion:^(BOOL finished){
        [_attachedView removeFromSuperview];
    }];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGRect desRect = CGRectMake(180, 22, 134, 134);
    //圆形的中心点
    CGPoint centerPt = CGPointMake(desRect.origin.x+desRect.size.width/2, desRect.origin.y+desRect.size.height/2);
    CGFloat bigLineWidth = 10;
    CGFloat smallLineWidth = 4;
    CGFloat bigRadius = desRect.size.width/2 - bigLineWidth/2;
    CGFloat smallRadius = bigRadius - bigLineWidth/2 - smallLineWidth/2;
    //
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, smallLineWidth);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:193.0f/255.0f green:193.0f/255.0f blue:193.0f/255.0f alpha:1.0f].CGColor);
    CGContextAddEllipseInRect(context, CGRectMake(centerPt.x-smallRadius, centerPt.y-smallRadius, smallRadius*2, smallRadius*2));
    CGContextStrokePath(context);
    //
    CGContextSetLineWidth(context, bigLineWidth);
    UIColor *blackColor = [UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f];
    UIColor *blueColor = [UIColor colorWithRed:40.0f/255.0f green:153.0f/255.0f blue:213.0f/255.0f alpha:1.0f];
    CGContextSetStrokeColorWithColor(context, blueColor.CGColor);
    CGContextAddArc(context, centerPt.x, centerPt.y, bigRadius, 0, 2*M_PI, 0);
    CGContextStrokePath(context);
    //
    CGContextSetLineWidth(context, bigLineWidth);
    CGContextSetStrokeColorWithColor(context, blackColor.CGColor);
    CGContextAddArc(context, centerPt.x, centerPt.y, bigRadius, -M_PI_2, 2*M_PI*rate-M_PI_2, 0);
    CGContextStrokePath(context);
}

- (void)refreshView
{
    CGRect refreshRect = CGRectMake(180, 22, 134, 134);
    [self setNeedsDisplayInRect:refreshRect];
}

- (void)showHintMsgLabel
{
    _hintLabel1.hidden = YES;
    _hintLabel2.hidden = NO;
    _hintLabel3.hidden = YES;
}

- (void)hideHintMsgLabel
{
    _hintLabel1.hidden = NO;
    _hintLabel2.hidden = YES;
    _hintLabel3.hidden = NO;
}

@end

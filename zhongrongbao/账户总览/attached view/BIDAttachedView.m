//
//  BIDAttachedView.m
//  zhongrongbao
//
//  Created by mal on 14-10-9.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDAttachedView.h"
#import "BIDCommonMethods.h"
#import <CoreText/CoreText.h>

const CGFloat kTriangleHeight = 3.0f;
const CGFloat kTriangleWidth = 5.0f;
const CGFloat kLabelHeight = 20.0f;
const CGFloat kViewBaseWidth = 60.0f;
const CGFloat kFontSize = 15.0f;

@interface BIDAttachedView()
{
    UILabel *_label;
    UIColor *_bgColor;
}

@end
@implementation BIDAttachedView

- (id)init
{
    if(self=[super init])
    {
        [self setBackgroundColor:[UIColor clearColor]];
        self.layer.masksToBounds = YES;
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
        [_label setBackgroundColor:[UIColor clearColor]];
        [_label setTextColor:[UIColor whiteColor]];
        [_label setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_label];
    }
    return self;
}

- (void)setContent:(NSString *)strContent textColor:(UIColor *)color
{
    CGFloat viewHeight = kLabelHeight + kTriangleHeight;
    UIFont *font = [UIFont systemFontOfSize:kFontSize];
    strContent = [[NSString alloc] initWithFormat:@"%@ 元", strContent];
    NSUInteger viewWidth = [BIDCommonMethods getWidthWithString:strContent font:font constraintSize:CGSizeMake(MAXFLOAT, viewHeight)];
    viewWidth = viewWidth>kViewBaseWidth?viewWidth:kViewBaseWidth;
    self.frame = CGRectMake(0, 0, viewWidth, viewHeight);
    _label.frame = CGRectMake(0, kTriangleHeight, viewWidth, kLabelHeight);
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:strContent];
    [attributeString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:kFontSize] range:NSMakeRange(0, strContent.length-2)];
    [attributeString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:8.0f] range:NSMakeRange(strContent.length-1, 1)];
    NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
    [ps setAlignment:NSTextAlignmentCenter];
    //[attributeString addAttribute:NSParagraphStyleAttributeName value:ps range:NSMakeRange(0, strContent.length)];
    //[_label setText:strContent];
    _label.attributedText = attributeString;
    _bgColor = color;
    [self setNeedsDisplay];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGFloat viewWidth = rect.size.width;
    CGPoint centerPt = CGPointMake(viewWidth/2, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, _bgColor.CGColor);
    CGContextMoveToPoint(context, 0, kTriangleHeight);
    CGContextAddLineToPoint(context, centerPt.x-kTriangleWidth/2, kTriangleHeight);
    CGContextAddLineToPoint(context, centerPt.x, 0);
    CGContextAddLineToPoint(context, centerPt.x+kTriangleWidth/2, kTriangleHeight);
    CGContextAddLineToPoint(context, viewWidth, kTriangleHeight);
    CGContextAddLineToPoint(context, viewWidth, kTriangleHeight+kLabelHeight);
    CGContextAddLineToPoint(context, 0, kTriangleHeight+kLabelHeight);
    CGContextAddLineToPoint(context, 0, kTriangleHeight);
    CGContextFillPath(context);
}

- (void)tapGestureHandler:(UIGestureRecognizer*)gestureRecognizer
{
    [self removeFromSuperview];
}

@end

//
//  BIDLockViewForLogin.m
//  mashangban
//
//  Created by mal on 14-8-11.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDLockViewForLogin.h"
#import "BIDCommonMethods.h"

/**
 *左边间距
 */
static const CGFloat leftSpacing = 25.0f;
/**
 *右边间距
 */
//static const CGFloat rightSpacing = 35.0f;
/**
 *上边间距
 */
static const CGFloat topSpacing = 0.0f;
/**
 *按钮半径
 */
static const CGFloat radius = 35.0f;
/**
 *小圆半径
 */
static const CGFloat smallRadius = radius/3;
/**
 *水平间距
 */
static const CGFloat itemSpacing =  30.0f;
/**
 *行间距
 */
static const CGFloat lineSpacing = 30.0f;

@interface BIDLockViewForLogin()
{
    //解锁失败次数
    int _failedTimes;
}
@end

@implementation BIDLockViewForLogin
@synthesize trackPath;
@synthesize rightTrackPath;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //[self setBackgroundColor:[UIColor colorWithRed:239.0f/255.0f green:239.0f/255.0f blue:243.0f/255.0f alpha:1.0f]];
        [self setBackgroundColor:[UIColor clearColor]];
        _bFinish = NO;
        _bSame = YES;
        _failedTimes = 0;
        [self createBtns];
        //获取手势密码
        NSString *configPath = [BIDCommonMethods getConfigPath];
        NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:configPath];
        rightTrackPath = [dictionary objectForKey:@"gesturePassword"];
    }
    return self;
}

//创建按钮
- (void)createBtns
{
    _btnsArr = [[NSMutableArray alloc] initWithCapacity:9];
    _choosedArr = [[NSMutableArray alloc] init];
    CGPoint startPt = CGPointMake(leftSpacing, topSpacing);
    for(int i=0; i<9; i++)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect btnFrame;
        btnFrame.origin.x = startPt.x + i%3*radius*2 + i%3*itemSpacing;
        btnFrame.origin.y = startPt.y + i/3*radius*2 + i/3*lineSpacing;
        btnFrame.size.width = radius*2;
        btnFrame.size.height = radius*2;
        btn.frame = btnFrame;
        btn.layer.borderColor = [UIColor whiteColor].CGColor;
        btn.layer.borderWidth = 1;
        btn.layer.cornerRadius = radius;
        btn.userInteractionEnabled = NO;
        btn.tag = i;
        [self addSubview:btn];
        [_btnsArr addObject:btn];
    }
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    if(_choosedArr.count==0) return;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGPoint startPt;
    CGPoint endPt;
    UIColor *normalColor = [UIColor colorWithRed:0 green:126.0f/255.0f blue:246.0f/255.0f alpha:1.0f];
    UIColor *wrongColor = [UIColor redColor];
    for(int i=0; i<_choosedArr.count; i++)
    {
        UIButton *startBtn = _choosedArr[i];
        if(_bFinish && !_bSame)
        {
            startBtn.layer.borderColor = wrongColor.CGColor;
        }
        startPt = CGPointMake(startBtn.frame.origin.x+radius, startBtn.frame.origin.y+radius);
        if(i==_choosedArr.count-1)
        {
            endPt = _curPt;
        }
        else
        {
            UIButton *endBtn = _choosedArr[i+1];
            endPt = CGPointMake(endBtn.frame.origin.x+radius, endBtn.frame.origin.y+radius);
        }
        //
        CGContextSetLineCap(context, kCGLineCapRound);
        CGContextSetLineWidth(context, 2.0f);

        if(_bFinish && !_bSame)
        {
            CGContextSetStrokeColorWithColor(context, wrongColor.CGColor);
            CGContextSetFillColorWithColor(context, wrongColor.CGColor);
        }
        else
        {
            CGContextSetStrokeColorWithColor(context, normalColor.CGColor);
            CGContextSetFillColorWithColor(context, normalColor.CGColor);
        }
        if(_bFinish && !_bSame && i==_choosedArr.count-1)
        {}
        else
        {
            CGContextMoveToPoint(context, startPt.x, startPt.y);
            CGContextAddLineToPoint(context, endPt.x, endPt.y);
            CGContextStrokePath(context);
        }
        
        CGContextFillEllipseInRect(context, CGRectMake(startPt.x-smallRadius, startPt.y-smallRadius, smallRadius*2, smallRadius*2));
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _bFinish = NO;
    UITouch *touch = [touches anyObject];
    CGPoint touchPt = [touch locationInView:self];
    for(UIButton *btn in _btnsArr)
    {
        CGRect rect = btn.frame;
        if([self isPointInRect:touchPt rect:rect])
        {
            [_choosedArr addObject:btn];
            break;
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPt = [touch locationInView:self];
    _curPt = touchPt;
    for(UIButton *btn in _btnsArr)
    {
        CGRect rect = btn.frame;
        if([self isPointInRect:touchPt rect:rect])
        {
            if(![self isBtnRepeat:btn])
            {
                [_choosedArr addObject:btn];
            }
            break;
        }
    }
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    _bFinish = YES;

    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:_choosedArr.count];
    for(UIButton *btn in _choosedArr)
    {
        [arr addObject:[NSNumber numberWithInteger:btn.tag]];
    }
    trackPath = [arr componentsJoinedByString:@","];
    if([trackPath isEqualToString:rightTrackPath])
    {
        //手势解锁成功
        _bSame = YES;
        [self clearScreen];
        [delegate gestureUnlockSuccess];
    }
    else
    {
        //手势解锁失败
        _failedTimes++;
        [delegate gestureUnlockFailed:_failedTimes];
        _bSame = NO;
        [self setNeedsDisplay];
        [self performSelector:@selector(clearScreen) withObject:nil afterDelay:1.0f];
    }
}

- (void)clearScreen
{    
    [_choosedArr removeAllObjects];
    [self resetAllBtn];
    [self setNeedsDisplay];
}

/**
 *重置所有按钮的状态
 */
- (void)resetAllBtn
{
    for(UIButton *btn in _btnsArr)
    {
        btn.layer.borderColor = [UIColor whiteColor].CGColor;
    }
}

/**
 *某个点是否在指定区域内(在yes,不在no)
 */
- (BOOL)isPointInRect:(CGPoint)pt rect:(CGRect)rect
{
    if(pt.x>rect.origin.x && pt.x<rect.origin.x+rect.size.width && pt.y>rect.origin.y && pt.y<rect.origin.y+rect.size.height)
        return YES;
    else
        return NO;
}

/**
 *按钮是否已添加过了(添加过yes,没添加过no)
 */
- (BOOL)isBtnRepeat:(UIButton*)newBtn
{
    for(UIButton *btn in _choosedArr)
    {
        if(newBtn.tag == btn.tag)
        {
            return YES;
        }
    }
    return NO;
}

@end

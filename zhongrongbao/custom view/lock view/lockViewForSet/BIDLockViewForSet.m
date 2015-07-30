//
//  BIDLockView.m
//  mashangban
//
//  Created by mal on 14-8-11.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDLockViewForSet.h"
#import "BIDHintView.h"

/**
 *左边间距 25
 */
static const CGFloat leftSpacing = 40.0f;
/**
 *右边间距
 */
//static const CGFloat rightSpacing = 35.0f;
/**
 *上边间距 100
 */
static const CGFloat topSpacing = 123.0f;
/**
 *按钮半径 35
 */
static const CGFloat radius = 30.0f;
/**
 *小圆半径
 */
static const CGFloat smallRadius = radius/3;
/**
 *水平间距
 */
static const CGFloat itemSpacing = 30.0f;
/**
 *行间距 30
 */
static const CGFloat lineSpacing = 24.0f;

@implementation BIDLockViewForSet
@synthesize firstTrackPath;
@synthesize secondTrackPath;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _bFinish = NO;
        _bFirstTrack = YES;
        _bSame = YES;
        _bEffect = YES;
        [self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"gestureBg.png"]]];
        //[self setBackgroundColor:[UIColor colorWithRed:239.0f/255.0f green:239.0f/255.0f blue:239.0f/255.0f alpha:1.0f]];
        [self createBtns];
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 79, frame.size.width, 30)];
        [_label setTextAlignment:NSTextAlignmentCenter];
        [_label setText:@"绘制解锁图案"];
        [_label setTextColor:[UIColor whiteColor]];
        [_label setFont:[UIFont systemFontOfSize:15.0f]];
        [self addSubview:_label];
    }
    return self;
}

//创建按钮
- (void)createBtns
{
    UIColor *color = [UIColor colorWithRed:206.0f/255.0f green:206.0f/255.0f blue:206.0f/255.0f alpha:1.0f];
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
        btn.layer.borderColor = color.CGColor;
        btn.layer.borderWidth = 1;
        btn.layer.cornerRadius = radius;
        btn.userInteractionEnabled = NO;
        btn.tag = i;
        [self addSubview:btn];
        [self sendSubviewToBack:btn];
        [_btnsArr addObject:btn];
    }
    
    CGFloat flagRadius = 5.0f;
    CGFloat flagItemSpacing = 3.0f;
    CGFloat flagLineSpacing = 3.0f;
    _smallBtnsArr = [[NSMutableArray alloc] initWithCapacity:9];
    startPt = CGPointMake(self.frame.size.width/2-(flagRadius*2*3+flagItemSpacing*2)/2, 33);
    for(int i=0; i<9; i++)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect btnFrame;
        btnFrame.origin.x = startPt.x + i%3*flagRadius*2 + i%3*flagItemSpacing;
        btnFrame.origin.y = startPt.y + i/3*flagRadius*2 + i/3*flagLineSpacing;
        btnFrame.size.width = flagRadius*2;
        btnFrame.size.height = flagRadius*2;
        btn.frame = btnFrame;
        btn.layer.borderColor = color.CGColor;
        btn.layer.borderWidth = 1;
        btn.layer.cornerRadius = flagRadius;
        btn.userInteractionEnabled = NO;
        btn.tag = i;
        [self addSubview:btn];
        [_smallBtnsArr addObject:btn];
    }
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    if(_choosedArr.count==0) return;
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGPoint startPt;
    CGPoint endPt;
    UIColor *normalColor = [UIColor colorWithRed:0 green:161.0f/255.0f blue:223.0f/255.0f alpha:1.0f];
    UIColor *wrongColor = [UIColor redColor];
    UIColor *normalTranslucentColor = [UIColor colorWithRed:0 green:161.0f/255.0f blue:223.0f/255.0f alpha:0.5f];
    UIColor *wrongTranslucentColor = [UIColor colorWithRed:235.0f/255.0f green:73.0f/255.0f blue:66.0f/255.0f alpha:0.5f];

    for(int i=0; i<_choosedArr.count; i++)
    {
        UIButton *startBtn = _choosedArr[i];
        if(!_bSame && !_bFirstTrack)
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
        if(!_bSame && !_bFirstTrack)
        {
            CGContextSetStrokeColorWithColor(context, wrongColor.CGColor);
        }
        else
        {
            CGContextSetStrokeColorWithColor(context, normalColor.CGColor);
        }
        
        if(_bFinish && i==_choosedArr.count-1)
        {
            //防止刷新的时候绘制最后一个点的时候留小尾巴
        }
        else
        {
            CGContextMoveToPoint(context, startPt.x, startPt.y);
            CGContextAddLineToPoint(context, endPt.x, endPt.y);
            CGContextStrokePath(context);
        }

        //
        if(!_bSame && !_bFirstTrack)
        {
            CGContextSetFillColorWithColor(context, wrongTranslucentColor.CGColor);
        }
        else
        {
           CGContextSetFillColorWithColor(context, normalTranslucentColor.CGColor);
        }
        UIButton *btn = _choosedArr[i];
        CGContextFillEllipseInRect(context, btn.frame);
        //
        if(!_bSame && !_bFirstTrack)
        {
            CGContextSetFillColorWithColor(context, wrongColor.CGColor);
        }
        else
        {
            CGContextSetFillColorWithColor(context, normalColor.CGColor);
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
            btn.layer.borderWidth = 0;
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
                btn.layer.borderWidth = 0;
                [_choosedArr addObject:btn];
            }
            break;
        }
    }
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self setFlagBtnState];
    _bFinish = YES;
    if(_choosedArr.count<3)
    {
        _bEffect = NO;
        [_label setText:@"绘制解锁图案"];
        CGSize hintViewSize = CGSizeMake(self.frame.size.width, 30);
        BIDHintView *hintView = [[BIDHintView alloc] initWithFrame:CGRectMake(self.frame.size.width/2-hintViewSize.width/2, -hintViewSize.height, hintViewSize.width, hintViewSize.height)];
        hintView.msg = @"密码太短,最少3位,请重新输入";
        [self addSubview:hintView];
        [UIView animateWithDuration:1.0f animations:^{
            CGRect hintViewFrame = hintView.frame;
            hintViewFrame.origin.y = 0;
            hintView.frame = hintViewFrame;
        } completion:^(BOOL finished){
            if(finished)
            {
                [hintView removeFromSuperview];
                [self performSelector:@selector(clearScreen) withObject:nil afterDelay:0.5f];
            }
        }];
    }
    else
    {
        _bEffect = YES;
        NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:_choosedArr.count];
        for(UIButton *btn in _choosedArr)
        {
            [arr addObject:[NSNumber numberWithInteger:btn.tag]];
        }
        if(_bFirstTrack)
        {
            [_label setText:@"请再次绘制解锁图案"];
            firstTrackPath = [arr componentsJoinedByString:@","];
            //[_choosedArr removeAllObjects];
            [self performSelector:@selector(clearScreen) withObject:nil afterDelay:0.5f];
        }
        else
        {
            secondTrackPath = [arr componentsJoinedByString:@","];
            //第二次设置完需要比较和第一次设置的是否一样
            if([firstTrackPath isEqualToString:secondTrackPath])
            {
                //两次设置的相同,提示设置成功，并返回
                [self saveGesturePassWord];
                CGSize hintViewSize = CGSizeMake(self.frame.size.width, 30);
                BIDHintView *hintView = [[BIDHintView alloc] initWithFrame:CGRectMake(self.frame.size.width/2-hintViewSize.width/2, -hintViewSize.height, hintViewSize.width, hintViewSize.height)];
                hintView.msg = @"设置成功";
                [self addSubview:hintView];
                [UIView animateWithDuration:1.0f animations:^{
                    CGRect hintViewFrame = hintView.frame;
                    hintViewFrame.origin.y = 0;
                    hintView.frame = hintViewFrame;
                } completion:^(BOOL finished){
                    if(finished)
                    {
                        [delegate setGesturePasswordSuccess];
                    }
                }];
            }
            else
            {
                //两次设置的不同
                [_label setText:@"与上一次输入不一致，请重新设置"];
                _bSame = NO;
                [self setNeedsDisplay];
                [self performSelector:@selector(clearScreen) withObject:nil afterDelay:1.0f];
            }
        }
    }
}

- (void)clearScreen
{
    if(_bEffect)
    {
        if(_bFirstTrack)
            _bFirstTrack = NO;
        else
        {
            _bFirstTrack = YES;
            _bSame = YES;
        }
    }
    else
    {
        _bFirstTrack = YES;
        _bSame = YES;
    }
    
    [_choosedArr removeAllObjects];
    [self setNeedsDisplay];
    [self resetAllBtn];
}

/**
 *设置标志按钮的状态
 */
- (void)setFlagBtnState
{
    for(UIButton *btn in _smallBtnsArr)
    {
        [btn setBackgroundColor:[UIColor clearColor]];
    }
    if(_choosedArr.count>0)
    {
        for(UIButton *btn in _choosedArr)
        {
            UIButton *flagBtn = _smallBtnsArr[btn.tag];
            [flagBtn setBackgroundColor:[UIColor colorWithRed:0 green:126.0f/255.0f blue:246.0f/255.0f alpha:1.0f]];
        }
    }
}

/**
 *重置所有按钮的状态
 */
- (void)resetAllBtn
{
    UIColor *color = [UIColor colorWithRed:206.0f/255.0f green:206.0f/255.0f blue:206.0f/255.0f alpha:1.0f];
    for(UIButton *btn in _btnsArr)
    {
        [btn setBackgroundColor:[UIColor clearColor]];
        btn.layer.borderColor = color.CGColor;
        btn.layer.borderWidth = 1;
    }
}

/**
 *存储手势密码
 */
- (void)saveGesturePassWord
{
    NSArray *urls = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if(urls.count>0)
    {
        NSString *documentPath = urls[0];
        NSString *configPath = [documentPath stringByAppendingPathComponent:@"config.plist"];
        if([[NSFileManager defaultManager] fileExistsAtPath:configPath])
        {
            //文件已经存在,则读取文件信息
            NSDictionary *infoDictionary = [[NSDictionary alloc] initWithContentsOfFile:configPath];
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithDictionary:infoDictionary];
            //[dictionary setValue:@1 forKey:@"openGesturePassWord"];
            [dictionary setValue:firstTrackPath forKey:@"gesturePassword"];
            [dictionary writeToFile:configPath atomically:YES];
        }
        //
        NSString *strLoginInfoPath = [[NSString alloc] initWithFormat:@"%@", [documentPath stringByAppendingPathComponent:loginInfoFileName]];
        if([[NSFileManager defaultManager] fileExistsAtPath:strLoginInfoPath])
        {
            NSMutableArray *arr = [[NSMutableArray alloc] initWithContentsOfFile:strLoginInfoPath];
            NSString *strUserId = [BIDAppDelegate getUserId];
            for(int i=0; i<arr.count; i++)
            {
                NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithDictionary:arr[i]];
                if([[dictionary objectForKey:@"uid"] isEqualToString:strUserId])
                {
                    [dictionary setValue:firstTrackPath forKey:@"gesturePwd"];
                    [arr replaceObjectAtIndex:i withObject:dictionary];
                    [arr writeToFile:strLoginInfoPath atomically:YES];
                    break;
                }
            }
        }
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

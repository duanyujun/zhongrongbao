//
//  BIDAccountSectionView.m
//  zhongrongbao
//
//  Created by mal on 14-8-26.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDAccountSectionView.h"
#import "BIDYearAndMonthView.h"
#import "BIDCommonMethods.h"
#import "BIDAppDelegate.h"
#import "BIDCustomSpinnerView.h"
#import "BIDAttachedView.h"

/**
 *查询某年某月的收益
 */
static NSString *strQueryIncomeURL = @"RepaymentDetail/RepaymentIncome.shtml";

@interface BIDAccountSectionView()<BIDYearAndMonthViewDelegate>
{
    BIDYearAndMonthView *_dateView;
    BIDCustomSpinnerView *_spinnerView;
    NSMutableArray *_incomeInfoArr;
    BIDAttachedView *_attachedView;
    int _tappedDay;
}
@end

@implementation BIDAccountSectionView
@synthesize labelArr;
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
    _tappedDay = 0;
    _incomeInfoArr = [[NSMutableArray alloc] init];
    //
    _flagLabel1.layer.cornerRadius = CGRectGetWidth(_flagLabel1.frame)/2;
    _flagLabel2.layer.cornerRadius = CGRectGetWidth(_flagLabel2.frame)/2;
    _flagLabel3.layer.cornerRadius = CGRectGetWidth(_flagLabel3.frame)/2;
    _flagLabel4.layer.cornerRadius = CGRectGetWidth(_flagLabel4.frame)/2;
    _leftBtnLabel.layer.cornerRadius = CGRectGetWidth(_leftBtnLabel.frame)/2;
    _rightBtnLabel.layer.cornerRadius = CGRectGetWidth(_rightBtnLabel.frame)/2;
    _leftBtnLabel.layer.masksToBounds = YES;
    _rightBtnLabel.layer.masksToBounds = YES;
    //[BIDCommonMethods setImgForBtn:_leftBtn imgForNormal:@"grayBtnBgNormal.png" imgForPress:@"grayBtnBgPress.png" inset:UIEdgeInsetsMake(10, 10, 11, 11)];
    //[BIDCommonMethods setImgForBtn:_rightBtn imgForNormal:@"grayBtnBgNormal.png" imgForPress:@"grayBtnBgPress.png" inset:UIEdgeInsetsMake(10, 10, 11, 11)];
    //
    _spinnerView = [[BIDCustomSpinnerView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    _spinnerView.content = @"获取数据..";
    //
    _dateView = [[BIDYearAndMonthView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
    //
    _attachedView = [[BIDAttachedView alloc] init];
    //
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
    [_dateLabel addGestureRecognizer:tapGestureRecognizer];
    
    //今天的日期
    NSDate *today = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    //根据今天的日期获取日期组件
    NSDateComponents *todayComponents = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit fromDate:today];
    _curMonth = (int)todayComponents.month;
    _curYear = (int)todayComponents.year;
    _trueMonth = _curMonth;
    _trueYear = _curYear;
    _dateLabel.text = _curMonth<10?[[NSString alloc] initWithFormat:@"%d-0%d", _trueYear, _trueMonth]:[[NSString alloc] initWithFormat:@"%d-%d", _trueYear, _trueMonth];
    [self initLayout:_curMonth year:_curYear];
    //
    UISwipeGestureRecognizer *leftToRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeFromLeftToRight:)];
    leftToRightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    //
    UISwipeGestureRecognizer *rightToLeftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeFromRightToLeft:)];
    rightToLeftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    //
    [self addGestureRecognizer:leftToRightGesture];
    [self addGestureRecognizer:rightToLeftGesture];
}

- (void)initLayout:(int)month year:(int)year
{
    [_attachedView removeFromSuperview];
    _flagView.hidden = YES;
    for(UILabel *label in labelArr)
    {
        [label removeFromSuperview];
    }
    [labelArr removeAllObjects];
    CGPoint startPt = CGPointMake(34.0f, 60.0f);
    CGFloat itemSpacing = 16.0f;
    CGFloat lineSpacing = 8.0f;
    CGSize labelSize = CGSizeMake(22.0f, 22.0f);
    NSCalendar *calendar = [NSCalendar currentCalendar];
    //今天的日期
    NSDate *today = [NSDate date];
    //根据今天的日期获取日期组件
    NSDateComponents *todayComponents = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit fromDate:today];
    //设置本月的1号的dateComponents
    [todayComponents setDay:1];
    [todayComponents setMonth:month];
    [todayComponents setYear:year];
    NSDate *firstDateInMonth = [calendar dateFromComponents:todayComponents];
    NSDateComponents *weekdayComponents = [calendar components:NSWeekdayCalendarUnit fromDate:firstDateInMonth];
    //获取本月1号是周几
    NSInteger weekDay = [weekdayComponents weekday];
    //获取本月共有多少天
    NSInteger monthDays = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:firstDateInMonth].length;
    labelArr = [[NSMutableArray alloc] initWithCapacity:monthDays];
    //创建日历
    for(int i=1; i<monthDays+1; i++)
    {
        //if(i<weekDay) continue;
        CGPoint pt;
        pt.x = startPt.x + (i+weekDay-2)%7 * labelSize.width + (i+weekDay-2)%7 * itemSpacing;
        pt.y = startPt.y + (i+weekDay-2)/7 * labelSize.height + (i+weekDay-2)/7 *lineSpacing;
        CGRect labelFrame = CGRectMake(pt.x, pt.y, labelSize.width, labelSize.height);
        UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
        [label setFont:[UIFont systemFontOfSize:13.0f]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setTextColor:[UIColor colorWithRed:148.0f/255.0f green:192.0f/255.0f blue:224.0f/255.0f alpha:1.0f]];
        [label setText:[[NSString alloc] initWithFormat:@"%d", i]];
        label.tag = i;
        label.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
        [label addGestureRecognizer:tapGesture];
        [self addSubview:label];
        [labelArr addObject:label];
    }
    //获得该view的最终高度
    UILabel *lastLabel = [labelArr lastObject];
    CGRect flagViewFrame = _flagView.frame;
    flagViewFrame.origin.y = CGRectGetMaxY(lastLabel.frame) + 10.0f;
    _flagView.frame = flagViewFrame;
    CGRect ownFrame = self.frame;
    ownFrame.size.height = CGRectGetMaxY(lastLabel.frame) + 10.0f + CGRectGetHeight(flagViewFrame);
    self.frame = ownFrame;
    [self setBackgroundColor:[UIColor colorWithRed:232.0f/255.0f green:236.0f/255.0f blue:238.0f/255.0f alpha:1.0f]];
    _flagView.hidden = NO;
    //
    [delegate refreshSectionView:ownFrame.size.height];
    //
    NSString *strDate = month<10?[[NSString alloc] initWithFormat:@"%d-0%d", year, month]:[[NSString alloc] initWithFormat:@"%d-%d", year, month];
    [self getIncomeInfoWithData:strDate];
}
/**
 *获取当前年月收益详情
 */
- (void)getIncomeInfoWithData:(NSString*)strDate
{
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strQueryIncomeURL];
    NSString *strPost = [[NSString alloc] initWithFormat:@"jsonDataSet={\"date\":\"%@\"}", strDate];
    [_spinnerView showTheView];
    //
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        int rev = [BIDDataCommunication uploadDataByPostToURL:strURL postValue:strPost toDictionary:dictionary];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_spinnerView dismissTheView];
            if(rev==1)
            {
                if([[dictionary objectForKey:@"json"] isEqualToString:@"success"])
                {
                    [_incomeInfoArr setArray:[dictionary objectForKey:@"dataList"]];
                    [self setLabelToCorrespondingBgColor];
                }
            }
            else
            {
                [BIDCommonMethods showAlertView:@"获取该月收益失败" buttonTitle:@"关闭" delegate:nil tag:0];
            }
        });
    });
}
/**
 *显示收益金额或日期选项
 */
- (void)tapGestureHandler:(UITapGestureRecognizer*)gestureRecognizer
{
    UILabel *label = (UILabel*)gestureRecognizer.view;
    NSLog(@"%d", label.tag);
    if(label.tag==100)
    {
        //显示日期选项
        [_dateView showView];
    }
    else
    {
        if(_tappedDay==label.tag)
        {
            _tappedDay = 0;
            [_attachedView removeFromSuperview];
        }
        else
        {
            for(NSDictionary *dictionary in _incomeInfoArr)
            {
                NSString *strDate = [dictionary objectForKey:@"repayDate"];
                int day = [strDate intValue];
                if(label.tag == day)
                {
                    NSString *str = [dictionary objectForKey:@"repayAmt"];
                    NSArray *arr = [str componentsSeparatedByString:@"-"];
                    NSString *strAmt = arr[0];
                    NSString *strColor = arr[1];
                    UIColor *color;
                    if([strColor isEqualToString:@"gray"])
                    {
                        //综合
                        color = [UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f];
                    }
                    else if([strColor isEqualToString:@"blue"])
                    {
                        //结息
                        color = [UIColor colorWithRed:52.0f/255.0f green:152.0f/255.0f blue:219.0f/255.0f alpha:1.0f];
                    }
                    else if([strColor isEqualToString:@"red"])
                    {
                        //本息
                        color = [UIColor colorWithRed:231.0f/255.0f green:76.0f/255.0f blue:60.0f/255.0f alpha:1.0f];
                    }
                    else if([strColor isEqualToString:@"dblue"])
                    {
                        //还本
                        color = [UIColor colorWithRed:44.0f/255.0f green:62.0f/255.0f blue:80.0f/255.0f alpha:1.0f];
                    }
                    _tappedDay = day;
                    [_attachedView setContent:strAmt textColor:color];
                    CGRect labelFrame = label.frame;
                    CGPoint centerPt = CGPointMake(label.center.x, CGRectGetMaxY(labelFrame)+2.0f+CGRectGetHeight(_attachedView.frame)/2);
                    _attachedView.center = centerPt;
                    [self addSubview:_attachedView];
                    break;
                }
            }
        }
    }
}
/**
 *上一个月
 */
- (IBAction)leftBtnHandler:(id)sender
{
    _curMonth--;
    if(_curMonth==0)
    {
        _curMonth = 12;
        _curYear--;
    }
    _dateLabel.text = _curMonth<10?[[NSString alloc] initWithFormat:@"%d-0%d", _curYear, _curMonth]:[[NSString alloc] initWithFormat:@"%d-%d", _curYear, _curMonth];
    [self initLayout:_curMonth year:_curYear];
}
/**
 *下一个月
 */
- (IBAction)rightBtnHandler:(id)sender
{
    _curMonth++;
    if(_curMonth>12)
    {
        _curMonth = 1;
        _curYear++;
    }
    _dateLabel.text = _curMonth<10?[[NSString alloc] initWithFormat:@"%d-0%d", _curYear, _curMonth]:[[NSString alloc] initWithFormat:@"%d-%d", _curYear, _curMonth];
    [self initLayout:_curMonth year:_curYear];
}

- (void)swipeFromLeftToRight:(UISwipeGestureRecognizer*)gestureRecognizer
{
    _curMonth--;
    if(_curMonth==0)
    {
        _curMonth = 12;
        _curYear--;
    }
    _dateLabel.text = _curMonth<10?[[NSString alloc] initWithFormat:@"%d-0%d", _curYear, _curMonth]:[[NSString alloc] initWithFormat:@"%d-%d", _curYear, _curMonth];
    [self initLayout:_curMonth year:_curYear];
}

- (void)swipeFromRightToLeft:(UISwipeGestureRecognizer*)gestureRecognizer
{
    _curMonth++;
    if(_curMonth>12)
    {
        _curMonth = 1;
        _curYear++;
    }
    _dateLabel.text = _curMonth<10?[[NSString alloc] initWithFormat:@"%d-0%d", _curYear, _curMonth]:[[NSString alloc] initWithFormat:@"%d-%d", _curYear, _curMonth];
    [self initLayout:_curMonth year:_curYear];
}

- (void)setInterestFlag:(NSInteger)day
{
    UILabel *label = (UILabel*)labelArr[day-1];
    [label setTextColor:[UIColor whiteColor]];
    label.layer.cornerRadius = CGRectGetWidth(label.frame)/2;
    label.layer.masksToBounds = YES;
    [label setBackgroundColor:[UIColor colorWithRed:40.0f/255.0f green:153.0f/255.0f blue:213.0f/255.0f alpha:1.0f]];
}

- (void)setPrincipalFlag:(NSInteger)day
{
    UILabel *label = (UILabel*)labelArr[day-1];
    [label setTextColor:[UIColor whiteColor]];
    label.layer.cornerRadius = CGRectGetWidth(label.frame)/2;
    label.layer.masksToBounds = YES;
    [label setBackgroundColor:[UIColor colorWithRed:235.0f/255.0f green:73.0f/255.0f blue:66.0f/255.0f alpha:1.0f]];
}

/**
 *设置日期对应的背景颜色
 */
- (void)setLabelToCorrespondingBgColor
{
    for(NSDictionary *dictionary in _incomeInfoArr)
    {
        NSString *strDay = [dictionary objectForKey:@"repayDate"];
        int day = [strDay intValue];
        UILabel *label = (UILabel*)labelArr[day-1];
        [label setTextColor:[UIColor whiteColor]];
        label.layer.cornerRadius = CGRectGetWidth(label.frame)/2;
        label.layer.masksToBounds = YES;
        UIColor *color;
        NSString *strInfo = [dictionary objectForKey:@"repayAmt"];
        NSString *strColor = [strInfo componentsSeparatedByString:@"-"][1];
        if([strColor isEqualToString:@"gray"])
        {
            //综合
            color = [UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f];
        }
        else if([strColor isEqualToString:@"blue"])
        {
            //结息
            color = [UIColor colorWithRed:52.0f/255.0f green:152.0f/255.0f blue:219.0f/255.0f alpha:1.0f];
        }
        else if([strColor isEqualToString:@"red"])
        {
            //本息
            color = [UIColor colorWithRed:231.0f/255.0f green:76.0f/255.0f blue:60.0f/255.0f alpha:1.0f];
        }
        else if([strColor isEqualToString:@"dblue"])
        {
            //还本
            color = [UIColor colorWithRed:44.0f/255.0f green:62.0f/255.0f blue:80.0f/255.0f alpha:1.0f];
        }
        [label setBackgroundColor:color];
    }
}

#pragma mark -BIDYearAndMonthViewDelegate
- (void)getChoosedDate:(NSString *)choosedDate
{
    _dateLabel.text = choosedDate;
    NSArray *arr = [choosedDate componentsSeparatedByString:@"-"];
    int month = [arr[1] intValue];
    int year = [arr[0] intValue];
    [self initLayout:month year:year];
}

@end

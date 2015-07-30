//
//  BIDYearAndMonthView.m
//  shangwuting
//
//  Created by mal on 14-2-11.
//  Copyright (c) 2014年 mal. All rights reserved.
//

#import "BIDYearAndMonthView.h"

@implementation BIDYearAndMonthView
@synthesize bgView;
@synthesize myPicker;
@synthesize myToolbar;
@synthesize yearArr;
@synthesize monthArr;
@synthesize bShow;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initView];
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
    bShow = NO;
    CGRect ownFrame = self.frame;
    ownFrame.size.height = 246.0f;
    ownFrame.origin.x = 0;
    ownFrame.origin.y = [UIScreen mainScreen].bounds.size.height;
    self.frame = ownFrame;
    [self setBackgroundColor:[UIColor whiteColor]];
    //设置数据源
    yearArr = [[NSMutableArray alloc] initWithCapacity:21];
    NSDate *curDate = [NSDate date];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy:M"];
    NSString *strDate = [df stringFromDate:curDate];
    NSArray *dateArr = [strDate componentsSeparatedByString:@":"];
    NSInteger curYear = [dateArr[0] integerValue];
    NSInteger curMonth = [dateArr[1] integerValue];
    for(int i=10; i>0; i--)
    {
        NSInteger value = curYear - i;
        [yearArr addObject:[[NSString alloc] initWithFormat:@"%ld", (long)value]];
    }
    [yearArr addObject:dateArr[0]];
    for(int i=1; i<11; i++)
    {
        NSInteger value = curYear + i;
        [yearArr addObject:[[NSString alloc] initWithFormat:@"%ld", (long)value]];
    }
    monthArr = [[NSArray alloc] initWithObjects:@"01", @"02", @"03", @"04", @"05", @"06", @"07", @"08", @"09", @"10", @"11", @"12", nil];
    
    //myToolBar
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelBtnHandler)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *item3 = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleBordered target:self action:@selector(confirmBtnHandler)];
    myToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, ownFrame.size.width, 30.0f)];
    [myToolbar setItems:[[NSArray alloc] initWithObjects:item1, item2, item3, nil]];
    myToolbar.barStyle = UIBarStyleBlackTranslucent;
    [self addSubview:myToolbar];
    
    //bgView
    bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, myToolbar.frame.size.height, ownFrame.size.width, 216.0f)];
    bgView.image = [UIImage imageNamed:@"dateBg.png"];
    if([UIDevice currentDevice].systemVersion.doubleValue>=7.0)
    {}
    else
    {
        //[self addSubview:bgView];

    }
        
    //pickerView
    CGSize pickerSize = CGSizeMake(320, 216.0f);
    myPicker = [[UIPickerView alloc] initWithFrame:CGRectMake((ownFrame.size.width-pickerSize.width)/2, myToolbar.frame.size.height, pickerSize.width, pickerSize.height)];
    myPicker.dataSource = self;
    myPicker.delegate = self;
    myPicker.showsSelectionIndicator = YES;
    [myPicker selectRow:10 inComponent:0 animated:NO];
    [myPicker selectRow:curMonth-1 inComponent:1 animated:NO];
    [self addSubview:myPicker];
}

- (void)confirmBtnHandler
{
    bShow = NO;
    __block CGRect frame1 = self.frame;
    [UIView animateWithDuration:0.35f animations:^{frame1.origin.y=[UIScreen mainScreen].bounds.size.height;self.frame = frame1;} completion:^(BOOL finished){
        NSInteger row = [myPicker selectedRowInComponent:0];
        NSString *strYear = [yearArr objectAtIndex:row];
        row = [myPicker selectedRowInComponent:1];
        NSString *strMonth = [monthArr objectAtIndex:row];
        [delegate getChoosedDate:[[NSString alloc] initWithFormat:@"%@-%@", strYear, strMonth]];
        [self removeFromSuperview];
    }];
}

- (void)cancelBtnHandler
{
    bShow = NO;
    [self dismissView];
}

- (void)showView
{
    if(!bShow)
    {
        bShow = YES;
        UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
        
        __block CGRect frame1 = self.frame;
        [keyWindow addSubview:self];
        [UIView animateWithDuration:0.6f animations:^{frame1.origin.y = [UIScreen mainScreen].bounds.size.height-246; self.frame = frame1;}];
    }
}

- (void)dismissView
{
    __block CGRect frame1 = self.frame;
    [UIView animateWithDuration:0.35f animations:^{frame1.origin.y=[UIScreen mainScreen].bounds.size.height;self.frame = frame1;} completion:^(BOOL finished){[self removeFromSuperview];}];
}

#pragma mark UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(component==0)
    {
        return [yearArr count];
    }
    else
    {
        return [monthArr count];
    }
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(component==0)
    {
        return [yearArr objectAtIndex:row];
    }
    else
    {
        return [monthArr objectAtIndex:row];
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 70.0f;
}

@end

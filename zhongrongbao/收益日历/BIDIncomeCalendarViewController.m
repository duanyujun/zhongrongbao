//
//  BIDIncomeCalendarViewController.m
//  zhongrongbao
//
//  Created by mal on 15/6/27.
//  Copyright (c) 2015年 cnsoft. All rights reserved.
//

#import "BIDIncomeCalendarViewController.h"
#import "BIDManagerInNavViewController.h"
#import "BIDMyTableView.h"
#import "BIDIncomeCalendarCell.h"

/**
 *收益日历(page.currentPage, page.showCount, stateType:01未还、02已还)
 */
static NSString *incomeCalendarURL = @"RepaymentDetail/RepaymentOnePage.shtml";

@interface BIDIncomeCalendarViewController ()<UIScrollViewDelegate, BIDMyTableViewDelegate>
{
    int _curPage;
    /**
     *全部
     */
    BIDMyTableView *_tableViewForAll;
    /**
     *待还
     */
    BIDMyTableView *_tableViewForRepayment;
    /**
     *已还
     */
    BIDMyTableView *_tableViewForFinished;
    /**
     *数据源
     */
    NSMutableArray *_dataSourceForAll;
    NSMutableArray *_dataSourceForRepayment;
    NSMutableArray *_dataSourceForFinished;
    //
    BOOL _bRegister;
    /**
     *初次加载
     */
    BOOL _bFirstLoad;
}

@end

@implementation BIDIncomeCalendarViewController
@synthesize segmentedIndex;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [BIDDataCommunication setCountPerPage:15];
    _curPage = 0;
    segmentedIndex = 0;
    _bFirstLoad = YES;
    _dataSourceForAll = [[NSMutableArray alloc] init];
    _dataSourceForRepayment = [[NSMutableArray alloc] init];
    _dataSourceForFinished = [[NSMutableArray alloc] init];
    //
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGRect tableViewFrameForAll = CGRectMake(0, 0, screenSize.width, screenSize.height-64-CGRectGetMinY(_myScrollView.frame));
    CGRect tableViewFrameForRepayment = CGRectMake(screenSize.width, 0, screenSize.width, screenSize.height-64-CGRectGetMinY(_myScrollView.frame));
    CGRect tableViewFrameForFinished = CGRectMake(screenSize.width*2, 0, screenSize.width, screenSize.height-64-CGRectGetMinY(_myScrollView.frame));
    _tableViewForAll = [[BIDMyTableView alloc] initWithFrame:tableViewFrameForAll];
    _tableViewForAll.tag = 1;
    _tableViewForAll.myDelegate = self;
    _tableViewForRepayment = [[BIDMyTableView alloc] initWithFrame:tableViewFrameForRepayment];
    _tableViewForRepayment.tag = 2;
    _tableViewForRepayment.myDelegate = self;
    _tableViewForFinished = [[BIDMyTableView alloc] initWithFrame:tableViewFrameForFinished];
    _tableViewForFinished.tag = 3;
    _tableViewForFinished.myDelegate = self;
    //
    NSString *strServerAddr = [BIDAppDelegate getServerAddr];
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", strServerAddr, incomeCalendarURL];
    _tableViewForAll.strURL = strURL;
    NSString *strURL2 = [[NSString alloc] initWithFormat:@"%@?repayStatus=%@", strURL, @"01"];
    _tableViewForRepayment.strURL = strURL2;
    NSString *strURL3 = [[NSString alloc] initWithFormat:@"%@?repayStatus=%@", strURL, @"02"];
    _tableViewForFinished.strURL = strURL3;
    //
    _myScrollView.contentSize = CGSizeMake(screenSize.width*3, screenSize.height-64-CGRectGetMinY(_myScrollView.frame));
    _myScrollView.pagingEnabled = YES;
    [_myScrollView addSubview:_tableViewForAll];
    [_myScrollView addSubview:_tableViewForRepayment];
    [_myScrollView addSubview:_tableViewForFinished];
    //
    [_tableViewForAll firstLoadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    parent.navigationItem.titleView = nil;
    parent.navigationItem.title = @"收益日历";
    parent.navigationItem.rightBarButtonItem = nil;
}

#pragma mark UISegmentedControlChangeEvent
- (IBAction)segmentedControlChangeHandler:(UISegmentedControl*)segmentedControl
{
    segmentedIndex = segmentedControl.selectedSegmentIndex;
    [_myScrollView setContentOffset:CGPointMake(segmentedIndex*CGRectGetWidth(self.view.frame), 0) animated:YES];
    _curPage = segmentedIndex;
    BIDMyTableView *tableView = nil;
    switch(_curPage)
    {
        case 0:
        {
            tableView = _tableViewForAll;
        }
            break;
        case 1:
        {
            tableView = _tableViewForRepayment;
        }
            break;
        case 2:
        {
            tableView = _tableViewForFinished;
        }
            break;
    }
    if(tableView.itemsArr.count==0) [tableView firstLoadData];
}

#pragma mark - UIScrollViewDelegate
//ScrollView 划动的动画结束后调用.
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    NSInteger page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if(page==_curPage)
    {
        if(page==0 && scrollView.contentOffset.x>=0)
        {
            BIDManagerInNavViewController *vc = (BIDManagerInNavViewController*)self.parentViewController;
            [vc slideToRight];
        }
    }
    else
    {
        _curPage = page;
        [_segmentedControl setSelectedSegmentIndex:page];
        segmentedIndex = page;
        BIDMyTableView *tableView = nil;
        switch(_curPage)
        {
            case 0:
            {
                tableView = _tableViewForAll;
            }
                break;
            case 1:
            {
                tableView = _tableViewForRepayment;
            }
                break;
            case 2:
            {
                tableView = _tableViewForFinished;
            }
                break;
        }
        if(tableView.itemsArr.count==0) [tableView firstLoadData];
    }
}

#pragma mark - BIDMyTableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    BIDMyTableView *myTableView = (BIDMyTableView*)tableView;
    return myTableView.itemsArr.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    static NSString *identifier = @"identifier";
    NSUInteger row = indexPath.row;
    if(!_bRegister)
    {
        _bRegister = YES;
        UINib *nib = [UINib nibWithNibName:@"BIDIncomeCalendarCell" bundle:nil];
        [_tableViewForAll registerNib:nib forCellReuseIdentifier:identifier];
        [_tableViewForRepayment registerNib:nib forCellReuseIdentifier:identifier];
        [_tableViewForFinished registerNib:nib forCellReuseIdentifier:identifier];
    }
    BIDIncomeCalendarCell *incomeCalendarCell = [tableView dequeueReusableCellWithIdentifier:identifier];
    BIDMyTableView *myTableView = (BIDMyTableView*)tableView;
    NSArray *dataArr = myTableView.itemsArr;
    NSDictionary *dictionary = dataArr[row];
    incomeCalendarCell.repayDateLabel.text = [dictionary objectForKey:@"repayDate"];
    NSString *strTypeCode = [dictionary objectForKey:@"repayType"];
    NSString *strType = @"";
    if([strTypeCode isEqualToString:@"01"]) strType = @"利息";
    else if([strTypeCode isEqualToString:@"02"]) strType = @"本金";
    else if([strTypeCode isEqualToString:@"03"]) strType = @"本息";
    incomeCalendarCell.repayTypeLabel.text = strType;
    incomeCalendarCell.repayCountLabel.text = [dictionary objectForKey:@"repayAmt"];
    NSString *strStatusCode = [dictionary objectForKey:@"repayStatus"];
    NSString *strStatus = @"";
    if([strStatusCode isEqualToString:@"01"])
    {
        incomeCalendarCell.repayStatusLabel.textColor = [UIColor colorWithRed:255.0f/255.0f green:61.0f/255.0f blue:61.0f/255.0f alpha:1.0f];
        strStatus = @"未还";
    }
    else if([strStatusCode isEqualToString:@"02"])
    {
        incomeCalendarCell.repayStatusLabel.textColor = [UIColor colorWithRed:91.0f/255.0f green:91.0f/255.0f blue:91.0f/255.0f alpha:1.0f];
        strStatus = @"已还";
    }
    incomeCalendarCell.repayStatusLabel.text = strStatus;
    cell = incomeCalendarCell;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

@end

//
//  BIDHomePageViewController.m
//  zhongrongbao
//
//  Created by mal on 14-8-12.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDHomePageViewController.h"
#import "BIDTenderCell.h"
#import "BIDTenderView.h"
#import "BIDTenderDetailInfoViewController.h"
#import "BIDAppDelegate.h"
#import "BIDManagerInNavViewController.h"
#import "BIDMyTableView.h"
#import "BIDCreditRightTransferView.h"
#import "BIDLoginAndRegisterViewController.h"

/**
 *标列表
 */
static NSString *strTenderListURL = @"borrow/borrowOnePage.shtml";
/**
 *新标预告列表
 */
static NSString *strNewTenderListURL = @"borrow/autoList.shtml";
/**
 *债权转让列表
 */
static NSString *strCreditRightListURL = @"transferDetails/queryTransferMes.shtml";

const int kTotalPage = 4;

@interface BIDHomePageViewController ()<UIAlertViewDelegate, UIScrollViewDelegate>
{
    /**
     *项目arr
     */
    NSMutableArray *_projectArr;
    /**
     *定向融资arr
     */
    NSMutableArray *_groupArr;
    /**
     *债权arr
     */
    NSMutableArray *_creditRightArr;

    int _curPage;
    /**
     *
     */
    BOOL _bFirst;
}
@end

@implementation BIDHomePageViewController
@synthesize segmentedIndex;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    segmentedIndex = 0;
    _curPage = 0;
    [BIDDataCommunication setCountPerPage:5];
    //
    //[_bgView setBackgroundColor:[UIColor colorWithRed:39.0f/255.0f green:149.0f/255.0f blue:205.0f/255.0f alpha:1.0f]];
    _myScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    _myScrollView.scrollEnabled = YES;
    _myScrollView.showsHorizontalScrollIndicator = NO;
    _myScrollView.showsVerticalScrollIndicator = NO;
    [_myScrollView setContentSize:CGSizeMake(426, 30.0f)];
    //[_bgView addSubview:_myScrollView];
    //
    _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"项目", @"定向融资", @"债权转让", @"新标预告"]];
    _segmentedControl.frame = CGRectMake(-4, 1, 328, 29);
    _segmentedControl.tintColor = [UIColor blueColor];
    _segmentedControl.selectedSegmentIndex = 0;
    [_segmentedControl setTintColor:[UIColor colorWithRed:52.0f/255.0f green:152.0f/255.0f blue:219.0f/255.0f alpha:1.0f]];
    [_segmentedControl addTarget:self action:@selector(segmentedControlChangeHandler:) forControlEvents:UIControlEventValueChanged];
    //[_myScrollView addSubview:_segmentedControl];
    [_bgView addSubview:_segmentedControl];
    //
    CGFloat scrollViewHeight = [UIScreen mainScreen].bounds.size.height-64-CGRectGetHeight(_bgView.frame);
    _listScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_bgView.frame), CGRectGetWidth(self.view.frame), scrollViewHeight)];
    [self.view addSubview:_listScrollView];
    _listScrollView.delegate = self;
    _listScrollView.showsHorizontalScrollIndicator = NO;
    _listScrollView.showsVerticalScrollIndicator = NO;
    _listScrollView.pagingEnabled = YES;
    _listScrollView.bounces = NO;
    _listScrollView.scrollsToTop = NO;
    //
    CGSize listViewSize = CGSizeMake(CGRectGetWidth(_listScrollView.frame), CGRectGetHeight(_listScrollView.frame));
    _tenderListViewArr = [[NSMutableArray alloc] initWithCapacity:4];
    for(int i=0; i<4; i++)
    {
        BIDTenderListView *tenderListView = [[BIDTenderListView alloc] initWithFrame:CGRectMake(i*listViewSize.width, 0, listViewSize.width, listViewSize.height)];
        [tenderListView setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:240.0f/255.0f blue:241.0f/255.0f alpha:1.0f]];
        tenderListView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tenderListView.parentVC = self;
        switch(i)
        {
            case 0:
            {
                tenderListView.strURL = [[NSString alloc] initWithFormat:@"%@/%@?bidType=%@", [BIDAppDelegate getServerAddr], strTenderListURL, @"02"];
            }
                break;
            case 1:
            {
                tenderListView.strURL = [[NSString alloc] initWithFormat:@"%@/%@?bidType=%@", [BIDAppDelegate getServerAddr], strTenderListURL, @"01"];
            }
                break;
            case 2:
            {
                tenderListView.strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strCreditRightListURL];
            }
                break;
            case 3:
            {
                tenderListView.strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strNewTenderListURL];
            }
                break;
        }
        tenderListView.scrollsToTop = NO;
        [_tenderListViewArr addObject:tenderListView];
        [_listScrollView addSubview:tenderListView];
    }
    //
    [_listScrollView setContentSize:CGSizeMake(listViewSize.width*4, CGRectGetHeight(_listScrollView.frame))];
    //
//    BIDTenderListView *tenderListView = (BIDTenderListView*)_tenderListViewArr[0];
//    [tenderListView firstLoadData];
//    tenderListView.scrollsToTop = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    //设置navBar中间的标题视图
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 22)];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navLogo.png"]];
    imgView.frame = CGRectMake(0, 0, 30, 22);
    [titleView addSubview:imgView];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 70, 22)];
    [label setText:@"中融宝"];
    [label setFont:[UIFont systemFontOfSize:22.0f]];
    [label setTextColor:[UIColor whiteColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [titleView addSubview:label];
    parent.navigationItem.titleView = titleView;
    //
    parent.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"充值" style:UIBarButtonItemStylePlain target:self action:@selector(topupHandler)];
}
- (void)viewDidAppear:(BOOL)animated
{
    //只执行1次
    if(!_bFirst)
    {
        _bFirst = YES;
        BIDTenderListView *tenderListView = (BIDTenderListView*)_tenderListViewArr[0];
        [tenderListView firstLoadData];
        tenderListView.scrollsToTop = YES;
    }
}

//充值
- (void)topupHandler
{
    if(![BIDAppDelegate isHaveLogin])
    {
        //未登录,则提示需要登录才能投标，是否登录
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"登录后才可以继续操作，是否登录" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
        [alertView show];
    }
    else
    {
        //已登录
        BIDManagerInNavViewController *vc = (BIDManagerInNavViewController*)self.parentViewController;
        [vc topup];
    }
}

/**
 *
 */
- (void)segmentedControlChangeHandler:(UISegmentedControl*)segmentedControl
{
    segmentedIndex = segmentedControl.selectedSegmentIndex;
    [_listScrollView setContentOffset:CGPointMake(segmentedIndex*CGRectGetWidth(self.view.frame), 0) animated:YES];
    _curPage = segmentedIndex;
    for(id obj in _tenderListViewArr)
    {
        BIDTenderListView *listView = (BIDTenderListView*)obj;
        listView.scrollsToTop = NO;
    }
    BIDTenderListView *tenderListView = (BIDTenderListView*)_tenderListViewArr[segmentedIndex];
    tenderListView.scrollsToTop = YES;
    if(tenderListView.itemsArr.count==0)
    {
        [tenderListView firstLoadData];
    }
}

#pragma mark UIScrollViewDelegate
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
        for(id obj in _tenderListViewArr)
        {
            BIDTenderListView *listView = (BIDTenderListView*)obj;
            listView.scrollsToTop = NO;
        }
        BIDTenderListView *tenderListView = (BIDTenderListView*)_tenderListViewArr[page];
        tenderListView.scrollsToTop = YES;
        if(tenderListView.itemsArr.count==0)
        {
            [tenderListView firstLoadData];
        }
        _curPage = page;
        [_segmentedControl setSelectedSegmentIndex:page];
        segmentedIndex = page;
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)
    {
        //登录注册
        BIDLoginAndRegisterViewController *vc = [[BIDLoginAndRegisterViewController alloc] initWithNibName:@"BIDLoginAndRegisterViewController" bundle:nil];
        [self.navigationController setViewControllers:@[vc] animated:YES];
    }
    else
    {
    }
}

@end
/**
 *BIDTenderListView
 */
@interface BIDTenderListView()
{
    BOOL _bRegister;
}
@end
@implementation BIDTenderListView
{
}
@synthesize parentVC;

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.itemsArr.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = indexPath.row;
    NSDictionary *dictionary = self.itemsArr[row];
    static NSString *identifier = @"identifier";
    if(!_bRegister)
    {
        _bRegister = YES;
        UINib *nib = [UINib nibWithNibName:@"BIDTenderCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:identifier];
    }
    BIDTenderCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    BIDTenderView *temporaryTenderView = (BIDTenderView*)[cell.contentView viewWithTag:111];
    if(!temporaryTenderView)
    {
        BIDTenderView *tenderView;
        if([UIScreen mainScreen].bounds.size.height>=568.0f)
        {
            tenderView = (BIDTenderView*)[[[NSBundle mainBundle] loadNibNamed:@"BIDTenderView" owner:self options:nil] lastObject];
            tenderView.frame = CGRectMake(10, 5, 300, 223);
        }
        else
        {
            tenderView = (BIDTenderView*)[[[NSBundle mainBundle] loadNibNamed:@"BIDTenderView320x480" owner:self options:nil] lastObject];
            tenderView.frame = CGRectMake(10, 5, 300, 180);
        }
        tenderView.tag = 111;
        [tenderView initView];
        [cell.contentView addSubview:tenderView];
        temporaryTenderView = tenderView;
    }
    //标的状态
    if(parentVC.segmentedIndex==0 || parentVC.segmentedIndex==1 || parentVC.segmentedIndex==3)
    {
        NSString *strBorrowStatus = [[NSString alloc] initWithFormat:@"%@", [dictionary objectForKey:@"borrowStatus"]];
        temporaryTenderView.tenderStatusLabel.textColor = [UIColor whiteColor];
        if([strBorrowStatus isEqualToString:@"02"])
        {
            temporaryTenderView.tenderProgressLabel.hidden = NO;
            temporaryTenderView.tenderStateLabel.hidden = NO;
            temporaryTenderView.tenderStatusLabel.hidden = YES;
            temporaryTenderView.tenderStatus = STATUS_TENDERRING;
        }
        else if([strBorrowStatus isEqualToString:@"03"])
        {
            temporaryTenderView.tenderProgressLabel.hidden = YES;
            temporaryTenderView.tenderStateLabel.hidden = YES;
            temporaryTenderView.tenderStatusLabel.hidden = NO;
            temporaryTenderView.tenderStatusLabel.textColor = [UIColor whiteColor];
            temporaryTenderView.tenderStatusLabel.text = @"满";
            temporaryTenderView.tenderStatus = STATUS_FULL;
        }
        else if([strBorrowStatus isEqualToString:@"04"])
        {
            temporaryTenderView.tenderProgressLabel.hidden = YES;
            temporaryTenderView.tenderStateLabel.hidden = YES;
            temporaryTenderView.tenderStatusLabel.hidden = NO;
            temporaryTenderView.tenderStatusLabel.textColor = [UIColor whiteColor];
            temporaryTenderView.tenderStatusLabel.text = @"还";
            temporaryTenderView.tenderStatus = STATUS_REPAY;
        }
        else if([strBorrowStatus isEqualToString:@"05"])
        {
            temporaryTenderView.tenderProgressLabel.hidden = YES;
            temporaryTenderView.tenderStateLabel.hidden = YES;
            temporaryTenderView.tenderStatusLabel.hidden = NO;
            temporaryTenderView.tenderStatusLabel.textColor = [UIColor whiteColor];
            temporaryTenderView.tenderStatusLabel.text = @"完";
            temporaryTenderView.tenderStatus = STATUS_REPAID;
        }
        else if([strBorrowStatus isEqualToString:@"07"])
        {
            temporaryTenderView.tenderProgressLabel.hidden = YES;
            temporaryTenderView.tenderStateLabel.hidden = YES;
            temporaryTenderView.tenderStatusLabel.hidden = NO;
            temporaryTenderView.tenderStatusLabel.textColor = [UIColor whiteColor];
            temporaryTenderView.tenderStatusLabel.text = @"预";
            temporaryTenderView.tenderStatus = STATUS_REPAID;
        }
    }
    else
    {
        NSString *strTransferStatus = [dictionary objectForKey:@"debtStatus"];
        temporaryTenderView.tenderStateLabel.textColor = [UIColor whiteColor];
        if([strTransferStatus isEqualToString:@"02"])
        {
            //转让中
            temporaryTenderView.tenderProgressLabel.hidden = YES;
            temporaryTenderView.tenderStateLabel.hidden = YES;
            temporaryTenderView.tenderStatusLabel.hidden = NO;
            temporaryTenderView.tenderStatusLabel.textColor = [UIColor whiteColor];
            temporaryTenderView.tenderStatusLabel.text = @"转";
            temporaryTenderView.tenderStatus = STATUS_TRANSFER;
        }
        else if([strTransferStatus isEqualToString:@"03"])
        {
            //转让成功
            temporaryTenderView.tenderProgressLabel.hidden = YES;
            temporaryTenderView.tenderStateLabel.hidden = YES;
            temporaryTenderView.tenderStatusLabel.hidden = NO;
            temporaryTenderView.tenderStatusLabel.textColor = [UIColor whiteColor];
            temporaryTenderView.tenderStatusLabel.text = @"完";
            temporaryTenderView.tenderStatus = STATUS_REPAID;
        }
    }
    //百分比
    NSInteger tenderProgress = [[dictionary objectForKey:@"pct"] intValue];
    temporaryTenderView.tenderProgress = tenderProgress*1.0f/100.0f;
    temporaryTenderView.tenderProgressLabel.text = [[NSString alloc] initWithFormat:@"%ld%%", (long)tenderProgress];
    [temporaryTenderView refresh];
    //标的状态名
    NSString *strBorrowStatusName = [dictionary objectForKey:@"borrowStatusName"];
    temporaryTenderView.tenderStateLabel.text = strBorrowStatusName;
    //融资金额
    if(parentVC.segmentedIndex==0 || parentVC.segmentedIndex==1 || parentVC.segmentedIndex==3)
    {
        NSString *strAmount = [[NSString alloc] initWithFormat:@"%@", [dictionary objectForKey:@"borrowAmtYuan"]];
        if([strAmount rangeOfString:@"."].location!=NSNotFound && [strAmount rangeOfString:@"."].location>=5)
        {
            temporaryTenderView.amountUnitsLabel.text = @"万元";
            strAmount = [[NSString alloc] initWithFormat:@"%@", [dictionary objectForKey:@"borrowAmtWan"]];
        }
        else if([strAmount rangeOfString:@"."].location==NSNotFound && strAmount.length>=5)
        {
            temporaryTenderView.amountUnitsLabel.text = @"万元";
            strAmount = [[NSString alloc] initWithFormat:@"%@", [dictionary objectForKey:@"borrowAmtWan"]];
        }
        else
        {
            temporaryTenderView.amountUnitsLabel.text = @"元";
        }
        temporaryTenderView.amountNameLable.text = @"融资金额";
        temporaryTenderView.financingAmountLabel.text = strAmount;
    }
    else
    {
        //债权转让
        NSString *strAmount = [[NSString alloc] initWithFormat:@"%@", [dictionary objectForKey:@"dealAmt"]];
        if([BIDCommonMethods isShowWithUnitsYuan:strAmount])
        {
            temporaryTenderView.amountUnitsLabel.text = @"元";
        }
        else
        {
            strAmount = [[NSString alloc] initWithFormat:@"%@", [dictionary objectForKey:@"dealAmtWan"]];
            temporaryTenderView.amountUnitsLabel.text = @"万元";
        }
        temporaryTenderView.amountNameLable.text = @"转让金额";
        temporaryTenderView.financingAmountLabel.text = strAmount;
    }
    UIColor *blueColor = [UIColor colorWithRed:52.0f/255.0f green:152.0f/255.0f blue:219.0f/255.0f alpha:1.0f];
    UIColor *grayColor = [UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f];
    //年化收益率
    NSString *strRate = [[NSString alloc] initWithFormat:@"%@", [dictionary objectForKey:@"annualRate"]];
    strRate = [[NSString alloc] initWithFormat:@"%@%%", strRate];
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:strRate];
    [attributeString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica Neue" size:22.0] range:NSMakeRange(0, strRate.length-1)];
    [attributeString addAttribute:NSForegroundColorAttributeName value:blueColor range:NSMakeRange(0, strRate.length)];
    [attributeString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica Neue" size:11.0] range:NSMakeRange(strRate.length-1, 1)];
    temporaryTenderView.incomeRateLabel.attributedText = attributeString;
    //temporaryTenderView.incomeRateLabel.text = [[NSString alloc] initWithFormat:@"%@%%", strRate];
    //期限
    NSString *strDeadLine = [[NSString alloc] initWithFormat:@"%@", [dictionary objectForKey:@"deadline"]];
    strDeadLine = [[NSString alloc] initWithFormat:@"%@个月", strDeadLine];
    NSMutableAttributedString *deadLineAttribute = [[NSMutableAttributedString alloc] initWithString:strDeadLine];
    [deadLineAttribute addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica Neue" size:22.0] range:NSMakeRange(0, strDeadLine.length-2)];
     [deadLineAttribute addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica Neue" size:11.0] range:NSMakeRange(strDeadLine.length-2, 2)];
    [deadLineAttribute addAttribute:NSForegroundColorAttributeName value:blueColor range:NSMakeRange(0, strDeadLine.length-2)];
    [deadLineAttribute addAttribute:NSForegroundColorAttributeName value:grayColor range:NSMakeRange(strDeadLine.length-2, 2)];
    //temporaryTenderView.deadLineLabel.text = [[NSString alloc] initWithFormat:@"%@", [dictionary objectForKey:@"deadline"]];
    temporaryTenderView.deadLineLabel.attributedText = deadLineAttribute;
    //标题
    temporaryTenderView.companyNameLabel.text = [dictionary objectForKey:@"borrowName"];
    //信用等级
    NSString *strCreditLevel = [[NSString alloc] initWithFormat:@"%@", [dictionary objectForKey:@"creditLevel"]];
    if([strCreditLevel isEqualToString:@"1"]) temporaryTenderView.creditLabel.text = @"A";
    else if([strCreditLevel isEqualToString:@"2"]) temporaryTenderView.creditLabel.text = @"AA";
    else if([strCreditLevel isEqualToString:@"3"]) temporaryTenderView.creditLabel.text = @"AAA";
    else if([strCreditLevel isEqualToString:@"4"]) temporaryTenderView.creditLabel.text = @"AAAA";
    else if([strCreditLevel isEqualToString:@"5"]) temporaryTenderView.creditLabel.text = @"AAAAA";
    //标类型
    NSString *strTenderType = [dictionary objectForKey:@"bidType"];
    if([strTenderType isEqualToString:@"01"])
    {
        //定向融资
        temporaryTenderView.rightBottomImgView.image = nil;
    }
    else if([strTenderType isEqualToString:@"02"])
    {
        //新手标
        temporaryTenderView.rightBottomImgView.image = [UIImage imageNamed:@"newbieTender.png"];
    }
    else if([strTenderType isEqualToString:@"03"])
    {
        //普通标
        temporaryTenderView.rightBottomImgView.image = nil;
    }
    if(parentVC.segmentedIndex==2)
    {
        temporaryTenderView.rightBottomImgView.image = nil;
    }
    if(parentVC.segmentedIndex==3)
    {
        temporaryTenderView.rightTopImgView.hidden = NO;
    }
    //开标时间
    //if(parentVC.segmentedIndex==1 || parentVC.segmentedIndex==3)
    if(parentVC.segmentedIndex==3)
    {
        temporaryTenderView.publishTenderDateLabel.hidden = NO;
        NSString *strPublishDate;
        //新标预告列表中的标显示的开标时间
        strPublishDate = [dictionary objectForKey:@"defaultOpenTime"];
        temporaryTenderView.publishTenderDateLabel.text = [[NSString alloc] initWithFormat:@"开标时间: %@", strPublishDate];
    }
    else
    {
        temporaryTenderView.publishTenderDateLabel.hidden = YES;
    }
    //抵押类型
    NSString *strMorgageType = [dictionary objectForKey:@"borrowType"];
    [temporaryTenderView setMortgageFlag:strMorgageType];
    //
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([UIScreen mainScreen].bounds.size.height>=568.0f)
    {
        return 233.0f;
    }
    else
    {
        return 190.0f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUInteger row = indexPath.row;
    NSDictionary *dictionary = self.itemsArr[row];
    if(parentVC.segmentedIndex==2)
    {
        //债权转让详情
        BIDCreditRightTransferView *vc = [[BIDCreditRightTransferView alloc] init];
        vc.creditRightTransferId = [dictionary objectForKey:@"id"];
        [self.parentVC.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        BIDTenderDetailInfoViewController *infoVC = [[BIDTenderDetailInfoViewController alloc] init];
        infoVC.tenderId = [dictionary objectForKey:@"bid"];
        if(parentVC.segmentedIndex==1)
        {
            infoVC.bIsGroupTender = YES;
        }
        else if(parentVC.segmentedIndex==3)
        {
            infoVC.bIsPredictTender = YES;
            infoVC.predictTime = [dictionary objectForKey:@"defaultOpenTime"];
        }
        else
        {
            infoVC.bIsPredictTender = NO;
            infoVC.bIsGroupTender = NO;
        }
        infoVC.mortgateType = [dictionary objectForKey:@"borrowType"];
        [self.parentVC.navigationController pushViewController:infoVC animated:YES];
    }
}

@end

//
//  BIDTenderDetailInfoViewController.m
//  zhongrongbao
//
//  Created by mal on 14-8-15.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDTenderDetailInfoViewController.h"
#import "BIDBottomView.h"
#import "BIDShareView.h"
#import "BIDAppDelegate.h"
#import "BIDEnterpriseBriefIntroductionView.h"
#import "BIDCustomCell.h"
#import "BIDEnterpriseInfoCell.h"
#import "BIDEnterpriseInfoView.h"
#import "BIDFinancialStatusView.h"
#import "BIDGuaranteeInfoView.h"
#import "BIDRepaymentPlanView.h"
#import "BIDCustomSpinnerView.h"
#import "BIDCommonMethods.h"
#import "BIDDataCommunication.h"
#import "BIDExpandCell.h"
#import "BIDTenderConditionView.h"
#import "BIDTextCell.h"
#import "BIDLoginAndRegisterViewController.h"
#import "BIDWebPageJumpViewController.h"
#import "BIDOpenHFTXViewController.h"
#import "BIDLoginViewController.h"
#import "BIDManagerInNavViewController.h"
/**
 *tableview的section的高度
 */
const CGFloat kSectionHeight = 44.0f;
/**
 *tableview cell中的字体大小
 */
const CGFloat kCellFontSize = 15.0f;

/**
 *获取标详情
 */
static NSString *strTenderDetailInfoURL = @"borrow/queryBorrowDtl.shtml";
/**
 *获取还款计划列表
 */
static NSString *strRepaymentPlanURL = @"borrow/borrowRepayment.shtml";
/**
 *投标情况列表
 */
static NSString *strTenderConditionURL = @"borrow/queryInvestList.shtml";
/**
 *投标
 */
static NSString *strTenderURL = @"UserPnr/InitiativeTender.shtml";
/**
 *查询客户汇付天下账户信息
 */
static NSString *strQueryUserAccountInfoURL = @"UserPay/PnrCount.shtml";

@interface BIDTenderDetailInfoViewController ()<BIDShareViewDelegate, BIDEnterpriseBriefIntroductionViewDelegate, BIDEnterpriseInfoViewDelegate, BIDGuaranteeInfoViewDelegate, BIDBottomViewDelegate, UIAlertViewDelegate>
{
    NSArray *_titlesArr;
    BIDBottomView *_bottomView;
    BIDBottomView *_bottomView1;
    BIDBottomView *_bottomView2;
    /**
     *分享视图
     */
    //BIDShareView *_shareView;
    NSMutableArray *_cellHeightArr;
    /**
     *公司简介(借款概述)
     */
    BIDEnterpriseBriefIntroductionView *_enterpriseBriefIntroductionView;
    /**
     *风险担保方案
     */
    BIDEnterpriseBriefIntroductionView *_guaranteeProjectView;
    /**
     *企业信息
     */
    BIDEnterpriseInfoView *_enterpriseInfoView;
    /**
     *财务状况
     */
    BIDFinancialStatusView *_financialStatusView;
    /**
     *担保信息
     */
    BIDGuaranteeInfoView *_guaranteeInfoView;
    /**
     *还款计划
     */
    BIDRepaymentPlanView *_repaymentPlanView;
    /**
     *投标情况
     */
    BIDTenderConditionView *_tenderConditionView;
    //
    BOOL _bRegister;
    BIDCustomSpinnerView *_spinnerView;
    /**
     *tableview的section分类
     */
    NSArray *_sectionArr;
    /**
     *标的基本信息
     */
    NSMutableArray *_tenderBaseInfoArr;
    /**
     *风险控制
     */
    NSMutableArray *_riskControlArr;
    /**
     *项目信息
     */
    NSMutableArray *_projectInfoArr;
    /**
     *企业信息
     */
    NSMutableArray *_enterpriseInfoArr;
    /**
     *抵质押信息
     */
    NSMutableArray *_guaranteeInfoArr;
    /**
     *还款计划视图的高度
     */
    NSNumber *_repaymentPlanHeightValue;
    /**
     *投标情况视图的高度
     */
    NSNumber *_tenderConditionHeightValue;
    /**
     *可投金额
     */
    NSString *_canInvestAmt;
    /**
     *可用余额
     */
    NSString *_leftAmt;
    /**
     *是否注册了汇付天下
     */
    BOOL _bRegisterHFTX;
    /**
     *标类型(普通标、集团标、新手标)
     */
    NSString *_bidType;
}

@end

@implementation BIDTenderDetailInfoViewController

@synthesize tenderName;
@synthesize tenderStartTime;
@synthesize companyContent;
@synthesize financingAmount;
@synthesize incomeRate;
@synthesize financingDuration;
@synthesize repaymentDate;
@synthesize haveFinancing;
@synthesize leftFinancing;
@synthesize leftTime;
@synthesize enterpriseBriefIntroduction;
@synthesize bIsGroupTender;
@synthesize bIsPredictTender;
@synthesize predictTime;

@synthesize tenderId;
@synthesize mortgateType;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"标详情";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _canInvestAmt = @"0.0";
    _leftAmt = @"0.0";
    _bidType = @"";
    //
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsSelection = NO;
    _spinnerView = [[BIDCustomSpinnerView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    [_spinnerView initLayout];
    //返回按钮设置
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backBtnHandler)];
    //
    [self.tableView setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:240.0f/255.0f blue:241.0f/255.0f alpha:1.0f]];
    //
    _titlesArr = @[@"融资金额", @"年化收益", @"融资期限", @"还款日期", @"已融金额", @"可投金额", @"剩余时间"];
    _cellHeightArr = [[NSMutableArray alloc] init];
    //
    for(int i=0; i<7; i++)
    {
        NSNumber *value = [NSNumber numberWithFloat:44.0f];
        [_cellHeightArr addObject:value];
    }
    //
    [self prepareForData];
    //初始化底部视图
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    //集团标
    _bottomView1 = (BIDBottomView*)[[[NSBundle mainBundle] loadNibNamed:@"BIDBottomView2" owner:self options:nil] lastObject];
    _bottomView1.isGroupTender = YES;
    [_bottomView1 initView];
    _bottomView1.delegate = self;
    CGRect bottomViewFrame1 = CGRectMake(0, screenSize.height-CGRectGetHeight(_bottomView1.frame), CGRectGetWidth(_bottomView1.frame), CGRectGetHeight(_bottomView1.frame));
    _bottomView1.frame = bottomViewFrame1;
    _bottomView1.hidden = YES;
    //新标预告
    _bottomView2 = (BIDBottomView*)[[[NSBundle mainBundle] loadNibNamed:@"BIDBottomView3" owner:self options:nil] lastObject];
    [_bottomView2 initView];
    _bottomView2.delegate = self;
    CGRect bottomViewFrame2 = CGRectMake(0, screenSize.height-CGRectGetHeight(_bottomView2.frame), CGRectGetWidth(_bottomView2.frame), CGRectGetHeight(_bottomView2.frame));
    _bottomView2.frame = bottomViewFrame2;
    _bottomView2.predictTimeLabel.text = [[NSString alloc] initWithFormat:@"预计开标时间 %@", predictTime];
    _bottomView2.hidden = YES;
    //普通标
    _bottomView = (BIDBottomView*)[[[NSBundle mainBundle] loadNibNamed:@"BIDBottomView" owner:self options:nil] lastObject];
    _bottomView.isGroupTender = NO;
    [_bottomView initView];
    _bottomView.delegate = self;
    CGRect bottomViewFrame = CGRectMake(0, screenSize.height-CGRectGetHeight(_bottomView.frame), CGRectGetWidth(_bottomView.frame), CGRectGetHeight(_bottomView.frame));
    _bottomView.frame = bottomViewFrame;
    _bottomView.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
}

- (void)viewDidAppear:(BOOL)animated
{
    //监听键盘
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [_tenderBaseInfoArr removeAllObjects];
    [_riskControlArr removeAllObjects];
    [_projectInfoArr removeAllObjects];
    [_enterpriseInfoArr removeAllObjects];
    [_guaranteeInfoArr removeAllObjects];
    //
    UIWindow *keyWindow = [BIDAppDelegate getKeyWindow];
    [keyWindow makeKeyAndVisible];
    if(_bottomView) [keyWindow addSubview:_bottomView];
    if(_bottomView1) [keyWindow addSubview:_bottomView1];
    if(_bottomView2) [keyWindow addSubview:_bottomView2];
    //
    [self getTenderDetailInfo];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    if(_bottomView) [_bottomView clearData];
    if(_bottomView1) [_bottomView1 clearData];
    [_bottomView removeFromSuperview];
    [_bottomView1 removeFromSuperview];
    [_bottomView2 removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    if(parent && [parent isKindOfClass:[BIDManagerInNavViewController class]])
    {
        parent.navigationItem.title = @"标详情";
        parent.navigationItem.rightBarButtonItem = nil;
    }
}

/**
 *初始化标底视图
 */
- (void)initBottomView
{
    if(bIsPredictTender)
    {
        //新标预告
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 54, 0);
        _bottomView2.hidden = NO;
    }
    else
    {
        if([_bidType isEqualToString:@"01"])
        {
            //集团标
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 120, 0);
            _bottomView1.hidden = NO;
        }
        else if([_bidType isEqualToString:@"03"] || [_bidType isEqualToString:@"02"])
        {
            //普通标
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 76, 0);
            _bottomView.hidden = NO;
        }
    }
}

/**
 *准备数据
 */
- (void)prepareForData
{
    //_sectionArr = @[@"", @"风险控制", @"项目信息", @"企业信息", @"抵质押信息", @"还款计划", @"投标情况"];
    //2015-4-20
    _sectionArr = @[@"", @"项目信息", @"企业信息", @"抵质押信息", @"还款计划", @"投标情况"];
    //2015-4-20
    _tenderBaseInfoArr = [[NSMutableArray alloc] initWithCapacity:8];
    _riskControlArr = [[NSMutableArray alloc] initWithCapacity:4];
    _projectInfoArr = [[NSMutableArray alloc] initWithCapacity:5];
    _enterpriseInfoArr = [[NSMutableArray alloc] initWithCapacity:1];
    _guaranteeInfoArr = [[NSMutableArray alloc] initWithCapacity:1];
}
/**
 *获取标详情
 */
- (void)getTenderDetailInfo
{
    //用户汇付账户信息(此处用于获取可用余额)
    NSMutableDictionary *userAmtInfoDictionary = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *tenderInfoDictionary = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *repaymentPlanDictionary = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *tenderConditionDictionary = [[NSMutableDictionary alloc] init];
    //
    NSString *strUserAmtInfoURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strQueryUserAccountInfoURL];
    //标的基本信息
    NSString *strURL1 = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strTenderDetailInfoURL];
    //还款计划
    NSString *strURL2 = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strRepaymentPlanURL];
    //投标情况
    NSString *strURL3 = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strTenderConditionURL];
    NSString *strPost = [[NSString alloc] initWithFormat:@"jsonDataSet={\"bid\":\"%@\"}", tenderId];
    NSString *strPost1 = [[NSString alloc] initWithFormat:@"jsonDataSet={\"bid\":\"%@\", \"page.currentPage\":\"%d\"}", tenderId, 1];
    _spinnerView.content = @"";
    [_spinnerView showTheView];
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        //获取用户汇付信息
        [BIDDataCommunication getDataFromNet:strUserAmtInfoURL toDictionary:userAmtInfoDictionary];
    });
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        //获取标的基本信息
        [BIDDataCommunication uploadDataByPostToURL:strURL1 postValue:strPost toDictionary:tenderInfoDictionary];
    });
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        //获取还款计划
        [BIDDataCommunication uploadDataByPostToURL:strURL2 postValue:strPost toDictionary:repaymentPlanDictionary];
    });
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        //获取投标情况
        [BIDDataCommunication uploadDataByPostToURL:strURL3 postValue:strPost1 toDictionary:tenderConditionDictionary];
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        //
        [_spinnerView dismissTheView];
        if([[tenderInfoDictionary objectForKey:@"json"] isEqualToString:@"success"])
        {
            NSDictionary *subDictionary = [tenderInfoDictionary objectForKey:@"data"];
            _bidType = [subDictionary objectForKey:@"bidType"];
            [self initBottomView];
            tenderName = [subDictionary objectForKey:@"borrowName"];
            self.mortgateType = [subDictionary objectForKey:@"borrowType"];
            self.tableView.tableHeaderView = [self prepareForTenderHeaderView];
            //获取标的基本信息
            [self getTenderBaseInfo:subDictionary];
            //获取风险控制信息
            [self getRiskControlInfo:subDictionary];
            //获取项目信息
            [self getProjectInfo:subDictionary];
            //获取企业信息
            [self getEnterpriseInfo:subDictionary];
            //获取抵质押信息
            [self getGuaranteeInfo:subDictionary];
        }
        //
        if([[repaymentPlanDictionary objectForKey:@"json"] isEqualToString:@"success"])
        {
            NSArray *planArr = [repaymentPlanDictionary objectForKey:@"dataList"];
            _repaymentPlanHeightValue = [self prepareForRepaymentPlanView:planArr];
        }
        //
        if([[tenderConditionDictionary objectForKey:@"json"] isEqualToString:@"success"])
        {
            NSArray *conditionArr = [tenderConditionDictionary objectForKey:@"dataList"];
            _tenderConditionHeightValue = [self prepareForTenderConditionView:conditionArr];
        }
        //
        if([[userAmtInfoDictionary objectForKey:@"json"] isEqualToString:@"success"])
        {
            [self getUserLeftAmt:[userAmtInfoDictionary objectForKey:@"data"]];
        }
        //
        if(![BIDAppDelegate isHaveLogin])
        {
            [_bottomView setCanInvestAmt:_canInvestAmt leftAmt:@"0.0"];
            [_bottomView1 setCanInvestAmt:_canInvestAmt leftAmt:@"0.0"];
        }
        else
        {
            [_bottomView setCanInvestAmt:_canInvestAmt leftAmt:_leftAmt];
            [_bottomView1 setCanInvestAmt:_canInvestAmt leftAmt:_leftAmt];
        }
        //
        [self.tableView reloadData];
    });
}
/**
 *获取可用余额
 */
- (void)getUserLeftAmt:(NSDictionary*)subDictionary
{
    if([[subDictionary objectForKey:@"pnrStatus"] isEqualToString:@"N"])
    {
        //未注册
        _leftAmt = @"0.0";
    }
    else
    {
        //
        CGFloat availableAmt = [[subDictionary objectForKey:@"avaiableAmt"] floatValue];
        NSString *strAvailabelAmt = [[NSString alloc] initWithFormat:@"%.2f", availableAmt];
        _leftAmt = [[NSString alloc] initWithFormat:@"%@元", strAvailabelAmt];
//        if(![BIDCommonMethods isShowWithUnitsYuan:strAvailabelAmt])
//        {
//            strAvailabelAmt = [[NSString alloc] initWithFormat:@"%@", [subDictionary objectForKey:@"avaiableAmtMillion"]];
//            _leftAmt = [[NSString alloc] initWithFormat:@"%@万元", strAvailabelAmt];
//        }
//        else
//        {
//            _leftAmt = [[NSString alloc] initWithFormat:@"%@元", strAvailabelAmt];
//        }
    }
}
/**
 *获取标的基本信息
 */
- (void)getTenderBaseInfo:(NSDictionary*)subDictionary
{
    NSString *strTitle = @"";
    NSString *strContent = @"";
    //获取标的基本信息
    //借款日期（新标预告的借款日期对应的字段和其他类型的标对应的字段不同，新标预告的为defaultOpenTime）
    strTitle = @"借款日期";
    strContent = [subDictionary objectForKey:@"publishTime"];
    NSDictionary *dictionary1 = @{@"title":strTitle, @"content":strContent, @"height":@0};
    //融资金额
    strTitle = @"融资金额";
    strContent = [[NSString alloc] initWithFormat:@"%@万元",[subDictionary objectForKey:@"borrowAmt"]];
    NSDictionary *dictionary2 = @{@"title":strTitle, @"content":strContent, @"height":@0};
    //年化收益
    strTitle = @"年化收益";
    strContent = [[NSString alloc] initWithFormat:@"%@%%", [subDictionary objectForKey:@"annualRate"]];
    NSDictionary *dictionary3 = @{@"title":strTitle, @"content":strContent, @"height":@0};
    //融资期限
    strTitle = @"融资期限";
    strContent = [[NSString alloc] initWithFormat:@"%@个月", [subDictionary objectForKey:@"deadline"]];
    NSDictionary *dictionary4 = @{@"title":strTitle, @"content":strContent, @"height":@0};
    //已融金额
    CGFloat borrowAmt = [[subDictionary objectForKey:@"borrowAmt"] floatValue];
    CGFloat canInvestAmt = [[subDictionary objectForKey:@"canInvestAmt"] floatValue];
    CGFloat borrowedAmt = borrowAmt*10000 - canInvestAmt;
    NSString *strCanInvestAmt = [[NSString alloc] initWithFormat:@"%.2f 元", canInvestAmt];
    //可投金额
    _canInvestAmt = strCanInvestAmt;

    strTitle = @"已融金额";
    strContent = [[NSString alloc] initWithFormat:@"%.2f元", borrowedAmt];
    NSDictionary *dictionary5 = @{@"title":strTitle, @"content":strContent, @"height":@0};
    //投标范围
    NSString *strMinAmt = [[NSString alloc] initWithFormat:@"%@", [subDictionary objectForKey:@"minBidAmt"]];
    NSString *strMaxAmt = [[NSString alloc] initWithFormat:@"%@", [subDictionary objectForKey:@"maxBidAmt"]];
    strTitle = @"投标范围";
    strContent = [[NSString alloc] initWithFormat:@"%@元--%@元", strMinAmt, strMaxAmt];
    NSDictionary *dictionary6 = @{@"title":strTitle, @"content":strContent, @"height":@0};
    //剩余时间
    /**
     *如果返回的字段"examineTime"为空，则显示剩余时间，如果字段不为空，则显示满标时间
     */
    NSString *strEndTime = [subDictionary objectForKey:@"closingTime"];
    NSString *strFullTime = [subDictionary objectForKey:@"examineTime"];
    if(strFullTime.length>0)
    {
        strTitle = @"满标时间";
        strContent = strFullTime;
    }
    else
    {
        strTitle = @"剩余时间";
        strContent = [self getRemainTime:strEndTime];
    }
    NSDictionary *dictionary7 = @{@"title":strTitle, @"content":strContent, @"height":@0};
    //借款概述
    NSString *strSummary = [subDictionary objectForKey:@"borrowSummary"];
    strTitle = @"";
    strContent = strSummary;
    NSNumber *heightValue = [self prepareForBorrowSummaryView:strContent];
    NSDictionary *dictionary8 = @{@"title":strTitle, @"content":strContent, @"height":heightValue};
    //
    [_tenderBaseInfoArr addObject:dictionary1];
    [_tenderBaseInfoArr addObject:dictionary2];
    [_tenderBaseInfoArr addObject:dictionary3];
    [_tenderBaseInfoArr addObject:dictionary4];
    [_tenderBaseInfoArr addObject:dictionary5];
    [_tenderBaseInfoArr addObject:dictionary6];
    [_tenderBaseInfoArr addObject:dictionary7];
    [_tenderBaseInfoArr addObject:dictionary8];
    //
    if([[subDictionary objectForKey:@"borrowStatus"] isEqualToString:@"05"] || [[subDictionary objectForKey:@"borrowStatus"] isEqualToString:@"04"])
    {
        //该标已还完,则输入金额框不可操作
        [_bottomView disableTenderBtn];
        [_bottomView1 disableTenderBtn];
    }
}
/**
 *计算投标截止时间与当前时间的差值
 */
- (NSString*)getRemainTime:(NSString*)endTime
{
    NSMutableString *strRemainTime = [[NSMutableString alloc] init];
    //获取当前时间
    NSDate *curDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd H:mm:ss"];
    NSDate *endDate = [dateFormatter dateFromString:endTime];
    NSTimeInterval timeInterval = [endDate timeIntervalSinceDate:curDate];
    long long seconds = [[NSNumber numberWithDouble:timeInterval] longLongValue];
    if(timeInterval<0)
    {
        [strRemainTime appendString:@"已开始"];
    }
    else
    {
        long daySeconds = 60 * 60 * 24;
        int hourSeconds = 60 * 60;
        int minuteSeconds = 60;
        int days = (int)(seconds / daySeconds);
        if(days>0)
        {
            [strRemainTime appendFormat:@"%d天", days];
            seconds = seconds % daySeconds;
        }
        int hours = (int)(seconds / hourSeconds);
        if(hours>0)
        {
            [strRemainTime appendFormat:@"%d小时", hours];
            seconds = seconds % hourSeconds;
        }
        int minutes = (int)(seconds / minuteSeconds);
        [strRemainTime appendFormat:@"%d分", minutes];
    }
    return strRemainTime;
}
/**
 *获取风险控制信息
 */
- (void)getRiskControlInfo:(NSDictionary*)subDictionary
{
    NSString *strTitle = @"";
    NSString *strContent = @"";
    CGFloat contentHeight = 0.0f;
    CGFloat constraintWidth = CGRectGetWidth(self.view.frame)-14*2-73;
    CGSize constraintSize = CGSizeMake(constraintWidth, MAXFLOAT);
    UIFont *font = [UIFont systemFontOfSize:kCellFontSize];
    //担保方
    //strTitle = @"担保方:";
    //strContent = [subDictionary objectForKey:@"guaranteeInc"];
    //NSDictionary *dictionary1 = @{@"title":strTitle, @"content":strContent, @"height":@0};
    //担保情况
    strTitle = @"担保情况:";
    strContent = [subDictionary objectForKey:@"guaranteeInc"];
    strContent = [BIDCommonMethods filterHTML:strContent];
    contentHeight = [BIDCommonMethods getHeightWithString:strContent font:font constraintSize:constraintSize];
    NSDictionary *dictionary2 = @{@"title":strTitle, @"content":strContent, @"height":[NSNumber numberWithFloat:contentHeight]};
    //担保公司
    strTitle = @"担保公司:";
    strContent = [subDictionary objectForKey:@"comNameCn"];
    contentHeight = [BIDCommonMethods getHeightWithString:strContent font:font constraintSize:constraintSize];
    NSDictionary *dictionary3 = @{@"title":strTitle, @"content":strContent, @"height":[NSNumber numberWithFloat:contentHeight]};
    //担保方式
    strTitle = @"担保方式:";
    strContent = [subDictionary objectForKey:@"guaranteeTypeName"];
    contentHeight = [BIDCommonMethods getHeightWithString:strContent font:font constraintSize:constraintSize];
    NSDictionary *dictionary4 = @{@"title":strTitle, @"content":strContent, @"height":[NSNumber numberWithFloat:contentHeight]};
    //担保方案
    strTitle = @"项目风险保障方案:";
    strContent = [subDictionary objectForKey:@"guaranteeDes"];
    strContent = [BIDCommonMethods filterHTML:strContent];
    NSNumber *heightValue = [self prepareForGuaranteeProjectView:[[NSString alloc] initWithFormat:@"%@\r\r   %@", strTitle, strContent]];
    NSDictionary *dictionary5 = @{@"title":strTitle, @"content":strContent, @"height":heightValue};
    //
    //[_riskControlArr addObject:dictionary1];
    [_riskControlArr addObject:dictionary2];
    [_riskControlArr addObject:dictionary3];
    [_riskControlArr addObject:dictionary4];
    [_riskControlArr addObject:dictionary5];
}
/**
 *获取项目信息
 */
- (void)getProjectInfo:(NSDictionary*)subDictionary
{
    NSString *strTitle = @"";
    NSString *strContent = @"";
    //融资企业
    strTitle = @"融资企业";
    strContent = [subDictionary objectForKey:@"borrowUserName"];
    NSDictionary *dictionary1 = @{@"title":strTitle, @"content":strContent, @"height":@0};
    //借款用途
    strTitle = @"借款用途";
    strContent = [subDictionary objectForKey:@"moneyPurposes"];
    NSDictionary *dictionary2 = @{@"title":strTitle, @"content":strContent, @"height":@0};
    //融资企业代理人
    strTitle = @"融资企业代理人";
    strContent = [subDictionary objectForKey:@"borrowman"];
    NSDictionary *dictionary3 = @{@"title":strTitle, @"content":strContent, @"height":@0};
    //还款来源
    strTitle = @"还款来源";
    strContent = [subDictionary objectForKey:@"repaymentSource"];
    NSDictionary *dictionary4 = @{@"title":strTitle, @"content":strContent, @"height":@0};
    //项目区域位置
    strTitle = @"项目区域位置";
    strContent = [subDictionary objectForKey:@"borrowLocation"];
    NSDictionary *dictionary5 = @{@"title":strTitle, @"content":strContent, @"height":@0};
    //
    [_projectInfoArr addObject:dictionary1];
    [_projectInfoArr addObject:dictionary2];
    [_projectInfoArr addObject:dictionary3];
    [_projectInfoArr addObject:dictionary4];
    [_projectInfoArr addObject:dictionary5];
}
/**
 *获取企业信息
 */
- (void)getEnterpriseInfo:(NSDictionary*)subDictionary
{
    NSString *strTitle = @"";
    NSString *strContent = [subDictionary objectForKey:@"companyAnalysis"];
    strContent = [BIDCommonMethods filterHTML:strContent];
    CGFloat contentHeight = [BIDCommonMethods getHeightWithString:strContent font:[UIFont systemFontOfSize:kCellFontSize] constraintSize:CGSizeMake(CGRectGetWidth(self.view.frame)-14*2, MAXFLOAT)];
    NSDictionary *dictionary = @{@"title":strTitle, @"content":strContent, @"height":[NSNumber numberWithFloat:contentHeight]};
    [_enterpriseInfoArr addObject:dictionary];
}
/**
 *获取抵质押信息
 */
- (void)getGuaranteeInfo:(NSDictionary*)subDictionary
{
    NSString *strTitle = @"";
    NSString *strContent = [subDictionary objectForKey:@"businessAnalysis"];
    strContent = [BIDCommonMethods filterHTML:strContent];
    CGFloat contentHeight = [BIDCommonMethods getHeightWithString:strContent font:[UIFont systemFontOfSize:kCellFontSize] constraintSize:CGSizeMake(CGRectGetWidth(self.view.frame)-14*2, MAXFLOAT)];
    NSDictionary *dictionary = @{@"title":strTitle, @"content":strContent, @"height":[NSNumber numberWithFloat:contentHeight]};
    [_guaranteeInfoArr addObject:dictionary];
}
//借款概述和担保方案用的是同一个view类（原公司简介视图），并没有重新单独设计，类名字可能有些别扭
/**
 *公司简介(借款概述)
 */
- (NSNumber*)prepareForBorrowSummaryView:(NSString*)strBorrowSummary
{
    _enterpriseBriefIntroductionView = (BIDEnterpriseBriefIntroductionView*)[[[NSBundle mainBundle] loadNibNamed:@"BIDEnterpriseBriefIntroductionView" owner:self options:nil] lastObject];
    [_enterpriseBriefIntroductionView setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:240.0f/255.0f blue:241.0f/255.0f alpha:1.0f]];
    _enterpriseBriefIntroductionView.tag = 100;
    _enterpriseBriefIntroductionView.delegate = self;
    _enterpriseBriefIntroductionView.section = 0;
    _enterpriseBriefIntroductionView.row = 7;
    _enterpriseBriefIntroductionView.enterpriseBriefIntroduction = strBorrowSummary;
    CGRect frame = _enterpriseBriefIntroductionView.frame;
    frame.origin.x = 0;
    frame.origin.y = 10;
    _enterpriseBriefIntroductionView.frame = frame;
    NSNumber *value = [NSNumber numberWithFloat:CGRectGetHeight(_enterpriseBriefIntroductionView.frame)];
    return value;
}
/**
 *担保方案
 */
- (NSNumber*)prepareForGuaranteeProjectView:(NSString*)strGuaranteeProject
{
    _guaranteeProjectView = (BIDEnterpriseBriefIntroductionView*)[[[NSBundle mainBundle] loadNibNamed:@"BIDEnterpriseBriefIntroductionView" owner:self options:nil] lastObject];
    [_guaranteeProjectView setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:240.0f/255.0f blue:241.0f/255.0f alpha:1.0f]];
    _guaranteeProjectView.tag = 100;
    _guaranteeProjectView.delegate = self;
    _guaranteeProjectView.section = 1;
    _guaranteeProjectView.row = 3;
    _guaranteeProjectView.enterpriseBriefIntroduction = strGuaranteeProject;
    NSNumber *value = [NSNumber numberWithFloat:CGRectGetHeight(_guaranteeProjectView.frame)];
    return value;
}
/**
 *企业信息
 */
- (void)prepareForEnterpriseInfoView
{
    _enterpriseInfoView = (BIDEnterpriseInfoView*)[[[NSBundle mainBundle] loadNibNamed:@"BIDEnterpriseInfoView" owner:self options:nil] lastObject];
    [_enterpriseInfoView setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:240.0f/255.0f blue:241.0f/255.0f alpha:1.0f]];
    _enterpriseInfoView.tag = 101;
    _enterpriseInfoView.delegate = self;
    _enterpriseInfoView.registerYearsLabel.text = @"7年";
    _enterpriseInfoView.registerCapitalLabel.text = @"300万元";
    _enterpriseInfoView.netAssetValueLabel.text = @"1571万元";
    _enterpriseInfoView.industryLabel.text = @"批发零售";
    _enterpriseInfoView.cashInflowsLabel.text = @"3225万元";
    _enterpriseInfoView.operatingCondition = companyContent;
    _enterpriseInfoView.lawsuitCondition = @"通过全国法院被执行人信息查询系统、全国法院失信被执行人名单信息公布与查询平台及互联网搜索，未发现借款人及企业涉诉信息。";
    _enterpriseInfoView.creditRegistries = @"通过人民银行征信报告显示，借款人及企业近5年内，未发生过逾期资信良好。";
    [_enterpriseInfoView setLayout];
    NSNumber *value = [NSNumber numberWithFloat:CGRectGetHeight(_enterpriseInfoView.frame)];
    [_cellHeightArr addObject:value];
}
/**
 *财务状况
 */
- (void)prepareForFinancialStatusView
{
    _financialStatusView = (BIDFinancialStatusView*)[[[NSBundle mainBundle] loadNibNamed:@"BIDFinancialStatusView" owner:self options:nil] lastObject];
    _financialStatusView.tag = 102;
    NSArray *arr = @[@"年份", @"主营收入(万)", @"毛利润(万)", @"净利润(万)", @"总资产(万)", @"净资产(万)", @"备注"];
    [_financialStatusView initViewWithArr:arr];
    NSNumber *value = [NSNumber numberWithFloat:CGRectGetHeight(_financialStatusView.frame)];
    [_cellHeightArr addObject:value];
}
/**
 *担保信息
 */
- (void)prepareForGuaranteeView
{
    _guaranteeInfoView = (BIDGuaranteeInfoView*)[[[NSBundle mainBundle] loadNibNamed:@"BIDGuaranteeInfoView" owner:self options:nil] lastObject];
    [_guaranteeInfoView initView];
    _guaranteeInfoView.tag = 103;
    _guaranteeInfoView.delegate = self;
    _guaranteeInfoView.securedPartyLabel.text = @"济南担保公司担保";
    _guaranteeInfoView.guaranteeLabel.text = @"金盾担保方案";
    _guaranteeInfoView.doubleGuaranteeLabel.text = @"金盾担保方案";
    NSNumber *value = [NSNumber numberWithFloat:CGRectGetHeight(_guaranteeInfoView.frame)];
    [_cellHeightArr addObject:value];
}
/**
 *还款计划
 */
- (NSNumber*)prepareForRepaymentPlanView:(NSArray*)planArr
{
    NSArray *arr = @[@"规定还款日期", @"实际还款日期", @"还款状态", @"还款类型", @"还款金额", @"是否逾期", @"罚金"];
    _repaymentPlanView = (BIDRepaymentPlanView*)[[[NSBundle mainBundle] loadNibNamed:@"BIDRepaymentPlanView" owner:self options:nil] lastObject];
    [_repaymentPlanView initViewWithTitles:arr infoArr:planArr];
    _repaymentPlanView.tag = 104;
    NSNumber *value = [NSNumber numberWithFloat:CGRectGetHeight(_repaymentPlanView.frame)];
    //[_cellHeightArr addObject:value];
    return value;
}
/**
 *投标情况
 */
- (NSNumber*)prepareForTenderConditionView:(NSArray*)infoArr
{
    NSArray *titlesArr = @[@"投资时间", @"投资人", @"投资金额"];
    _tenderConditionView = (BIDTenderConditionView*)[[[NSBundle mainBundle] loadNibNamed:@"BIDTenderConditionView" owner:self options:nil] lastObject];
    [_tenderConditionView initViewWithTitles:titlesArr infoArr:infoArr];
    _tenderConditionView.tag = 105;
    NSNumber *value = [NSNumber numberWithFloat:CGRectGetHeight(_tenderConditionView.frame)];
    return value;
}

/**
 *返回按钮
 */
- (void)backBtnHandler
{
    [_bottomView removeFromSuperview];
    //[_shareView hideShareView];
    [self.navigationController popViewControllerAnimated:YES];
}
/**
 *标底视图的显示与隐藏
 */
- (void)showBottomView
{
    UIView *desView = nil;
    if(_bottomView) desView = _bottomView;
    else if(_bottomView1) desView = _bottomView1;
    else if(_bottomView2) desView = _bottomView2;

    [(BIDBottomView*)desView removeMaskView];
    [UIView animateWithDuration:0.5f animations:^{
        CGRect frame = desView.frame;
        frame.origin.x -= kSlideDistance;
        desView.frame = frame;
    } completion:^(BOOL finished){
        if(finished)
        {
            
        }
    }];
}
- (void)hideBottomView
{
    UIView *desView = nil;
    if(_bottomView) desView = _bottomView;
    else if(_bottomView1) desView = _bottomView1;
    else if(_bottomView2) desView = _bottomView2;
    
    [(BIDBottomView*)desView addMaskView];
    [UIView animateWithDuration:0.5f animations:^{
        CGRect frame = desView.frame;
        frame.origin.x += kSlideDistance;
        desView.frame = frame;
    } completion:^(BOOL finished){
        if(finished)
        {
            
        }
    }];
}

/**
 *分享
 */
- (void)shareBtnHandler
{
    //[_shareView showShareView];
}

/**
 *设置标头视图
 */
- (UIView*)prepareForTenderHeaderView
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    UIView *headerView = [[UIView alloc] init];
    UIFont *nameLabelFont = [UIFont systemFontOfSize:20.0f];
    CGFloat topSpacing = 20.0f;
    CGFloat leftSpacing = 10.0f;
    CGFloat rightSpacing = 10.0f;
    //CGFloat itemSpacing = 5.0f;
    CGFloat lineSpacing = 15.0f;
    CGFloat bottomSpacing = 10.0f;
    //
    CGSize nameLabelSize = CGSizeMake(screenSize.width-leftSpacing-rightSpacing, 0);
    NSDictionary *attributeDictionary = @{NSFontAttributeName:nameLabelFont};
    CGSize tenderNameSize = [tenderName boundingRectWithSize:CGSizeMake(nameLabelSize.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributeDictionary context:nil].size;
    CGFloat tenderNameHeight = ceil(tenderNameSize.height);
    nameLabelSize.height = tenderNameHeight;
    //创建标题名字label
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftSpacing, topSpacing, nameLabelSize.width, nameLabelSize.height)];
    nameLabel.numberOfLines = 0;
    [nameLabel setTextColor:[UIColor darkGrayColor]];
    nameLabel.text = tenderName;
    [nameLabel setFont:nameLabelFont];
    [headerView addSubview:nameLabel];
    //抵押类型
    CGSize mortgageTypeLabelSize = CGSizeMake(40, 20);
    CGRect mortgageTypeLabelFrame = CGRectMake(leftSpacing, CGRectGetMaxY(nameLabel.frame)+lineSpacing, mortgageTypeLabelSize.width, mortgageTypeLabelSize.height);
    UILabel *mortgageLabel = [[UILabel alloc] initWithFrame:mortgageTypeLabelFrame];
    [mortgageLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [mortgageLabel setTextColor:[UIColor whiteColor]];
    [mortgageLabel setTextAlignment:NSTextAlignmentCenter];
    mortgageLabel.clipsToBounds = YES;
    mortgageLabel.layer.cornerRadius = 3.0f;
    if([mortgateType isEqualToString:@"01"])
    {
        //个人
        [mortgageLabel setText:@"个人"];
        [mortgageLabel setBackgroundColor:[UIColor colorWithRed:52.0f/255.0f green:152.0f/255.0f blue:219.0f/255.0f alpha:1.0f]];
    }
    else if([mortgateType isEqualToString:@"02"])
    {
        //房押
        [mortgageLabel setText:@"房押"];
        [mortgageLabel setBackgroundColor:[UIColor colorWithRed:231.0f/255.0f green:76.0f/255.0f blue:60.0f/255.0f alpha:1.0f]];
    }
    else if([mortgateType isEqualToString:@"03"])
    {
        //车押
        [mortgageLabel setText:@"车押"];
        [mortgageLabel setBackgroundColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
    }
    else if([mortgateType isEqualToString:@"04"])
    {
        //车房押
        [mortgageLabel setText:@"车*房"];
        [mortgageLabel setBackgroundColor:[UIColor colorWithRed:52.0f/255.0f green:152.0f/255.0f blue:219.0f/255.0f alpha:1.0f]];
    }
    else if([mortgateType isEqualToString:@"04"])
    {
        //其他
        [mortgageLabel setText:@"其他"];
        [mortgageLabel setBackgroundColor:[UIColor colorWithRed:52.0f/255.0f green:152.0f/255.0f blue:219.0f/255.0f alpha:1.0f]];
    }
    [headerView addSubview:mortgageLabel];
    //
    CGFloat headerViewHeight = CGRectGetMaxY(mortgageLabel.frame) + bottomSpacing;
    CGRect headerViewFrame = CGRectMake(0, 0, screenSize.width, headerViewHeight);
    headerView.frame = headerViewFrame;
    return headerView;
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGFloat keyboardHeight = keyboardSize.height;
    //NSValue *durationValue = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    //NSTimeInterval timeInterval;
    //[durationValue getValue:&timeInterval];
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationDuration:0.3f];
    //NSLog(@"%f", timeInterval);
    //
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if(bIsGroupTender)
    {
        CGRect bottomViewFrame = _bottomView1.frame;
        bottomViewFrame.origin.y = screenSize.height - keyboardHeight - CGRectGetHeight(bottomViewFrame);
        _bottomView1.frame = bottomViewFrame;

    }
    else
    {
        CGRect bottomViewFrame = _bottomView.frame;
        bottomViewFrame.origin.y = screenSize.height - keyboardHeight - CGRectGetHeight(bottomViewFrame);
        _bottomView.frame = bottomViewFrame;
    }
    //
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if(bIsGroupTender)
    {
        CGRect bottomViewFrame = _bottomView1.frame;
        bottomViewFrame.origin.y = screenSize.height - CGRectGetHeight(bottomViewFrame);
        _bottomView1.frame = bottomViewFrame;

    }
    else
    {
        CGRect bottomViewFrame = _bottomView.frame;
        bottomViewFrame.origin.y = screenSize.height - CGRectGetHeight(bottomViewFrame);
        _bottomView.frame = bottomViewFrame;
    }
}

#pragma mark -UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)
    {
        if(alertView.tag==0)
        {
            //登录注册
            BIDLoginAndRegisterViewController *vc = [[BIDLoginAndRegisterViewController alloc] initWithNibName:@"BIDLoginAndRegisterViewController" bundle:nil];
            [self.navigationController setViewControllers:@[vc] animated:YES];
        }
        else
        {
            //开通汇付天下
            BIDOpenHFTXViewController *vc = [[BIDOpenHFTXViewController alloc] initWithNibName:@"BIDOpenHFTXViewController" bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else
    {
        if(alertView.tag==2)
        {
            //登录
            BIDLoginViewController *vc;
            if([UIScreen mainScreen].bounds.size.height>=568.0f)
            {
                vc = [[BIDLoginViewController alloc] initWithNibName:@"BIDLoginViewController" bundle:nil];
            }
            else
            {
                vc = [[BIDLoginViewController alloc] initWithNibName:@"BIDLoginViewController320x480" bundle:nil];
            }
            vc.bRequestException = YES;
            [self.navigationController setViewControllers:@[vc] animated:YES];
        }
    }
}

#pragma mark BIDEnterpriseBriefIntroductionViewDelegate
- (void)refreshEnterpriseBriefIntroduction:(int)section row:(int)row
{
    //更新view的高度
    switch(section)
    {
        case 0:
        {
            NSNumber *value = [NSNumber numberWithFloat:CGRectGetHeight(_enterpriseBriefIntroductionView.frame)];
            NSDictionary *dictionary = _tenderBaseInfoArr[row];
            NSMutableDictionary *dictionary1 = [[NSMutableDictionary alloc] initWithDictionary:dictionary copyItems:YES];
            [dictionary1 setObject:value forKey:@"height"];
            [_tenderBaseInfoArr replaceObjectAtIndex:row withObject:dictionary1];
        }
            break;
        case 1:
        {
            NSNumber *value = [NSNumber numberWithFloat:CGRectGetHeight(_guaranteeProjectView.frame)];
            NSDictionary *dictionary = _riskControlArr[row];
            NSMutableDictionary *dictionary1 = [[NSMutableDictionary alloc] initWithDictionary:dictionary copyItems:YES];
            [dictionary1 setObject:value forKey:@"height"];
            [_riskControlArr replaceObjectAtIndex:row withObject:dictionary1];
        }
            break;
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
}
#pragma mark BIDBottomViewDelegate
//投标
- (void)toTenderWithAmount:(NSString *)strAmount password:(NSString *)strPassword
{
    //先关闭键盘
    [_bottomView closeKeyboard];
    [_bottomView1 closeKeyboard];
    if(![BIDAppDelegate isHaveLogin])
    {
        //未登录,则提示需要登录才能投标，是否登录
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"登录后才可以继续操作，是否登录" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
        alertView.tag = 0;
        [alertView show];
    }
    else
    {
        //先判断金额是够足够
        if([strAmount floatValue] > [_leftAmt floatValue])
        {
            //余额不足
            [_spinnerView dismissTheView];
            [BIDCommonMethods showAlertView:@"余额不足" buttonTitle:@"关闭" delegate:nil tag:0];
            return;
        }
        //已登录
        NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strTenderURL];
        NSString *strPost = @"";
        if(bIsGroupTender)
        {
            strPost = [[NSString alloc] initWithFormat:@"jsonDataSet={\"bid\":\"%@\", \"transAmt\":\"%@\", \"investPwd\":\"%@\", \"retUtlType\":\"ios\"}", tenderId, strAmount, strPassword];
        }
        else
        {
            strPost = [[NSString alloc] initWithFormat:@"jsonDataSet={\"bid\":\"%@\", \"transAmt\":\"%@\", \"retUtlType\":\"ios\"}", tenderId, strAmount];
        }
        _spinnerView.content = @"";
        [_spinnerView showTheView];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
//            int state = [BIDCommonMethods isHaveRegisterHFTX];
//            if(state==0)
//            {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [_spinnerView dismissTheView];
//                    [BIDCommonMethods showAlertView:@"请求失败" buttonTitle:@"关闭" delegate:nil tag:0];
//                });
//            }
//            else if(state==1)
//            {
//                //未注册汇付天下
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [_spinnerView dismissTheView];
//                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"需要注册汇付天下才能继续操作,是否注册" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
//                    alertView.tag = 1;
//                    [alertView show];
//                });
//            }
            //else if(state==2)
            {
                //已注册汇付天下
                int rev = [BIDDataCommunication uploadDataByPostToURL:strURL postValue:strPost toDictionary:dictionary];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_spinnerView dismissTheView];
                    if(rev==1)
                    {
                        if([[dictionary objectForKey:@"json"] isEqualToString:@"success"])
                        {
                            NSString *strDesURL = [dictionary objectForKey:@"data"];
                            BIDWebPageJumpViewController *vc = [[BIDWebPageJumpViewController alloc] initWithNibName:@"BIDWebPageJumpViewController" bundle:nil];
                            vc.desURL = strDesURL;
                            [self.navigationController pushViewController:vc animated:YES];
                        }
                        else
                        {
                            [BIDCommonMethods showAlertView:[dictionary objectForKey:@"message"] buttonTitle:@"关闭" delegate:nil tag:0];
                        }
                    }
                    else if(rev==2)
                    {
                        [BIDCommonMethods showAlertView:err_msg buttonTitle:@"关闭" delegate:self tag:2];
                    }
                    else
                    {
                        [BIDCommonMethods showAlertView:@"请求失败" buttonTitle:@"关闭" delegate:nil tag:0];
                    }
                });
            }
//            else if(state==3)
//            {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [_spinnerView dismissTheView];
//                    [BIDCommonMethods showAlertView:err_msg buttonTitle:@"关闭" delegate:self tag:2];
//                });
//            }
        });
    }
}

#pragma mark BIDEnterpriseInfoViewDelegate
- (void)refreshEnterpriseInfo
{
    //更新view的高度
    NSNumber *value = [NSNumber numberWithFloat:CGRectGetHeight(_enterpriseInfoView.frame)];
    [_cellHeightArr replaceObjectAtIndex:8 withObject:value];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:8 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark BIDGuaranteeInfoViewDelegate
- (void)refreshGuaranteeInfoView
{
    //更新view的高度
    NSNumber *value = [NSNumber numberWithFloat:CGRectGetHeight(_guaranteeInfoView.frame)];
    [_cellHeightArr replaceObjectAtIndex:10 withObject:value];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:10 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark BIDShareViewDelegate
- (void)shareTypeSelect:(SHARE_TYPE)shareType
{
    switch(shareType)
    {
        case WECHAT_FRIEND:
        {
            //微信好友
        }
            break;
        case WECHAT_FRIEND_CIRCLE:
        {
            //微信朋友圈
        }
            break;
        case QQ_FRIEND:
        {}
            break;
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _sectionArr.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rows = 0;
    switch(section)
    {
        case 0:
        {
            rows = _tenderBaseInfoArr.count;
        }
            break;
//        case 1:
//        {
//            //风险控制
//            rows = _riskControlArr.count;
//        }
//            break;
        case 1:
        {
            //项目信息
            rows = _projectInfoArr.count;
        }
            break;
        case 2:
        {
            //企业信息
            rows = _enterpriseInfoArr.count;
        }
            break;
        case 3:
        {
            //抵质押信息
            rows = _guaranteeInfoArr.count;
        }
            break;
        case 4:
        {
            //还款计划
            rows = 1;
        }
            break;
        case 5:
        {
            //投标情况
            rows = 1;
        }
            break;
    }
    return rows;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.row;
    UIColor *textColor = [UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f];
    static NSString *textIdentifier = @"textIdentifier";
    static NSString *identifier = @"identifier";
    static NSString *expandIdentifier = @"expandIdentifier";
    static NSString *customIdentifier = @"customIdentifier";
    static NSString *riskControlIdentifier = @"riskControlIdentifier";
    static NSString *enterpriseInfoIdentifier = @"enterpriseInfo";
    static NSString *repaymentPlanIdentifier = @"repaymentPlan";
    static NSString *tenderConditionIdentifier = @"conditionIdentifier";
    if(!_bRegister)
    {
        _bRegister = YES;
        UINib *nib = [UINib nibWithNibName:@"BIDCustomCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:customIdentifier];
        UINib *nib1 = [UINib nibWithNibName:@"BIDEnterpriseInfoCell" bundle:nil];
        [tableView registerNib:nib1 forCellReuseIdentifier:enterpriseInfoIdentifier];
        UINib *nib2 = [UINib nibWithNibName:@"BIDExpandCell" bundle:nil];
        [tableView registerNib:nib2 forCellReuseIdentifier:expandIdentifier];
        UINib *nib3 = [UINib nibWithNibName:@"BIDTextCell" bundle:nil];
        [tableView registerNib:nib3 forCellReuseIdentifier:textIdentifier];
    }
    switch(section)
    {
        case 0:
        {
            //标的基本信息
            if(row<7)
            {
                BIDTextCell *textCell = (BIDTextCell*)[tableView dequeueReusableCellWithIdentifier:textIdentifier];
                NSDictionary *dictionary = _tenderBaseInfoArr[row];
                NSString *strTitle = [dictionary objectForKey:@"title"];
                NSString *strContent = [dictionary objectForKey:@"content"];
                NSString *strText = [[NSString alloc] initWithFormat:@"%@ : %@", strTitle, strContent];
                textCell.textLabel.text = strText;
                textCell.textLabel.textColor = textColor;
                textCell.textLabel.font = [UIFont systemFontOfSize:kCellFontSize];
                textCell.lineLable.hidden = NO;
                cell = textCell;
            }
            else
            {
                BIDExpandCell *expandCell = (BIDExpandCell*)[tableView dequeueReusableCellWithIdentifier:expandIdentifier];
                [expandCell setBackgroundColor:[UIColor yellowColor]];
                if([expandCell.contentView viewWithTag:100])
                {}
                else
                {
                    [expandCell.contentView addSubview:_enterpriseBriefIntroductionView];
                }
                cell = expandCell;
            }
        }
            break;
//        case 1:
//        {
//            //风险控制
//            if(row<_riskControlArr.count-1)
//            {
//                BIDCustomCell *customCell = (BIDCustomCell*)[tableView dequeueReusableCellWithIdentifier:customIdentifier];
//                NSDictionary *dictionary = _riskControlArr[row];
//                customCell.titleLabel.text = [dictionary objectForKey:@"title"];
//                customCell.titleLabel.font = [UIFont systemFontOfSize:kCellFontSize];
//                customCell.contentLabel.text = [dictionary objectForKey:@"content"];
//                CGFloat labelWidth = CGRectGetWidth(self.view.frame)-73-14*2;
//                CGFloat labelHeight = [[dictionary objectForKey:@"height"] floatValue]+3;
//                CGRect frame = customCell.contentLabel.frame;
//                frame.size = CGSizeMake(labelWidth, labelHeight);
//                customCell.contentLabel.frame = frame;
//                customCell.contentLabel.numberOfLines = 0;
//                customCell.contentLabel.font = [UIFont systemFontOfSize:kCellFontSize];
//                CGRect lineFrame = customCell.lineLabel.frame;
//                lineFrame.origin.y = CGRectGetMaxY(frame)+10<44?43:CGRectGetMaxY(frame)+9;
//                lineFrame.size.width = CGRectGetWidth(self.view.frame)-14;
//                customCell.lineLabel.frame = lineFrame;
//                customCell.lineLabel.hidden = NO;
//                cell = customCell;
//            }
//            else
//            {
//                cell = [tableView dequeueReusableCellWithIdentifier:riskControlIdentifier];
//                if(!cell)
//                {
//                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:riskControlIdentifier];
//                }
//                if([cell.contentView viewWithTag:100])
//                {}
//                else
//                {
//                    [cell.contentView addSubview:_guaranteeProjectView];
//                }
//            }
//        }
//            break;
        case 1:
        {
            //项目信息
            BIDTextCell *textCell = (BIDTextCell*)[tableView dequeueReusableCellWithIdentifier:textIdentifier];
            NSDictionary *dictionary = _projectInfoArr[row];
            NSString *strTitle = [dictionary objectForKey:@"title"];
            NSString *strContent = [dictionary objectForKey:@"content"];
            NSString *strText = [[NSString alloc] initWithFormat:@"%@ : %@", strTitle, strContent];
            textCell.textLabel.text = strText;
            textCell.textLabel.textColor = textColor;
            textCell.textLabel.font = [UIFont systemFontOfSize:kCellFontSize];
            if(row==_projectInfoArr.count-1) textCell.lineLable.hidden = YES;
            else textCell.lineLable.hidden = NO;
            cell = textCell;
        }
            break;
        case 2:
        {
            //企业信息
            cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if(!cell)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            }
            NSDictionary *dictionary = _enterpriseInfoArr[row];
            cell.textLabel.text = [dictionary objectForKey:@"content"];
            CGRect labelFrame = cell.textLabel.frame;
            labelFrame.size.height = [[dictionary objectForKey:@"height"] floatValue];
            cell.textLabel.frame = labelFrame;
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.textColor = textColor;
            cell.textLabel.font = [UIFont systemFontOfSize:kCellFontSize];
        }
            break;
        case 3:
        {
            //抵质押信息
            cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if(!cell)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            }
            NSDictionary *dictionary = _guaranteeInfoArr[row];
            cell.textLabel.text = [dictionary objectForKey:@"content"];
            CGRect labelFrame = cell.textLabel.frame;
            labelFrame.size.height = [[dictionary objectForKey:@"height"] floatValue];
            cell.textLabel.frame = labelFrame;
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.textColor = textColor;
            cell.textLabel.font = [UIFont systemFontOfSize:kCellFontSize];
        }
            break;
        case 4:
        {
            //还款计划
            cell = [tableView dequeueReusableCellWithIdentifier:repaymentPlanIdentifier];
            if(!cell)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:repaymentPlanIdentifier];
            }
            if([cell.contentView viewWithTag:104])
            {}
            else
            {
                [cell.contentView addSubview:_repaymentPlanView];
            }
        }
            break;
        case 5:
        {
            //投标情况
            cell = [tableView dequeueReusableCellWithIdentifier:tenderConditionIdentifier];
            if(!cell)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tenderConditionIdentifier];
            }
            if([cell.contentView viewWithTag:105])
            {
                UIView *subView = [cell.contentView viewWithTag:105];
                [subView removeFromSuperview];
                [cell.contentView addSubview:_tenderConditionView];
            }
            else
            {
                [cell.contentView addSubview:_tenderConditionView];
            }
        }
            break;
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    return cell;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), kSectionHeight)];
    [label setTextAlignment:NSTextAlignmentLeft];
    [label setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:240.0f/255.0f blue:241.0f/255.0f alpha:1.0f]];
    [label setTextColor:[UIColor darkGrayColor]];
    [label setFont:[UIFont systemFontOfSize:18.0f]];
    NSString *strTitle = _sectionArr[section];
    [label setText:[[NSString alloc] initWithFormat:@"   %@", strTitle]];
    return label;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 1)];
    [footerView setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:240.0f/255.0f blue:241.0f/255.0f alpha:1.0f]];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, CGRectGetWidth(self.view.frame)-14, 1)];
    [label setBackgroundColor:[UIColor colorWithRed:93.0f/255.0f green:166.0f/255.0f blue:217.0f/255.0f alpha:1.0f]];
    [footerView addSubview:label];
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section==0)
    {
        return 0.0f;
    }
    else
    {
        return kSectionHeight;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(section == _sectionArr.count-1)
    {
        return 0.0f;
    }
    return 1.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.row;
    CGFloat cellHeight = 0.0f;
    switch(section)
    {
        case 0:
        {
            NSDictionary *dictionary = _tenderBaseInfoArr[row];
            cellHeight = [[dictionary objectForKey:@"height"] floatValue];
            cellHeight = row<7?cellHeight:cellHeight;
        }
            break;
//        case 1:
//        {
//            NSDictionary *dictionary = _riskControlArr[row];
//            cellHeight = [[dictionary objectForKey:@"height"] floatValue] + 3 + 10*2;
//            cellHeight = row<_riskControlArr.count-1?cellHeight:[[dictionary objectForKey:@"height"] floatValue];
//        }
//            break;
        case 1:
        {
            NSDictionary *dictionary = _projectInfoArr[row];
            cellHeight = [[dictionary objectForKey:@"height"] floatValue];
        }
            break;
        case 2:
        {
            NSDictionary *dictionary = _enterpriseInfoArr[row];
            cellHeight = [[dictionary objectForKey:@"height"] floatValue] + 10*2;
        }
            break;
        case 3:
        {
            NSDictionary *dictionary = _guaranteeInfoArr[row];
            cellHeight = [[dictionary objectForKey:@"height"] floatValue] + 10*2;
        }
            break;
        case 4:
        {
            cellHeight = [_repaymentPlanHeightValue floatValue];
        }
            break;
        case 5:
        {
            cellHeight = [_tenderConditionHeightValue floatValue];
        }
            break;
    }
    return cellHeight<44.0f?44.0f:ceil(cellHeight);
}

@end

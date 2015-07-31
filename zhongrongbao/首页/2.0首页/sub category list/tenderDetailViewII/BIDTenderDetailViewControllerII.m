//
//  BIDTenderDetailViewControllerII.m
//  zhongrongbao
//
//  Created by mal on 15/7/1.
//  Copyright (c) 2015年 cnsoft. All rights reserved.
//

#import "BIDTenderDetailViewControllerII.h"
#import "BIDLoginViewController.h"
#import "BIDOpenHFTXViewController.h"
#import "BIDTenderDetailHeaderView.h"
#import "BIDTenderAmountView.h"
#import "BIDActivityListView.h"
#import "BIDSubCategoryCollectionCell.h"
#import "BIDEnterpriseBriefIntroductionView.h"
#import "BIDRepaymentPlanView.h"
#import "BIDTenderConditionView.h"
#import "BIDTextCell.h"
#import "BIDWebPageJumpViewController.h"
#import "BIDBrowserImageViewController.h"
#import "BIDNode.h"
#import "BIDAttributeCell.h"
/*$.post('/userInvest.shtml','jsonDataSet={"investAmt":"10","activityIds":["11111","224235"],"investPwd":"","bid":"1705"}','json');
activityIds  是 ["红包id","体验金id","其他活动id"]**/

/**
 *获取红包和体验金列表
 */
static NSString *getActivityList = @"ActivityUser/ActList.shtml";
/**
 *获取标详情
 */
static NSString *getTenderDetailURL1 = @"borrow/getBorrowDtlMes.shtml";
static NSString *getTenderDetailURL2 = @"borrow/getBorrowDetailsMes.shtml";
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
//static NSString *strTenderURL = @"UserPnr/InitiativeTender.shtml";
static NSString *strTenderURL = @"userInvest.shtml";
/**
 *查询客户汇付天下账户信息
 */
static NSString *strQueryUserAccountInfoURL = @"UserPay/PnrCount.shtml";
/**
 *某个标的当前可投金额
 */
static NSString *canInvestAmtForTenderURL = @"borrows/getCanInvestAmt.shtml";


@interface BIDTenderDetailViewControllerII ()<UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate, BIDTenderAmountViewDelegate, UIAlertViewDelegate>
{
    BIDTenderDetailHeaderView *_tenderDetailHeaderView;
    UICollectionView *_collectionView;
    NSMutableArray *_dataSourceArr;
    BOOL _bRegister;
    BOOL _bRegisterForTableView;
    CGFloat _tableViewWidth;
    CGFloat _tableViewHeight;
    int _selectIndex;
    //
    NSMutableArray *_sectionTitleArr;
    //投标视图背景遮罩图
    UIView *_maskView;
    /**
     *tableview的section的高度
     */
    CGFloat kSectionHeight;
    /**
     *tableview cell中的字体大小
     */
    CGFloat kCellFontSize;
    /**
     *个人/企业基本信息
     */
    BIDEnterpriseBriefIntroductionView *_personalOrEnterpriseInfoView;
    /**
     *抵质押信息
     */
    BIDEnterpriseBriefIntroductionView *_mortgateInfoView;
    /**
     *风控信息
     */
    BIDEnterpriseBriefIntroductionView *_riskInfoView;
    /**
     *还款计划
     */
    BIDRepaymentPlanView *_repaymentPlanView;
    /**
     *投标情况
     */
    BIDTenderConditionView *_tenderConditionView;
    /**
     *风险控制
     */
    NSMutableArray *_riskInfoArr;
    /**
     *项目信息
     */
    NSMutableArray *_projectInfoArr;
    /**
     *个人/企业信息
     */
    NSMutableArray *_personalOrEnterpriseInfoArr;
    /**
     *抵质押信息
     */
    NSMutableArray *_mortgageInfoArr;
    /**
     *账户余额
     */
    NSString *_leftAmt;
    /**
     *还款计划视图的高度
     */
    NSNumber *_repaymentPlanHeightValue;
    /**
     *投标情况视图的高度
     */
    NSNumber *_tenderConditionHeightValue;
    //
    BIDTenderAmountView *_tenderAmountView;
    //
    BIDActivityListView *_activityListView;
    //红包和体验金信息
    NSMutableDictionary *_activityInfoDic;
    //
    BIDAttributeCell *_tempAttributeCell;
}

@end

@implementation BIDTenderDetailViewControllerII
@synthesize bCanInvest;
@synthesize tenderId;
@synthesize bShowOpenTime;
@synthesize openTime;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"项目详情";
    //
    _tempAttributeCell = (BIDAttributeCell*)[[[NSBundle mainBundle] loadNibNamed:@"BIDAttributeCell" owner:self options:nil] lastObject];
    //
    [self prepareForData];
    [self layoutView];
    [self getTenderDetailInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)layoutView
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat ownWidth = screenSize.width;
    CGFloat ownHeight = screenSize.height;
    //create tenderAmountView
    _tenderAmountView = (BIDTenderAmountView*)[[[NSBundle mainBundle] loadNibNamed:@"BIDTenderAmountView" owner:self options:nil] lastObject];
    _tenderAmountView.delegate = self;
    _tenderAmountView.center = CGPointMake(ownWidth/2, ownHeight/2);
    //
    _activityListView = [[BIDActivityListView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_tenderAmountView.frame), 0, CGRectGetWidth(_tenderAmountView.frame), 100)];
    _activityListView.delegate = (BIDTenderAmountView<BIDActivityListViewDelegate>*)_tenderAmountView;
    //
    _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ownWidth, ownHeight)];
    [_maskView setBackgroundColor:[UIColor colorWithWhite:0.2f alpha:0.8f]];
    //create tenderHeaderView
    _tenderDetailHeaderView = (BIDTenderDetailHeaderView*)[[[NSBundle mainBundle] loadNibNamed:@"BIDTenderDetailHeaderView" owner:self options:nil] lastObject];
    [_tenderDetailHeaderView initView];
    CGRect headerViewFrame = _tenderDetailHeaderView.frame;
    headerViewFrame.origin.x = 0;
    headerViewFrame.origin.y = 0;
    _tenderDetailHeaderView.frame = headerViewFrame;
    [self.view addSubview:_tenderDetailHeaderView];
    //set segmentControl frame
    _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"项目详情", @"投资列表", @"还款计划"]];
    _segmentedControl.frame = CGRectMake(10, 0, 300, 29);
    _segmentedControl.tintColor = [UIColor colorWithRed:255.0f/255.0f green:57.0f/255.0f blue:66.0f/255.0f alpha:1.0f];
    _segmentedControl.selectedSegmentIndex = 0;
    [_segmentedControl addTarget:self action:@selector(segmentedControlChangeHandler:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_segmentedControl];
    _segmentedControl.selectedSegmentIndex = 0;
    CGRect segmentedControlFrame = _segmentedControl.frame;
    segmentedControlFrame.origin.y = CGRectGetMaxY(headerViewFrame) + 10;
    _segmentedControl.frame = segmentedControlFrame;
    //create collectionView
    CGFloat collectionViewHeight = ownHeight-CGRectGetHeight(headerViewFrame)-10-CGRectGetHeight(_segmentedControl.frame)-10-64;
    if(bCanInvest)
    {
        //显示投标按钮
        _investBtn.hidden = NO;
        collectionViewHeight -= CGRectGetHeight(_investBtn.frame);
    }
    else
    {
        if(bShowOpenTime)
        {
            _investBtn.hidden = NO;
            _investBtn.enabled = NO;
            //_investBtn.titleLabel.text = openTime;
            [_investBtn setTitle:openTime forState:UIControlStateNormal];
            collectionViewHeight -= CGRectGetHeight(_investBtn.frame);
        }
        else
        {
            _investBtn.hidden = YES;
        }
    }
    //
    _tableViewWidth = ownWidth;
    _tableViewHeight = collectionViewHeight;
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setMinimumInteritemSpacing:0.0f];
    [flowLayout setMinimumLineSpacing:0.f];
    [flowLayout setItemSize:CGSizeMake(ownWidth, collectionViewHeight)];
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_segmentedControl.frame)+10, ownWidth, collectionViewHeight) collectionViewLayout:flowLayout];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.bounces = NO;
    [self.view addSubview:_collectionView];
}

- (void)prepareForData
{
    kSectionHeight = 44.0f;
    kCellFontSize = 15.0f;
    _selectIndex = 0;
    _dataSourceArr = [[NSMutableArray alloc] init];
    _sectionTitleArr = [[NSMutableArray alloc] init];
    _activityInfoDic = [[NSMutableDictionary alloc] init];
    for(int i=0; i<_segmentedControl.numberOfSegments; i++)
    {
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        [_dataSourceArr addObject:arr];
    }
    _projectInfoArr = [[NSMutableArray alloc] initWithCapacity:5];
    _personalOrEnterpriseInfoArr = [[NSMutableArray alloc] initWithCapacity:1];
    _riskInfoArr = [[NSMutableArray alloc] initWithCapacity:1];
    _mortgageInfoArr = [[NSMutableArray alloc] initWithCapacity:1];
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
 *获取标详情
 */
- (void)getTenderDetailInfo
{
    [_dataSourceArr removeAllObjects];
    [_sectionTitleArr removeAllObjects];
    [_projectInfoArr removeAllObjects];
    [_personalOrEnterpriseInfoArr removeAllObjects];
    [_riskInfoArr removeAllObjects];
    [_mortgageInfoArr removeAllObjects];
    //用户汇付账户信息(此处用于获取可用余额)
    NSMutableDictionary *userAmtInfoDictionary = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *tenderInfoDictionary1 = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *tenderInfoDictionary2 = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *repaymentPlanDictionary = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *tenderConditionDictionary = [[NSMutableDictionary alloc] init];
    //
    NSString *strUserAmtInfoURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strQueryUserAccountInfoURL];
    //标的基本信息
    NSString *strURL1 = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], getTenderDetailURL1];
    NSString *strURL2 = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], getTenderDetailURL2];
    //还款计划
    NSString *strURL3 = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strRepaymentPlanURL];
    //投标情况
    NSString *strURL4 = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strTenderConditionURL];
    NSString *strPost = [[NSString alloc] initWithFormat:@"jsonDataSet={\"bid\":\"%@\"}", tenderId];
    NSString *strPost1 = [[NSString alloc] initWithFormat:@"jsonDataSet={\"bid\":\"%@\", \"page.currentPage\":\"%d\"}", tenderId, 1];
    
    [self.spinnerView showTheView];
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        //获取用户汇付信息
        [BIDDataCommunication getDataFromNet:strUserAmtInfoURL toDictionary:userAmtInfoDictionary];
    });
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        //获取标的基本信息
        [BIDDataCommunication uploadDataByPostToURL:strURL1 postValue:strPost toDictionary:tenderInfoDictionary1];
    });
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        //获取标的基本信息
        [BIDDataCommunication uploadDataByPostToURL:strURL2 postValue:strPost toDictionary:tenderInfoDictionary2];
    });
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        //获取还款计划
        [BIDDataCommunication uploadDataByPostToURL:strURL3 postValue:strPost toDictionary:repaymentPlanDictionary];
    });
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        //获取投标情况
        [BIDDataCommunication uploadDataByPostToURL:strURL4 postValue:strPost1 toDictionary:tenderConditionDictionary];
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        //
        [self.spinnerView dismissTheView];
        if([[tenderInfoDictionary1 objectForKey:@"json"] isEqualToString:@"success"])
        {
            NSDictionary *subDictionary = [tenderInfoDictionary1 objectForKey:@"data"];
            NSString *strBidType = [subDictionary objectForKey:@"bidType"];
            if([strBidType isEqualToString:@"01"])
            {
                //团体标有密码
                [_tenderAmountView showOrHidePasswordOption:YES];
            }
            else
            {
                [_tenderAmountView showOrHidePasswordOption:NO];
            }
            //获取标的基本信息
            [self getTenderBaseInfo:subDictionary];
        }
        //
        if([[tenderInfoDictionary2 objectForKey:@"json"] isEqualToString:@"success"])
        {
            //获取项目信息
            [self getProjectInfo:[tenderInfoDictionary2 objectForKey:@"borrowData"]];
            //获取企业信息
            [self getPersonalOrEnterpriseInfo:[tenderInfoDictionary2 objectForKey:@"enterData"]];
            //获取风险控制信息
            [self getRiskInfo:[tenderInfoDictionary2 objectForKey:@"riskData"]];
            //获取抵质押信息
            [self getMortgageInfo:[tenderInfoDictionary2 objectForKey:@"mortgageData"]];
            //获取图片信息
            [self getImageInfo:[tenderInfoDictionary2 objectForKey:@"imgData"]];
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
            //为投标视图赋值账户余额
            _tenderAmountView.leftAmount = [_leftAmt floatValue];
        }
        //
        [_collectionView reloadData];
    });
}
//显示投标视图
- (void)showTenderAmountView
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:_maskView];
    [keyWindow addSubview:_tenderAmountView];
}
//移除投标视图
- (void)hideTenderAmountView
{
    [_maskView removeFromSuperview];
    [_tenderAmountView removeFromSuperview];
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
        _leftAmt = [[NSString alloc] initWithFormat:@"%.2f", availableAmt];
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
 *标的基本信息
 */
- (void)getTenderBaseInfo:(NSDictionary *)subDictionary
{
    if(!subDictionary || subDictionary.count==0) return;
    NSNumber *value = nil;
    //标的进度
    value = subDictionary[@"pct"];
    _tenderDetailHeaderView.progressLabel.text = [[NSString alloc] initWithFormat:@"进度%@%%", value];
    //标名字
    NSString *strBorrowName = subDictionary[@"borrowName"];
    //标类型
    NSString *strBorrowTypeName = subDictionary[@"borrowTypeName"];
    //融资金额
    value = subDictionary[@"borrowAmtWan"];
    NSString *strBorrowAmt = [[NSString alloc] initWithFormat:@"%@", value];
    //可投金额
    value = subDictionary[@"canInvestAmt"];
    NSString *strCanInvestAmt = [[NSString alloc] initWithFormat:@"%@", value];
    //截止时间
    NSString *strClosingTime = subDictionary[@"closingTime"];
    NSString *strExamineTime = subDictionary[@"examineTime"];
    //标的状态02投标中，03满标
    //NSString *strBorrowStatus = subDictionary[@"borrowStatus"];
    //信用等级
    value = subDictionary[@"creditLevel"];
    NSString *strCreditLevel = [[NSString alloc] initWithFormat:@"%@", value];
    if([strCreditLevel isEqualToString:@"1"]) strCreditLevel = @"A";
    else if([strCreditLevel isEqualToString:@"2"]) strCreditLevel = @"AA";
    else if([strCreditLevel isEqualToString:@"3"]) strCreditLevel = @"AAA";
    else if([strCreditLevel isEqualToString:@"4"]) strCreditLevel = @"AAAA";
    else if([strCreditLevel isEqualToString:@"5"]) strCreditLevel = @"AAAAA";
    //授信额度
    value = subDictionary[@"creditLimitWan"];
    NSString *strCreditLimit = [[NSString alloc] initWithFormat:@"%@", value];
    //年化收益率
    value = subDictionary[@"annualRate"];
    NSString *strYearRate = [[NSString alloc] initWithFormat:@"%@", value];
    //标的期限
    value = subDictionary[@"deadline"];
    NSString *strDeadline = [[NSString alloc] initWithFormat:@"%@", value];
    //
    _tenderDetailHeaderView.borrowNameLabel.text = [[NSString alloc] initWithFormat:@"%@·%@", strBorrowTypeName, strBorrowName];
    //
    _tenderDetailHeaderView.borrowAmtLabel.text = strBorrowAmt;
    //
//    strCanInvestAmt = [[NSString alloc] initWithFormat:@"%@可投金额(元)", strCanInvestAmt];
//    NSMutableAttributedString *investAmtAttribute = [[NSMutableAttributedString alloc] initWithString:strCanInvestAmt];
//    [investAmtAttribute addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica Neue" size:30.0] range:NSMakeRange(0, strCanInvestAmt.length-7)];
//    [investAmtAttribute addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica Neue" size:13.0] range:NSMakeRange(strCanInvestAmt.length-7, 7)];
//    _tenderDetailHeaderView.canInvestAmtLabel.attributedText = investAmtAttribute;
    _tenderDetailHeaderView.canInvestAmtLabel.text = strCanInvestAmt;
    //
    NSString *strTime = @"";
    if(strExamineTime.length==0)
    {
        strTime = [self getRemainTime:strClosingTime];
        strTime = [[NSString alloc] initWithFormat:@" 结束时间:%@", strTime];
    }
    else
    {
        strTime = [[NSString alloc] initWithFormat:@" 满标时间:%@", strExamineTime];
    }
    //动态设置进度标志的位置
    CGRect progressLabelFrame = _tenderDetailHeaderView.progressLabel.frame;
    CGFloat labelHeight = CGRectGetHeight(_tenderDetailHeaderView.dateLabel.frame);
    UIFont *font = _tenderDetailHeaderView.dateLabel.font;
    int textWidth = [BIDCommonMethods getWidthWithString:strTime font:font constraintSize:CGSizeMake(MAXFLOAT, labelHeight)];
    progressLabelFrame.origin.x = textWidth + 8;
    _tenderDetailHeaderView.progressLabel.frame = progressLabelFrame;
    //
    _tenderDetailHeaderView.dateLabel.text = strTime;
    //
    _tenderDetailHeaderView.creditLabel.text = strCreditLevel;
    //
    strCreditLimit = [[NSString alloc] initWithFormat:@"%@万", strCreditLimit];
    _tenderDetailHeaderView.creditLimitLabel.text = strCreditLimit;
    //
    _tenderDetailHeaderView.yearRateLabel.text = strYearRate;
    //
    _tenderDetailHeaderView.deadLineLabel.text = strDeadline;
}
/**
 *项目信息
 */
- (void)getProjectInfo:(NSDictionary *)subDictionary
{
    if(!subDictionary || subDictionary.count==0) return;
    NSString *strIsShow = subDictionary[@"isShow"];
    if([strIsShow isEqualToString:@"00"])
    {
        //[_projectInfoArr removeAllObjects];
        return;
    }
    else
    {
        NSString *sectionTitle = subDictionary[@"title"];
        [_sectionTitleArr addObject:sectionTitle];
    }
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
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:5];
    [arr addObject:dictionary1];
    [arr addObject:dictionary2];
    [arr addObject:dictionary3];
    [arr addObject:dictionary4];
    [arr addObject:dictionary5];
    //
    NSDictionary *dictionary = @{@"moduleType":[NSNumber numberWithInt:TYPE_PROJECT], @"data":arr};
    [_dataSourceArr addObject:dictionary];
}
/**
 *风险控制信息
 */
- (void)getRiskInfo:(NSDictionary*)subDictionary
{
    if(!subDictionary || subDictionary.count==0) return;
    NSString *strIsShow = subDictionary[@"isShow"];
    if([strIsShow isEqualToString:@"00"])
    {
        [_riskInfoArr removeAllObjects];
        return;
    }
    else
    {
        NSString *sectionTitle = subDictionary[@"title"];
        [_sectionTitleArr addObject:sectionTitle];
    }
    NSString *strTitle = @"";
    NSString *strContent = [subDictionary objectForKey:@"riskRecord"];
    //strContent = [BIDCommonMethods filterHTML:strContent];
    CGFloat contentHeight = [BIDCommonMethods getHeightWithString:strContent font:[UIFont systemFontOfSize:kCellFontSize] constraintSize:CGSizeMake(CGRectGetWidth(self.view.frame)-14*2, MAXFLOAT)];
    NSDictionary *dictionary = @{@"title":strTitle, @"content":strContent, @"height":[NSNumber numberWithFloat:contentHeight], @"moduleType":[NSNumber numberWithInt:TYPE_RISK]};
    //[_riskInfoArr addObject:dictionary];
    [_dataSourceArr addObject:dictionary];
}
/**
 *抵质押信息
 */
- (void)getMortgageInfo:(NSDictionary*)subDictionary
{
    if(!subDictionary || subDictionary.count==0) return;
    NSString *strIsShow = subDictionary[@"isShow"];
    if([strIsShow isEqualToString:@"00"])
    {
        [_mortgageInfoArr removeAllObjects];
        return;
    }
    else
    {
        NSString *sectionTitle = subDictionary[@"title"];
        [_sectionTitleArr addObject:sectionTitle];
    }
    NSString *strTitle = @"";
    NSString *strContent = [subDictionary objectForKey:@"businessAnalysis"];
    //strContent = [BIDCommonMethods filterHTML:strContent];
    CGFloat contentHeight = [BIDCommonMethods getHeightWithString:strContent font:[UIFont systemFontOfSize:kCellFontSize] constraintSize:CGSizeMake(CGRectGetWidth(self.view.frame)-14*2, MAXFLOAT)];
    NSDictionary *dictionary = @{@"title":strTitle, @"content":strContent, @"height":[NSNumber numberWithFloat:contentHeight], @"moduleType":[NSNumber numberWithInt:TYPE_MORTGAGE]};
    //[_mortgageInfoArr addObject:dictionary];
    [_dataSourceArr addObject:dictionary];
}
/**
 *个人/企业基本信息
 */
- (void)getPersonalOrEnterpriseInfo:(NSDictionary*)subDictionary
{
    if(!subDictionary || subDictionary.count==0) return;
    NSString *strIsShow = subDictionary[@"isShow"];
    if([strIsShow isEqualToString:@"00"])
    {
        [_personalOrEnterpriseInfoArr removeAllObjects];
        return;
    }
    else
    {
        NSString *sectionTitle = subDictionary[@"title"];
        [_sectionTitleArr addObject:sectionTitle];
    }
    NSString *strTitle = @"";
    NSString *strContent = [subDictionary objectForKey:@"companyAnalysis"];
    //strContent = [BIDCommonMethods filterHTML:strContent];
    CGFloat contentHeight = [BIDCommonMethods getHeightWithString:strContent font:[UIFont systemFontOfSize:kCellFontSize] constraintSize:CGSizeMake(CGRectGetWidth(self.view.frame)-14*2, MAXFLOAT)];
    NSDictionary *dictionary = @{@"title":strTitle, @"content":strContent, @"height":[NSNumber numberWithFloat:contentHeight], @"moduleType":[NSNumber numberWithInt:TYPE_ENTERPRISE]};
    //[_personalOrEnterpriseInfoArr addObject:dictionary];
    [_dataSourceArr addObject:dictionary];
}
/**
 *图片信息
 */
- (void)getImageInfo:(NSDictionary*)subDictionary
{
    if(!subDictionary || subDictionary.count==0) return;
    NSString *strIsShow = subDictionary[@"isShow"];
    if([strIsShow isEqualToString:@"00"])
    {
        return;
    }
    else
    {
        [_sectionTitleArr addObject:@""];
    }
    NSString *strTitle = [subDictionary objectForKey:@"title"];
    NSDictionary *dictionary = @{@"title":strTitle, @"moduleType":[NSNumber numberWithInt:TYPE_IMG], @"imgData":subDictionary[@"data"]};
    [_dataSourceArr addObject:dictionary];
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

//投标按钮按下事件
- (IBAction)investBtnHandler:(id)sender
{
    if(![BIDAppDelegate isHaveLogin])
    {
        //未登录,则提示需要登录才能投标，是否登录
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"登录后才可以继续操作，是否登录" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
        alertView.tag = 0;
        [alertView show];
    }
    else
    {
        [self.spinnerView showTheView];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            int state = [BIDCommonMethods isHaveRegisterHFTX];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.spinnerView dismissTheView];
                if(state==2)
                {
                    NSMutableDictionary *userAmtInfoDictionary = [[NSMutableDictionary alloc] init];
                    NSMutableDictionary *tenderInfoDic = [[NSMutableDictionary alloc] init];
                    NSString *strUserAmtInfoURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strQueryUserAccountInfoURL];
                    NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], getActivityList];
                    NSString *strCanInvestAmtURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], canInvestAmtForTenderURL];
                    NSString *strPost = [[NSString alloc] initWithFormat:@"jsonDataSet={\"bid\":\"%@\"}", tenderId];
                    [self.spinnerView showTheView];
                    __block int rev = 0;
                    dispatch_group_t group = dispatch_group_create();
                    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
                        //获取用户汇付信息
                        [BIDDataCommunication getDataFromNet:strUserAmtInfoURL toDictionary:userAmtInfoDictionary];
                    });
                    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
                        rev = [BIDDataCommunication uploadDataByPostWithoutCookie:strCanInvestAmtURL postValue:strPost toDictionary:tenderInfoDic];
                    });
                    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
                        //获取活动列表(红包、体验金)
                        rev = [BIDDataCommunication getDataFromNet:strURL toDictionary:_activityInfoDic];
                    });
                    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
                        //
                        [self.spinnerView dismissTheView];
                        //获取可用余额
                        NSString *strLeftAmt = @"0.0";
                        if([[userAmtInfoDictionary objectForKey:@"json"] isEqualToString:@"success"])
                        {
                            NSDictionary *subDic = userAmtInfoDictionary[@"data"];
                            if([[subDic objectForKey:@"pnrStatus"] isEqualToString:@"N"])
                            {
                                //未注册
                                strLeftAmt = @"0.0";
                            }
                            else
                            {
                                //
                                CGFloat availableAmt = [[subDic objectForKey:@"avaiableAmt"] floatValue];
                                strLeftAmt = [[NSString alloc] initWithFormat:@"%.2f", availableAmt];
                                //为投标视图赋值账户余额
                                _tenderAmountView.leftAmount = [strLeftAmt floatValue];
                            }
                        }
                        //
                        if([[tenderInfoDic objectForKey:@"json"] isEqualToString:@"success"])
                        {
                            NSNumber *canInvestAmtValue = tenderInfoDic[@"data"];
                            _tenderAmountView.canInvestAmt = [canInvestAmtValue floatValue];
                        }
                        //
                        if(rev==1)
                        {
                            if([_activityInfoDic[@"json"] isEqualToString:@"success"])
                            {
                                NSArray *arr = _activityInfoDic[@"dataList0"];
                                if(arr.count>0)
                                {
                                    [_tenderAmountView showOrHideRedPacketOption:YES];
                                }
                                else
                                {
                                    [_tenderAmountView showOrHideRedPacketOption:NO];
                                }
                                arr = _activityInfoDic[@"dataList1"];
                                if(arr.count>0)
                                {
                                    [_tenderAmountView showOrHideTiYanJinOption:YES];
                                }
                                else
                                {
                                    [_tenderAmountView showOrHideTiYanJinOption:NO];
                                }
                            }
                            else
                            {
                                [_tenderAmountView showOrHideRedPacketOption:NO];
                                [_tenderAmountView showOrHideTiYanJinOption:NO];
                            }
                        }
                        else
                        {
                            [_tenderAmountView showOrHideRedPacketOption:NO];
                            [_tenderAmountView showOrHideTiYanJinOption:NO];
                        }
                        [self showTenderAmountView];
                    });
                }
                else
                {
                    if(state==0)
                    {
                        [BIDCommonMethods showAlertView:@"请求失败" buttonTitle:@"关闭" delegate:nil tag:0];
                    }
                    else if(state==1)
                    {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"注册汇付天下后才可以继续操作，是否注册" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
                        alertView.tag = 1;
                        [alertView show];
                    }
                    else if(state==3)
                    {
                        [BIDCommonMethods showAlertView:err_msg buttonTitle:@"关闭" delegate:self tag:2];
                    }
                }
            });
        });
    }
}
#pragma mark -UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)
    {
        if(alertView.tag==0)
        {
            BIDLoginViewController *loginVC = nil;
            //登录
            if(IPHONE4OR4S)
            {
                loginVC = [[BIDLoginViewController alloc] initWithNibName:@"BIDLoginViewController" bundle:nil];
            }
            else
            {
                loginVC = [[BIDLoginViewController alloc] initWithNibName:@"BIDLoginViewController2" bundle:nil];
            }
            [self.navigationController setViewControllers:@[loginVC] animated:YES];
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
            if(IPHONE4OR4S)
            {
                vc = [[BIDLoginViewController alloc] initWithNibName:@"BIDLoginViewController" bundle:nil];
            }
            else
            {
                vc = [[BIDLoginViewController alloc] initWithNibName:@"BIDLoginViewController2" bundle:nil];
            }
            vc.bRequestException = YES;
            [self.navigationController setViewControllers:@[vc] animated:YES];
        }
    }
}

#pragma mark - BIDTenderAmountViewDelegate
- (void)toTenderWithAmount:(NSString *)strAmount password:(NSString *)strPwd activityId:(NSString *)strActivityIds
{
    [self hideTenderAmountView];
    //已登录
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strTenderURL];
    NSString *strPost = @"";
    {
        //strPost = [[NSString alloc] initWithFormat:@"jsonDataSet={\"bid\":\"%@\", \"transAmt\":\"%@\", \"retUtlType\":\"ios\"}", tenderId, strAmount];
        strPost = [[NSString alloc] initWithFormat:@"jsonDataSet={\"bid\":\"%@\", \"investAmt\":\"%@\", \"investPwd\":\"%@\", \"activityIds\":%@}", tenderId, strAmount, strPwd, strActivityIds];
    }
    [self.spinnerView showTheView];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        {
            int rev = [BIDDataCommunication uploadDataByPostToURL:strURL postValue:strPost toDictionary:dictionary];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.spinnerView dismissTheView];
                if(rev==1)
                {
                    if([[dictionary objectForKey:@"json"] isEqualToString:@"success"])
                    {
                        NSString *strDesURL = [dictionary objectForKey:@"data"][@"investUrl"];
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
    });
}
//取消投标
- (void)cancelTender
{
    [_maskView removeFromSuperview];
}

//显示活动列表
- (void)showActivityList:(CGRect)frame type:(int)type
{
    [_activityListView removeFromSuperview];
    CGRect frame1 = _tenderAmountView.frame;
    CGFloat posY = CGRectGetMinY(frame1) + CGRectGetMinY(frame) + CGRectGetHeight(frame);
    CGRect activityListViewFrame = _activityListView.frame;
    if(type==1)
    {
        //红包
        _activityListView.activityType = ACTIVITY_REDPACKET;
        [_activityListView setDataSourceArr:_activityInfoDic[@"dataList0"]];
    }
    else if(type==2)
    {
        //体验金
        _activityListView.activityType = ACTIVITY_TIYANJIN;
        [_activityListView setDataSourceArr:_activityInfoDic[@"dataList1"]];
    }
    activityListViewFrame.origin.y = posY;
    _activityListView.frame = activityListViewFrame;
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:_activityListView];
}

#pragma mark UISegmentedControlChangeEvent
- (IBAction)segmentedControlChangeHandler:(UISegmentedControl*)segmentedControl
{
    _selectIndex = segmentedControl.selectedSegmentIndex;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_selectIndex inSection:0];
    [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}

#pragma mark -UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(![scrollView isKindOfClass:[UICollectionView class]]) return;
    CGFloat pageWidth = scrollView.frame.size.width;
    NSInteger page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
   // if(_selectIndex!=page)
    {
        _selectIndex = page;
        _segmentedControl.selectedSegmentIndex = _selectIndex;
        //[_collectionView reloadData];
    }
}

#pragma mark -UIcollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 3;
}
- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    static NSString *identifier = @"identifier";
    _selectIndex = indexPath.row;
    if(!_bRegister)
    {
        _bRegister = YES;
        [collectionView registerClass:[BIDSubCategoryCollectionCell class] forCellWithReuseIdentifier:identifier];
    }
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    UITableView *tableView = (UITableView*)[cell.contentView viewWithTag:100];
    if(!tableView)
    {
        tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, _tableViewWidth, _tableViewHeight)];
        tableView.tag = 100;
        [tableView setBackgroundColor:[UIColor colorWithRed:244.0f/255.0f green:244.0f/255.0f blue:244.0f/255.0f alpha:1.0f]];
        [cell.contentView addSubview:tableView];
    }
    tableView.dataSource = self;
    tableView.delegate = self;
    //tableView.allowsSelection = NO;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.tableFooterView = [[UIView alloc] init];
    [tableView reloadData];
    cell.contentView.autoresizesSubviews = NO;
    return cell;
}
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(_selectIndex==0)
    {
        return _sectionTitleArr.count;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(_selectIndex==0)
    {
        
        NSDictionary *dictionary = _dataSourceArr[section];
        MODULE_TYPE moduleType = [[dictionary objectForKey:@"moduleType"] intValue];
        switch(moduleType)
        {
            case TYPE_PROJECT:
            {
                NSArray *arr = dictionary[@"data"];
                return arr.count;
            }
                break;
            case TYPE_ENTERPRISE:
            {
                return 1;
            }
                break;
            case TYPE_RISK:
            {
                return 1;
            }
                break;
            case TYPE_MORTGAGE:
            {
                return 1;
            }
                break;
            case TYPE_IMG:
            {
                return 1;
            }
                break;
        }
    }
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    static NSString *identifier = @"identifier";
    static NSString *textIdentifier = @"textIdentifier";
    static NSString *tenderIdentifier = @"tenderIdentifier";
    static NSString *repayPlanIdentifier = @"repayPlanIdentifier";
    static NSString *attributeIdentifier = @"attributeIdentifier";
    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.row;
    UIColor *textColor = [UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f];
    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    if(!_bRegisterForTableView)
    {
        _bRegisterForTableView = YES;
        UINib *nib3 = [UINib nibWithNibName:@"BIDTextCell" bundle:nil];
        [tableView registerNib:nib3 forCellReuseIdentifier:textIdentifier];
        //
        UINib *nib4 = [UINib nibWithNibName:@"BIDAttributeCell" bundle:nil];
        [tableView registerNib:nib4 forCellReuseIdentifier:attributeIdentifier];
    }
    if(_selectIndex==0)
    {
        NSDictionary *moduleDic = _dataSourceArr[section];
        MODULE_TYPE moduleType = [[moduleDic objectForKey:@"moduleType"] intValue];
        switch(moduleType)
        {
            case TYPE_PROJECT:
            {
                //项目信息
                NSArray *projectArr = moduleDic[@"data"];
                BIDTextCell *textCell = (BIDTextCell*)[tableView dequeueReusableCellWithIdentifier:textIdentifier];
                if(!textCell)
                {
                    UINib *nib3 = [UINib nibWithNibName:@"BIDTextCell" bundle:nil];
                    [tableView registerNib:nib3 forCellReuseIdentifier:textIdentifier];
                    textCell = (BIDTextCell*)[tableView dequeueReusableCellWithIdentifier:textIdentifier];
                }
                NSDictionary *dictionary = projectArr[row];
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
            case TYPE_ENTERPRISE:
            {
                //个人或企业信息
            }
                //break;
            case TYPE_RISK:
            {
                //风控信息
            }
                //break;
            case TYPE_MORTGAGE:
            {
                //抵质押信息
                BIDAttributeCell *attributeCell = [tableView dequeueReusableCellWithIdentifier:attributeIdentifier];
                NSString *htmlString = moduleDic[@"content"];
                NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSBackgroundColorAttributeName:[UIColor clearColor] } documentAttributes:nil error:nil];
                attributeCell.contentLabel.attributedText = attrStr;
                cell = attributeCell;
//                cell.textLabel.text = [moduleDic objectForKey:@"content"];
//                CGRect labelFrame = cell.textLabel.frame;
//                labelFrame.size.height = [[moduleDic objectForKey:@"height"] floatValue];
//                cell.textLabel.frame = labelFrame;
//                cell.textLabel.numberOfLines = 0;
//                cell.textLabel.textColor = textColor;
//                cell.textLabel.font = [UIFont systemFontOfSize:kCellFontSize];
            }
                break;
            case TYPE_IMG:
            {
                //图片信息
                cell.textLabel.text = moduleDic[@"title"];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
                break;
        }
    }
    else if(_selectIndex==1)
    {
        //投资列表
        cell = [tableView dequeueReusableCellWithIdentifier:tenderIdentifier];
        if(!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tenderIdentifier];
        }
        UIView *subView = [cell.contentView viewWithTag:101];
        if(!subView)
        {
            _tenderConditionView.tag = 101;
            [cell.contentView addSubview:_tenderConditionView];
        }
    }
    else if(_selectIndex==2)
    {
        //还款计划
        cell = [tableView dequeueReusableCellWithIdentifier:repayPlanIdentifier];
        if(!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:repayPlanIdentifier];
        }
        UIView *subView = [cell.contentView viewWithTag:102];
        if(!subView)
        {
            _repaymentPlanView.tag = 102;
            [cell.contentView addSubview:_repaymentPlanView];
        }
    }
    cell.contentView.autoresizesSubviews = NO;
    return cell;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), kSectionHeight)];
    [label setTextAlignment:NSTextAlignmentLeft];
    //[label setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:240.0f/255.0f blue:241.0f/255.0f alpha:1.0f]];
    [label setBackgroundColor:[UIColor whiteColor]];
    [label setTextColor:[UIColor darkGrayColor]];
    [label setFont:[UIFont systemFontOfSize:18.0f]];
    NSString *strTitle = _sectionTitleArr[section];
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
    if(_selectIndex==0)
    {
        NSDictionary *dic = _dataSourceArr[section];
        if([[dic objectForKey:@"moduleType"] intValue] == TYPE_IMG)
        {
            return 0;
        }
        return kSectionHeight;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(_selectIndex==0)
    {
        if(section == _sectionTitleArr.count-1)
        {
            return 0.0f;
        }
        return 1.0f;
    }
    return 0.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.row;
    CGFloat cellHeight = 0.0f;
    if(_selectIndex==0)
    {
        NSDictionary *moduleDic = _dataSourceArr[section];
        MODULE_TYPE moduleType = [[moduleDic objectForKey:@"moduleType"] intValue];
        switch(moduleType)
        {
            case TYPE_PROJECT:
            {
                NSArray *arr = moduleDic[@"data"];
                NSDictionary *subDic = arr[row];
                cellHeight = [[subDic objectForKey:@"height"] floatValue];
            }
                break;
            case TYPE_ENTERPRISE:
            {
            }
                //break;
            case TYPE_RISK:
            {
            }
                //break;
            case TYPE_MORTGAGE:
            {
                //cellHeight = [[moduleDic objectForKey:@"height"] floatValue];
                NSString *htmlString = moduleDic[@"content"];
                NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSBackgroundColorAttributeName:[UIColor clearColor] } documentAttributes:nil error:nil];
                _tempAttributeCell.contentLabel.attributedText = attrStr;
                _tempAttributeCell.contentLabel.preferredMaxLayoutWidth = CGRectGetWidth(tableView.frame)-8*2;
                CGSize size = [_tempAttributeCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
                cellHeight = size.height + 1;
            }
                break;
            case TYPE_IMG:
            {
                cellHeight = 44;
            }
                break;
        }
        return cellHeight<44.0f?44.0f:ceil(cellHeight);
    }
    else if(_selectIndex==1)
    {
        //投资列表
        return _tenderConditionHeightValue.floatValue;
    }
    else if(_selectIndex==2)
    {
        //还款计划
        return _repaymentPlanHeightValue.floatValue;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSMutableArray *nodeArr = [[NSMutableArray alloc] init];
    NSDictionary *dic = _dataSourceArr[indexPath.section];
    NSString *strImgServer = [BIDAppDelegate getStaticImgServer];
    if([[dic objectForKey:@"moduleType"] intValue] == TYPE_IMG)
    {
        BIDBrowserImageViewController *vc = [[BIDBrowserImageViewController alloc] initWithNibName:@"BIDBrowserImageViewController" bundle:nil];
        NSDictionary *dataDic = dic[@"imgData"];
        NSArray *arr = dataDic[@"01"];
        for(NSDictionary *subDic in arr)
        {
            NSString *strDownloadURL = [[NSString alloc] initWithFormat:@"%@/%@", strImgServer, subDic[@"imgPath"]];
            BIDNode *node = [[BIDNode alloc] init];
            node.img = nil;
            node.imgDownloadURL = strDownloadURL;
            node.imgTypeName = subDic[@"imgTypeName"];
            [nodeArr addObject:node];
        }
        arr = dataDic[@"02"];
        for(NSDictionary *subDic in arr)
        {
            NSString *strDownloadURL = [[NSString alloc] initWithFormat:@"%@/%@", strImgServer, subDic[@"imgPath"]];
            BIDNode *node = [[BIDNode alloc] init];
            node.img = nil;
            node.imgDownloadURL = strDownloadURL;
            node.imgTypeName = subDic[@"imgTypeName"];
            [nodeArr addObject:node];
        }
        arr = dataDic[@"03"];
        for(NSDictionary *subDic in arr)
        {
            NSString *strDownloadURL = [[NSString alloc] initWithFormat:@"%@/%@", strImgServer, subDic[@"imgPath"]];
            BIDNode *node = [[BIDNode alloc] init];
            node.img = nil;
            node.imgDownloadURL = strDownloadURL;
            node.imgTypeName = subDic[@"imgTypeName"];
            [nodeArr addObject:node];
        }
        vc.nodeArr = [[NSMutableArray alloc] initWithArray:nodeArr];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end

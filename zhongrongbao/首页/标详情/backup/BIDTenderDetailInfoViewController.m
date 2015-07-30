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

/**
 *获取标详情
 */
static NSString *strTenderDetailInfoURL = @"borrow/queryBorrowDtl.shtml";

@interface BIDTenderDetailInfoViewController ()<BIDShareViewDelegate, BIDEnterpriseBriefIntroductionViewDelegate, BIDEnterpriseInfoViewDelegate, BIDGuaranteeInfoViewDelegate>
{
    NSArray *_titlesArr;
    BIDBottomView *_bottomView;
    /**
     *分享视图
     */
    BIDShareView *_shareView;
    NSMutableArray *_cellHeightArr;
    /**
     *公司简介
     */
    BIDEnterpriseBriefIntroductionView *_enterpriseBriefIntroductionView;
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
    //
    BOOL _bRegister;
    BIDCustomSpinnerView *_spinnerView;
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

@synthesize tenderId;

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
    //
    _spinnerView = [[BIDCustomSpinnerView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    [_spinnerView initLayout];
    //返回按钮设置
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backBtnHandler)];
    //分享按钮设置
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share.png"] style:UIBarButtonItemStylePlain target:self action:@selector(shareBtnHandler)];
    //创建分享视图
    _shareView = (BIDShareView*)[[[NSBundle mainBundle] loadNibNamed:@"BIDShareView" owner:self options:nil] lastObject];
    //
    [self.tableView setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:240.0f/255.0f blue:241.0f/255.0f alpha:1.0f]];
    self.tableView.tableHeaderView = [self prepareForTenderHeaderView];
    //self.tableView.tableFooterView = [self prepareTenderFooterView];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 76, 0);
    //
    _titlesArr = @[@"融资金额", @"年化收益", @"融资期限", @"还款日期", @"已融金额", @"可投金额", @"剩余时间"];
    _cellHeightArr = [[NSMutableArray alloc] init];
    //
    _bottomView = (BIDBottomView*)[[[NSBundle mainBundle] loadNibNamed:@"BIDBottomView" owner:self options:nil] lastObject];
    [_bottomView initView];
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGRect bottomViewFrame = CGRectMake(0, screenSize.height-CGRectGetHeight(_bottomView.frame), CGRectGetWidth(_bottomView.frame), CGRectGetHeight(_bottomView.frame));
    _bottomView.frame = bottomViewFrame;
    //
    for(int i=0; i<7; i++)
    {
        NSNumber *value = [NSNumber numberWithFloat:44.0f];
        [_cellHeightArr addObject:value];
    }
    //
    [self getTenderDetailInfo];
    //
    [self prepareForEnterpriseBriefIntroductionView];
    [self prepareForEnterpriseInfoView];
    [self prepareForFinancialStatusView];
    [self prepareForGuaranteeView];
    [self prepareForRepaymentPlanView];
}

- (void)viewWillAppear:(BOOL)animated
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:_bottomView];
    //监听键盘
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [_bottomView removeFromSuperview];
    [_shareView hideShareView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/**
 *获取标详情
 */
- (void)getTenderDetailInfo
{
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strTenderDetailInfoURL];
    NSString *strPost = [[NSString alloc] initWithFormat:@"jsonDataSet={\"bid\":\"%@\"}", tenderId];
    _spinnerView.content = @"";
    [_spinnerView showTheView];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        int rev = [BIDDataCommunication uploadDataByPostToURL:strURL postValue:strPost toDictionary:dictionary];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_spinnerView dismissTheView];
            if(rev==1)
            {
                if([[dictionary objectForKey:@"json"] isEqualToString:@"success"])
                {
                }
                else
                {
                    [BIDCommonMethods showAlertView:[dictionary objectForKey:@"message"] buttonTitle:@"关闭" delegate:nil tag:0];
                }
            }
            else
            {
                [BIDCommonMethods showAlertView:@"请求失败" buttonTitle:@"关闭" delegate:nil tag:0];
            }
        });
    });
}

/**
 *公司简介
 */
- (void)prepareForEnterpriseBriefIntroductionView
{
    _enterpriseBriefIntroductionView = (BIDEnterpriseBriefIntroductionView*)[[[NSBundle mainBundle] loadNibNamed:@"BIDEnterpriseBriefIntroductionView" owner:self options:nil] lastObject];
    [_enterpriseBriefIntroductionView setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:240.0f/255.0f blue:241.0f/255.0f alpha:1.0f]];
    _enterpriseBriefIntroductionView.tag = 100;
    _enterpriseBriefIntroductionView.delegate = self;
    _enterpriseBriefIntroductionView.enterpriseBriefIntroduction = companyContent;
    NSNumber *value = [NSNumber numberWithFloat:CGRectGetHeight(_enterpriseBriefIntroductionView.frame)];
    [_cellHeightArr addObject:value];
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
- (void)prepareForRepaymentPlanView
{
    NSArray *arr = @[@"序号", @"还款日期", @"已还本息", @"待还本息", @"已付罚息", @"待还罚息", @"状态"];
    NSArray *infoArr = @[@1, @2, @3, @4, @5, @6, @7, @8, @9];
    _repaymentPlanView = (BIDRepaymentPlanView*)[[[NSBundle mainBundle] loadNibNamed:@"BIDRepaymentPlanView" owner:self options:nil] lastObject];
    [_repaymentPlanView initViewWithTitles:arr infoArr:infoArr];
    _repaymentPlanView.tag = 104;
    NSNumber *value = [NSNumber numberWithFloat:CGRectGetHeight(_repaymentPlanView.frame)];
    [_cellHeightArr addObject:value];
}

/**
 *返回按钮
 */
- (void)backBtnHandler
{
    [_bottomView removeFromSuperview];
    [_shareView hideShareView];
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *分享
 */
- (void)shareBtnHandler
{
    [_shareView showShareView];
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
    CGFloat itemSpacing = 5.0f;
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
    //汽车抵押
    CGSize btnSize = CGSizeMake(58, 20);
    UIFont *btnFont = [UIFont systemFontOfSize:14.0f];
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake(leftSpacing, CGRectGetMaxY(nameLabel.frame)+lineSpacing, btnSize.width, btnSize.height);
    [btn1 setTitle:@"汽车抵押" forState:UIControlStateNormal];
    [btn1 setBackgroundColor:[UIColor darkGrayColor]];
    [btn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn1.titleLabel setFont:btnFont];
    [headerView addSubview:btn1];
    //房屋抵押
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(CGRectGetMaxX(btn1.frame)+itemSpacing, CGRectGetMinY(btn1.frame), btnSize.width, btnSize.height);
    [btn2 setTitle:@"房屋抵押" forState:UIControlStateNormal];
    [btn2 setBackgroundColor:[UIColor blackColor]];
    [btn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn2.titleLabel setFont:btnFont];
    [headerView addSubview:btn2];
    //债权转让
    UIButton *btn3 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn3.frame = CGRectMake(CGRectGetMaxX(btn2.frame)+itemSpacing, CGRectGetMinY(btn1.frame), btnSize.width, btnSize.height);
    [btn3 setTitle:@"债权转让" forState:UIControlStateNormal];
    [btn3 setBackgroundColor:[UIColor redColor]];
    [btn3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn3.titleLabel setFont:btnFont];
    [headerView addSubview:btn3];
    //时间
    CGRect timeLabelFrame = CGRectMake(CGRectGetMaxX(btn3.frame)+itemSpacing, CGRectGetMinY(btn1.frame), screenSize.width-CGRectGetMaxX(btn3.frame)-itemSpacing-rightSpacing, 20);
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:timeLabelFrame];
    [timeLabel setTextColor:[UIColor lightGrayColor]];
    [timeLabel setText:[[NSString alloc] initWithFormat:@"时间:%@", tenderStartTime]];
    [timeLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [headerView addSubview:timeLabel];
    //
    CGFloat headerViewHeight = CGRectGetMaxY(btn1.frame) + bottomSpacing;
    CGRect headerViewFrame = CGRectMake(0, 0, screenSize.width, headerViewHeight);
    headerView.frame = headerViewFrame;
    return headerView;
}

/**
 *设置标底视图
 */
- (UIView*)prepareTenderFooterView
{
    CGFloat topSpacing = 27.0f;
    CGFloat leftSpacing = 10.0f;
    CGFloat rightSpacing = 10.0f;
    CGFloat bottomSpacing = 10.0f;
    CGFloat lineSpacing = 0.0f;
    //
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    UIView *footerView = [[UIView alloc] init];
    //separator line
    CGRect lineLabelFrame = CGRectMake(leftSpacing, topSpacing, screenSize.width-leftSpacing, 1);
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:lineLabelFrame];
    [lineLabel setBackgroundColor:[UIColor colorWithRed:40.0f/255.0f green:153.0f/255.0f blue:213.0f/255.0f alpha:1.0f]];
    [footerView addSubview:lineLabel];
    //公司信息
    CGRect titleFrame = CGRectMake(leftSpacing, topSpacing+2, 150, 50);
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
    [titleLabel setText:@"公司信息"];
    [titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [titleLabel setTextColor:[UIColor lightGrayColor]];
    [footerView addSubview:titleLabel];
    //公司信息内容
    UIFont *contentFont = [UIFont systemFontOfSize:12.0f];
    CGRect contentFrame = CGRectMake(leftSpacing, CGRectGetMaxY(titleLabel.frame)+lineSpacing, screenSize.width-leftSpacing-rightSpacing, 0);
    NSDictionary *attributeDictionary = @{NSFontAttributeName:contentFont};
    CGSize contentSize = [companyContent boundingRectWithSize:CGSizeMake(CGRectGetWidth(contentFrame), MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributeDictionary context:nil].size;
    CGFloat contentHeight = ceil(contentSize.height);
    contentFrame.size.height = contentHeight;
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:contentFrame];
    contentLabel.numberOfLines = 0;
    [contentLabel setText:companyContent];
    [contentLabel setTextColor:[UIColor lightGrayColor]];
    [contentLabel setFont:contentFont];
    [footerView addSubview:contentLabel];
    //
    CGFloat footerViewHeight = CGRectGetMaxY(contentFrame) + bottomSpacing;
    CGRect footerViewFrame = CGRectMake(0, 0, screenSize.width, footerViewHeight);
    footerView.frame = footerViewFrame;
    //
    return footerView;
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGFloat keyboardHeight = keyboardSize.height;
    NSValue *durationValue = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval timeInterval;
    [durationValue getValue:&timeInterval];
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationDuration:timeInterval];
    //
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGRect bottomViewFrame = _bottomView.frame;
    bottomViewFrame.origin.y = screenSize.height - keyboardHeight - CGRectGetHeight(bottomViewFrame);
    _bottomView.frame = bottomViewFrame;
    //
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationDuration:0.30f];
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGRect bottomViewFrame = _bottomView.frame;
    bottomViewFrame.origin.y = screenSize.height - CGRectGetHeight(bottomViewFrame);
    _bottomView.frame = bottomViewFrame;
    [UIView commitAnimations];
}

#pragma mark BIDEnterpriseBriefIntroductionViewDelegate
- (void)refreshEnterpriseBriefIntroduction
{
    //更新view的高度
    NSNumber *value = [NSNumber numberWithFloat:CGRectGetHeight(_enterpriseBriefIntroductionView.frame)];
    [_cellHeightArr replaceObjectAtIndex:7 withObject:value];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:7 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
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
    }
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _titlesArr.count+5;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    NSUInteger row = indexPath.row;
    static NSString *identifier = @"identifier";
    static NSString *briefIntroductionIdentifier = @"briefIntroduction";
    static NSString *enterpriseInfoIdentifier = @"enterpriseInfo";
    static NSString *financialStatusIdentifier = @"financialStatus";
    static NSString *guaranteeInfoIdentifier = @"guaranteeInfo";
    static NSString *repaymentPlanIdentifier = @"repaymentPlan";
    if(!_bRegister)
    {
        _bRegister = YES;
        UINib *nib = [UINib nibWithNibName:@"BIDCustomCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:briefIntroductionIdentifier];
        UINib *nib1 = [UINib nibWithNibName:@"BIDEnterpriseInfoCell" bundle:nil];
        [tableView registerNib:nib1 forCellReuseIdentifier:enterpriseInfoIdentifier];
    }
    if(row<7)
    {
        NSString *strText = @"";
        NSString *strTitle = _titlesArr[row];
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if(!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        switch(row)
        {
            case 0:
            {
                //融资金额
                strText = [[NSString alloc] initWithFormat:@"%@ : %@元", strTitle, financingAmount];
            }
                break;
            case 1:
            {
                //年化收益
                strText = [[NSString alloc] initWithFormat:@"%@ : %@%%", strTitle, incomeRate];
            }
                break;
            case 2:
            {
                //融资期限
                strText = [[NSString alloc] initWithFormat:@"%@ : %@个月", strTitle, financingDuration];
            }
                break;
            case 3:
            {
                //还款日期
                strText = [[NSString alloc] initWithFormat:@"%@ : %@", strTitle, repaymentDate];
            }
                break;
            case 4:
            {
                //已融金额
                strText = [[NSString alloc] initWithFormat:@"%@ : %@元", strTitle, haveFinancing];
            }
                break;
            case 5:
            {
                //可投金额
                strText = [[NSString alloc] initWithFormat:@"%@ : %@元", strTitle, leftFinancing];
            }
                break;
            case 6:
            {
                //剩余时间
                strText = [[NSString alloc] initWithFormat:@"%@ : %@", strTitle, leftTime];
            }
                break;
        }
        cell.textLabel.text = strText;
    }
    else
    {
        //公司简介
        if(row==7)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:briefIntroductionIdentifier forIndexPath:indexPath];
            if([cell.contentView viewWithTag:100])
            {}
            else
            {
                [cell.contentView addSubview:_enterpriseBriefIntroductionView];
            }
        }
        else if(row==8)
        {
            //企业信息
            BIDEnterpriseInfoCell *infoCell = [tableView dequeueReusableCellWithIdentifier:enterpriseInfoIdentifier];
            if([infoCell.contentView viewWithTag:101])
            {}
            else
            {
                [infoCell.contentView addSubview:_enterpriseInfoView];
            }
            cell = infoCell;
        }
        else if(row==9)
        {
            //财务状况
            cell = [tableView dequeueReusableCellWithIdentifier:financialStatusIdentifier];
            if(!cell)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:financialStatusIdentifier];
            }
            if([cell.contentView viewWithTag:102])
            {}
            else
            {
                [cell.contentView addSubview:_financialStatusView];
            }
        }
        else if(row==10)
        {
            //担保信息
            cell = [tableView dequeueReusableCellWithIdentifier:guaranteeInfoIdentifier];
            if(!cell)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:guaranteeInfoIdentifier];
            }
            if([cell.contentView viewWithTag:103])
            {}
            else
            {
                [cell.contentView addSubview:_guaranteeInfoView];
            }
        }
        else if(row==11)
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
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *value = _cellHeightArr[indexPath.row];
    NSLog(@"%d:%f",indexPath.row, [value floatValue]);
    return [value floatValue];
}

@end

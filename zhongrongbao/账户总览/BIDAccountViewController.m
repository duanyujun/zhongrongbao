//
//  BIDAccountViewController.m
//  zhongrongbao
//
//  Created by mal on 14-8-26.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDAccountViewController.h"
#import "BIDAccountHeaderView.h"
#import "BIDAccountSectionView.h"
#import "BIDAccountCell.h"
#import "BIDManagerInNavViewController.h"
#import "BIDAppDelegate.h"
#import "BIDDataCommunication.h"
#import "BIDCustomSpinnerView.h"
#import "BIDCommonMethods.h"
#import "BIDRegisterPaymentPlatformViewController.h"
#import "BIDLoginViewController.h"

/**
 *查询用户累计投资、累计收益
 */
static NSString *strAccumulatedTenderAndIncomeURL = @"RepaymentDetail/CumulativeProfit.shtml";
/**
 *用户冻结金额、可用余额
 */
static NSString *strAccountInfoURL = @"Profit/queryAmt.shtml";
/**
 *是否注册汇付
 */
static NSString *strIsRegisteredURL = @"Profit/queryAugthStep.shtml";
/**
 *查询客户汇付天下账户信息
 */
static NSString *strQueryUserAccountInfoURL = @"UserPay/PnrCount.shtml";
/**
 *获取汇付天下注册地址
 */
static NSString *strQueryRegisterPaymentPlatformURL = @"UserPnr/UserRegister.shtml";

@interface BIDAccountViewController ()<BIDAccountSectionViewDelegate, UIAlertViewDelegate>
{
    NSMutableArray *_itemsArr;
    CGFloat _sectionHeaderViewHeight;
    BIDAccountSectionView *_sectionView;
    BIDAccountHeaderView *_headerView;
    BOOL _bRegister;
    /**
     *汇付天下注册地址
     */
    NSString *_registerPaymentPlatformURL;
    BIDCustomSpinnerView *_spinnerView;
}

@end

@implementation BIDAccountViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _spinnerView = [[BIDCustomSpinnerView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    [_spinnerView initLayout];
    _itemsArr = [[NSMutableArray alloc] init];
    [self.view setBackgroundColor:[UIColor colorWithRed:232.0f/255.0f green:236.0f/255.0f blue:238.0f/255.0f alpha:1.0f]];
    for(int i=0; i<3; i++)
    {
        NSNumber *value = [NSNumber numberWithInt:i];
        [_itemsArr addObject:value];
    }
    _headerView = (BIDAccountHeaderView*)[[[NSBundle mainBundle] loadNibNamed:@"BIDAccountHeaderView" owner:self options:nil] lastObject];
    [_headerView initView];
    _headerView.descriptionLabel.text = @"2014年7月28日注册后你的投资收益情况";
    _headerView.accumulatedTenderLabel.text = @"0";
    _headerView.accumulatedIncomeLabel.text = @"0";
    _headerView.rate = 1.0f;
    //_headerView.frozenLabel.text = @"0";
    //_headerView.balanceLabel.text = @"0";
    _headerView.accountLabel.text = @"";
    _headerView.totalAccountLabel.textColor = [UIColor darkGrayColor];
    _headerView.totalAccountLabel.text = @"0";
    [_headerView refreshView];
    NSLog(@"%f,%f", _headerView.frame.origin.y, _headerView.frame.size.height);
    self.tableView.tableHeaderView = _headerView;
    //
    _sectionView = (BIDAccountSectionView*)[[[NSBundle mainBundle] loadNibNamed:@"BIDAccountSectionView" owner:self options:nil] lastObject];
    [_sectionView initView];
    _sectionView.delegate = self;
    _sectionHeaderViewHeight = _sectionView.frame.size.height;
    //
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    parent.navigationItem.titleView = nil;
    parent.navigationItem.title = @"账户总览";
    parent.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"充值" style:UIBarButtonItemStylePlain target:self action:@selector(topupHandler)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self getInfoByAsynchronous];
}

/**
 *充值提现
 */
- (void)topupHandler
{
    BIDManagerInNavViewController *vc = (BIDManagerInNavViewController*)self.parentViewController;
    [vc topup];
}

/**
 *异步获取投资和收益情况
 */
- (void)getInfoByAsynchronous
{
    [_spinnerView showTheView];
    dispatch_group_t group = dispatch_group_create();
    //累计投资、累计收益
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{[self getAccumulatedTenderAndIncome];});
    //冻结金额、可用余额
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{[self getAccountInfo];});
    //
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [_spinnerView dismissTheView];
    });
}
/**
 *累计投资、累计收益
 */
- (void)getAccumulatedTenderAndIncome
{
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        NSMutableDictionary *incomeDictionary = [[NSMutableDictionary alloc] init];
        NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strAccumulatedTenderAndIncomeURL];
        int rev = [BIDDataCommunication getDataFromNet:strURL toDictionary:incomeDictionary];
        dispatch_sync(dispatch_get_main_queue(), ^{
            if(rev==1)
            {
                if([[incomeDictionary objectForKey:@"json"] isEqualToString:@"success"])
                {
                    NSDictionary *subDictionary = [incomeDictionary objectForKey:@"data"];
                    //累计投资
                    NSString *strTender = [[NSString alloc] initWithFormat:@"%@", [subDictionary objectForKey:@"allInvestAmt"]];
                    //累计收益
                    NSString *strIncome = [[NSString alloc] initWithFormat:@"%@", [subDictionary objectForKey:@"repayAmt"]] ;
                    //账户总资产
                    NSString *strTotalAssets = [[NSString alloc] initWithFormat:@"%@", [subDictionary objectForKey:@"accountTotal"]];
                    if(![BIDCommonMethods isShowWithUnitsYuan:strTender])
                    {
                        //显示万元为单位
                        strTender = [[NSString alloc] initWithFormat:@"%@万", [subDictionary objectForKey:@"allInvestAmtWan"]];
                    }
                    if(![BIDCommonMethods isShowWithUnitsYuan:strIncome])
                    {
                        strIncome = [[NSString alloc] initWithFormat:@"%@万", [subDictionary objectForKey:@"repayAmtWan"]];
                    }
                    CGFloat totalAssets = [[subDictionary objectForKey:@"accountTotal"] floatValue];
                    strTotalAssets = [[NSString alloc] initWithFormat:@"%.2f", totalAssets];
//                    if(![BIDCommonMethods isShowWithUnitsYuan:strTotalAssets])
//                    {
//                        strTotalAssets = [[NSString alloc] initWithFormat:@"%@", [subDictionary objectForKey:@"accountTotalWan"]];
//                        _headerView.totalAssetsLabel.text = [[NSString alloc] initWithFormat:@"账户总资产(万元) %@", strTotalAssets];
//                    }
//                    else
                    {
                        _headerView.totalAssetsLabel.text = [[NSString alloc] initWithFormat:@"账户总资产(元) %@", strTotalAssets];
                    }
                    
                    _headerView.accumulatedTenderLabel.text = [[NSString alloc] initWithFormat:@"%@元", strTender];
                    _headerView.accumulatedIncomeLabel.text = [[NSString alloc] initWithFormat:@"%@元", strIncome];
                    
                }
                else
                {}
            }
            else if(rev==2)
            {
            }
        });
    });
}
/**
 *用户汇付天下账户信息
 */
- (void)getAccountInfo
{
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strQueryUserAccountInfoURL];
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        int rev = [BIDDataCommunication getDataFromNet:strURL toDictionary:dictionary];
        dispatch_sync(dispatch_get_main_queue(), ^{
            if(rev==1)
            {
                if([[dictionary objectForKey:@"json"] isEqualToString:@"success"])
                {
                    NSDictionary *subDictionary = [dictionary objectForKey:@"data"];
                    if([[subDictionary objectForKey:@"pnrStatus"] isEqualToString:@"N"])
                    {
                        //未注册
                        self.parentViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"注册" style:UIBarButtonItemStyleBordered target:self action:@selector(registerPaymentPlatform)];
                        [_headerView showHintMsgLabel];
                    }
                    else
                    {
                        //已注册
                        self.parentViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"充值" style:UIBarButtonItemStylePlain target:self action:@selector(topupHandler)];
                        [_headerView hideHintMsgLabel];
                        _headerView.usernameLabel.text = [subDictionary objectForKey:@"custId"];
                        _headerView.accountLabel.text = [subDictionary objectForKey:@"usrCustId"];
                        //用户的冻结金额和可用余额的数目
                        CGFloat frozenAmount = 0.0f;
                        CGFloat totalAmount = 0.0f;
                        NSString *strFreezeAmt = [[NSString alloc] initWithFormat:@"%@", [subDictionary objectForKey:@"freezeAmt"]];
//                        if(![BIDCommonMethods isShowWithUnitsYuan:strFreezeAmt])
//                        {
//                            //以万元为单位显示
//                            strFreezeAmt = [[NSString alloc] initWithFormat:@"%@", [subDictionary objectForKey:@"freezeAmtMillion"]];
//                            _headerView.frozenLabel.text = [[NSString alloc] initWithFormat:@"冻结余额(万元) %@", strFreezeAmt];
//                            frozenAmount = [strFreezeAmt floatValue]*10000;
//                        }
//                        else
                        {
                            frozenAmount = [[subDictionary objectForKey:@"freezeAmt"] floatValue];
                            strFreezeAmt = [[NSString alloc] initWithFormat:@"%.2f", frozenAmount];
                            _headerView.frozenLabel.text = [[NSString alloc] initWithFormat:@"冻结余额(元) %@", strFreezeAmt];
                        }
                        //
                        NSString *strAvailabelAmt = [[NSString alloc] initWithFormat:@"%@", [subDictionary objectForKey:@"avaiableAmt"]];
//                        if(![BIDCommonMethods isShowWithUnitsYuan:strAvailabelAmt])
//                        {
//                            strAvailabelAmt = [[NSString alloc] initWithFormat:@"%@", [subDictionary objectForKey:@"avaiableAmtMillion"]];
//                            _headerView.balanceLabel.text = [[NSString alloc] initWithFormat:@"可用余额(万元) %@", strAvailabelAmt];
//                        }
//                        else
                        {
                            CGFloat availableAmt = [[subDictionary objectForKey:@"avaiableAmt"] floatValue];
                            strAvailabelAmt = [[NSString alloc] initWithFormat:@"%.2f", availableAmt];
                            _headerView.balanceLabel.text = [[NSString alloc] initWithFormat:@"可用余额(元) %@", strAvailabelAmt];
                        }
                        //
                        NSString *strTotalAmt = [[NSString alloc] initWithFormat:@"%@", [subDictionary objectForKey:@"totalAmt"]];
                        //手指按下时，显示具体的钱数
                        _headerView.totalAmount = [[NSString alloc] initWithFormat:@"%@", strTotalAmt];
                        if(![BIDCommonMethods isShowWithUnitsYuan:strTotalAmt])
                        {
                            strTotalAmt = [[NSString alloc] initWithFormat:@"%@", [subDictionary objectForKey:@"totalAmtMillion"]];
                            _headerView.totalAccountFlagLabel.text = @"汇付总金额(万元)";
                            totalAmount = [strTotalAmt floatValue]*10000;
                        }
                        else
                        {
                            _headerView.totalAccountFlagLabel.text = @"汇付总金额(元)";
                            totalAmount = [strTotalAmt floatValue];
                        }
                        _headerView.totalAccountLabel.textColor = [UIColor redColor];
                        _headerView.totalAccountLabel.text = strTotalAmt;
                        _headerView.rate = frozenAmount / totalAmount;
                        [_headerView refreshView];
                    }
                }
                else if(rev==2)
                {
                }
                else if(rev==0)
                {}
            }
        });
    });
}

/**
 *注册汇付天下
 */
- (void)registerPaymentPlatform
{
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strQueryRegisterPaymentPlatformURL];
    _spinnerView.content = @"请稍候..";
    [_spinnerView showTheView];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        int rev = [BIDDataCommunication getDataFromNet:strURL toDictionary:dictionary];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_spinnerView dismissTheView];
            if(rev==1)
            {
                if([[dictionary objectForKey:@"json"] isEqualToString:@"success"])
                {
                    //汇付天下注册url
                    NSString *strRegisterURL = [dictionary objectForKey:@"data"];
                    BIDRegisterPaymentPlatformViewController *vc = [[BIDRegisterPaymentPlatformViewController alloc] initWithNibName:@"BIDRegisterPaymentPlatformViewController" bundle:nil];
                    vc.registerURL = strRegisterURL;
                    [self.navigationController pushViewController:vc animated:YES];
                }
                else
                {
                    [BIDCommonMethods showAlertView:[dictionary objectForKey:@"message"] buttonTitle:@"关闭" delegate:nil tag:0];
                }
            }
            else if(rev==0)
            {
                [BIDCommonMethods showAlertView:@"请求失败" buttonTitle:@"关闭" delegate:nil tag:0];
            }
            else if(rev==2)
            {
                [BIDCommonMethods showAlertView:err_msg buttonTitle:@"关闭" delegate:self tag:2];
            }
        });
    });
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 2)
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

#pragma mark - BIDAccountSectionViewDelegate
- (void)refreshSectionView:(CGFloat)sectionViewHeight
{
    _sectionHeaderViewHeight = sectionViewHeight;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //
    return _sectionView;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    static NSString *identifier = @"identifier";
    //NSUInteger row = indexPath.row;
    if(!_bRegister)
    {
        _bRegister = YES;
        UINib *nib = [UINib nibWithNibName:@"BIDAccountCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:identifier];
    }
    BIDAccountCell *accountCell = [tableView dequeueReusableCellWithIdentifier:identifier];
    accountCell.dateLabel.text = @"8月17日";
    accountCell.typeLabel.text = @"结息";
    accountCell.moneyLabel.text = @"332元";
    [accountCell setBackgroundColor:[UIColor clearColor]];
    cell = accountCell;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return _sectionHeaderViewHeight;
}

@end

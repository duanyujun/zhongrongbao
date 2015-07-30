//
//  BIDCategoryListViewController.m
//  zhongrongbao
//
//  Created by mal on 15/6/25.
//  Copyright (c) 2015年 cnsoft. All rights reserved.
//
#import "BIDLoginViewController.h"
#import "BIDCategoryListViewController.h"
#import "BIDSubCategoryListViewController.h"
#import "BIDManagerInNavViewController.h"
#import "BIDIncomeCalendarViewController.h"
#import "BIDCategoryListHeaderView.h"
#import "BIDCategoryCell.h"
#import "BIDDataCommunication.h"

/**
 *查询用户累计投资、累计收益
 */
static NSString *strAccumulatedTenderAndIncomeURL = @"RepaymentDetail/CumulativeProfit.shtml";
/**
 *查询客户汇付天下账户信息
 */
static NSString *strQueryUserAccountInfoURL = @"UserPay/PnrCount.shtml";

@interface BIDCategoryListViewController ()<UITableViewDataSource, UITableViewDelegate, BIDCategoryListHeaderViewDelegate>
{
    BIDCategoryListHeaderView *_listHeaderView;
    NSArray *_dataSourceArr;
    NSArray *_colorArr;
    NSArray *_categoryImgNameArr;
    BOOL _bRegister;
}
@end

@implementation BIDCategoryListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _dataSourceArr = [[NSArray alloc] init];
    UIColor *color1 = [UIColor colorWithRed:255.0f/255.0f green:186.0f/255.0f blue:0 alpha:1.0f];
    UIColor *color2 = [UIColor colorWithRed:0 green:136.0f/255.0f blue:214.0f/255.0f alpha:1.0f];
    UIColor *color3 = [UIColor colorWithRed:25.0f/255.0f green:212.0f/255.0f blue:193.0f/255.0f alpha:1.0f];
    UIColor *color4 = [UIColor colorWithRed:89.0f/255.0f green:56.0f/255.0f blue:252.0f/255.0f alpha:1.0f];
    _colorArr = @[color1, color2, color3, color4];
    _categoryImgNameArr = @[@"fenlei1.png", @"fenlei2.png", @"fenlei3.png", @"fenlei4.png"];
    //create list header view
    _listHeaderView = (BIDCategoryListHeaderView*)[[[NSBundle mainBundle] loadNibNamed:@"BIDCategoryListHeaderView" owner:self options:nil] lastObject];
    _listHeaderView.delegate = self;
    [_listHeaderView setAccount:@"0"];
    [_listHeaderView setBalance:@"0"];
    [_listHeaderView setIncome:@"0"];
    //
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.tableHeaderView = _listHeaderView;
    if([BIDAppDelegate isHaveLogin])
    {
        [_listHeaderView setViewState:1];
    }
    else
    {
        [_listHeaderView setViewState:0];
    }
    //
    [self loadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if([BIDAppDelegate isHaveLogin])
    {
        [self getAccountInfo];
    }
}

- (void)didReceiveMemoryWarning {
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
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    UIColor *color = [UIColor colorWithRed:70.0f/255.0f green:94.0f/255.0f blue:114.0f/255.0f alpha:1.0f];
//    btn.layer.borderColor = color.CGColor;
//    btn.layer.borderWidth = 0.5f;
//    btn.frame = CGRectMake(0, 0, 66, 25);
//    btn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
//    [btn setTitle:@"收益日历" forState:UIControlStateNormal];
//    [btn setTitleColor:color forState:UIControlStateNormal];
//    [btn addTarget:self action:@selector(showIncomeCalendar) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
//    parent.navigationItem.rightBarButtonItem = item;
    //parent.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"收益日历" style:UIBarButtonItemStylePlain target:self action:@selector(showIncomeCalendar)];
}

/**
 *加载数据
 */
- (void)loadData
{
    NSDictionary *postInfo = @{@"body":@{}, @"head":@{@"channelType":@"05", @"funCode":@"mobileIndex", @"interfaceVersion":@"1.0", @"sid":@""}};
    NSError *err;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postInfo options:kNilOptions error:&err];
    NSString *strPost = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    strPost = [[NSString alloc] initWithFormat:@"dataMsg=%@", strPost];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableDictionary *responseDictionary = [[NSMutableDictionary alloc] init];
        int rev = [BIDDataCommunication uploadDataByPostWithoutCookie:[BIDAppDelegate SERVER_ADDR] postValue:strPost toDictionary:responseDictionary];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(rev==1)
            {
                NSDictionary *headDictionary = [responseDictionary objectForKey:@"head"];
                if([[headDictionary objectForKey:@"state"] isEqualToString:@"FAIL"])
                {
                    [BIDCommonMethods showAlertView:[headDictionary objectForKey:@"msg"] buttonTitle:@"关闭" delegate:nil tag:0];
                }
                else
                {
                    _dataSourceArr = [[NSArray alloc] initWithArray:[[responseDictionary objectForKey:@"body"] objectForKey:@"data"]];
                    [_tableView reloadData];
                }
            }
            else
            {
                [BIDCommonMethods showAlertView:@"加载失败" buttonTitle:@"关闭" delegate:nil tag:0];
            }
        });
    });
}
/*
 {"body":{"data":[{"id":"feature","name":"特色金融","des":"您的专属理财产品","sort":[{"id":"top","name":"精品"},{"id":"01","name":"私人定制"},{"id":"02","name":"新手专享"}]},
    {"id":"consumer","name":"消费金融","des":"装修、出国不再发愁！","sort":[{"id":"top","name":"精品"},{"id":":PCCB_PHONE","name":"手机分期"},{"id":"PCCB_CAR","name":"汽车金融"},{"id":"PCCB_EDUCATION","name":"教育金融"}]},
    {"id":"enterprise","name":"企业贷款","des":"高收益低风险回款快！","sort":[{"id":"top","name":"精品"},{"id":"01","name":"融抵押"},{"id":"02","name":"融担保"},{"id":"03","name":"融小贷"},{"id":"04","name":"融保理"},{"id":"05","name":"融车宝"},{"id":"06","name":"融房宝"}]},{"id":"organization","name":"机构金融","des":"","sort":[{"id":"top","name":"精品"},{"id":"01","name":"私人定制"},{"id":"02","name":"新手专享"}]}],"size":4},"head":{"code":"pi0001","msg":"有响应数据","state":"SUCC"}}
 */
/**
 *异步获取投资和收益情况
 */
- (void)getInfoByAsynchronous
{
    [self.spinnerView showTheView];
    dispatch_group_t group = dispatch_group_create();
    //累计投资、累计收益
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{[self getAccumulatedTenderAndIncome];});
    //冻结金额、可用余额
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{[self getAccountInfo];});
    //
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [self.spinnerView dismissTheView];
    });
}
/**
 *累计投资、累计收益
 */
- (void)getAccumulatedTenderAndIncome
{
    [self.spinnerView showTheView];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableDictionary *incomeDictionary = [[NSMutableDictionary alloc] init];
        NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strAccumulatedTenderAndIncomeURL];
        int rev = [BIDDataCommunication getDataFromNet:strURL toDictionary:incomeDictionary];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.spinnerView dismissTheView];
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
                    CGFloat totalAssets = [[subDictionary objectForKey:@"accountTotal"] floatValue];
                    strTotalAssets = [[NSString alloc] initWithFormat:@"%.2f", totalAssets];
                    [_listHeaderView setAccount:strTotalAssets];
                    [_listHeaderView setIncome:strIncome];
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
    [self.spinnerView showTheView];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        int rev = [BIDDataCommunication getDataFromNet:strURL toDictionary:dictionary];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.spinnerView dismissTheView];
            if(rev==1)
            {
                if([[dictionary objectForKey:@"json"] isEqualToString:@"success"])
                {
                    NSDictionary *subDictionary = [dictionary objectForKey:@"data"];
                    if([[subDictionary objectForKey:@"pnrStatus"] isEqualToString:@"N"])
                    {
                        _tableView.tableHeaderView = nil;
                        //没有注册汇付天下则不显示收益日历
                        //self.parentViewController.navigationItem.rightBarButtonItem = nil;
                    }
                    else
                    {
                        //已注册
                        self.parentViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"收益日历" style:UIBarButtonItemStylePlain target:self action:@selector(showIncomeCalendar)];
                        _tableView.tableHeaderView = _listHeaderView;
                        
                        //用户的冻结金额和可用余额的数目
                        CGFloat frozenAmount = 0.0f;
                        NSString *strFreezeAmt = [[NSString alloc] initWithFormat:@"%@", [subDictionary objectForKey:@"freezeAmt"]];
                        frozenAmount = [[subDictionary objectForKey:@"freezeAmt"] floatValue];
                        strFreezeAmt = [[NSString alloc] initWithFormat:@"%.2f", frozenAmount];
                        //
                        NSString *strAvailabelAmt = [[NSString alloc] initWithFormat:@"%@", [subDictionary objectForKey:@"avaiableAmt"]];
                        
                        CGFloat availableAmt = [[subDictionary objectForKey:@"avaiableAmt"] floatValue];
                        strAvailabelAmt = [[NSString alloc] initWithFormat:@"%.2f", availableAmt];
                        [_listHeaderView setBalance:strAvailabelAmt];
                        //
                        [self getAccumulatedTenderAndIncome];
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
 *显示收益日历
 */
- (void)showIncomeCalendar
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
        [vc incomeCalendar];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - BIDCategoryListHeaderViewDelegate
- (void)toLogin
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
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSourceArr.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    static NSString *identifier = @"identifier";
    NSUInteger row = indexPath.row;
    if(!_bRegister)
    {
        _bRegister = YES;
        UINib *nib = [UINib nibWithNibName:@"BIDCategoryCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:identifier];
    }
    BIDCategoryCell *categoryCell = [tableView dequeueReusableCellWithIdentifier:identifier];
    NSDictionary *dictionary = _dataSourceArr[row];
    categoryCell.headTitleLabel.text = [dictionary objectForKey:@"name"];
    categoryCell.subTitleLabel.text = [dictionary objectForKey:@"des"];
    categoryCell.categoryImgView.image = [UIImage imageNamed:_categoryImgNameArr[row]];
    UIColor *bgColor = _colorArr[row];
    [categoryCell setBackgroundColor:bgColor];
    categoryCell.bgColor = bgColor;
    cell = categoryCell;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BIDSubCategoryListViewController *vc = [[BIDSubCategoryListViewController alloc] initWithNibName:@"BIDSubCategoryListViewController" bundle:nil];
    NSUInteger row = indexPath.row;
    NSDictionary *dictionary = _dataSourceArr[row];
    vc.subCategoryDictionary = [[NSDictionary alloc] initWithDictionary:dictionary];
    vc.categoryColor = _colorArr[row];
    vc.categoryImg = [UIImage imageNamed:_categoryImgNameArr[row]];
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 171.0f;
}
@end

//
//  BIDFunctionListView.m
//  zhongrongbao
//
//  Created by mal on 14-8-12.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDFunctionListViewController.h"
#import "BIDLogoutView.h"
#import "BIDHaveLoginView.h"
#import "BIDLoginViewController.h"
#import "BIDRegisterViewController.h"
#import "BIDCustomSpinnerView.h"
#import "BIDCommonMethods.h"
#import "BIDDataCommunication.h"

extern NSString *err_msg;
/**
 *查询用户累计投资、累计收益
 */
static NSString *strAccumulatedTenderAndIncomeURL = @"RepaymentDetail/CumulativeProfit.shtml";
/**
 *查询客户汇付天下账户信息
 */
static NSString *strQueryUserAccountInfoURL = @"UserPay/PnrCount.shtml";

NSString *VIEW_CHANGE_EVENT = @"viewChangeEvent";
NSString *REFRESH_USERACCOUNTINFO_EVENT = @"refreshUserAccountInfoEvent";
NSString *REFRESH_PORTRAIT_EVENT = @"refreshPortraitEvent";

@interface BIDFunctionListViewController()<BIDLogoutViewDelegate, UIAlertViewDelegate>
{
    /**
     *滑动手势开始的起始点
     */
    CGPoint _startPt;
    /**
     *未登录时的视图
     */
    BIDLogoutView *_logoutView;
    /**
     *已登录过的视图
     */
    BIDHaveLoginView *_haveLoginView;
    /**
     *是否正在从后台获取用户的资产和收益值
     */
    BOOL _bLoading;
}
@end

@implementation BIDFunctionListViewController
@synthesize delegate;
@synthesize bHaveShow;
@synthesize userStatus;

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
    _bLoading = NO;
    userStatus = STATUS_LOGOUT;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUserAccountInfo) name:REFRESH_USERACCOUNTINFO_EVENT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPortrait) name:REFRESH_PORTRAIT_EVENT object:nil];
    [self initView];
}

- (void)initView
{
    bHaveShow = NO;
    _functionNameArr = @[@"我要投资", @"充值提现", @"投资信息", @"我的债权", @"推广达人", @"我的红包", @"客服电话", @"关于系统"];
    _imgNameArr = @[@"touzi.png", @"chongzhi.png", @"jiaoyichaxun.png", @"wodezhaiquan.png", @"gerenshezhi.png", @"tuiguangdaren.png", @"hongbao.png", @"kefudianhua.png", @"systemAbout.png"];
    //设置背景图片
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"functionListBg.png"]]];
    //设置角标label
    _badgeLabel.layer.cornerRadius = 10;
    _badgeLabel.clipsToBounds = YES;
    //
    //_imgView.layer.borderWidth = 5;
    //_imgView.layer.borderColor = [UIColor colorWithRed:100.0f/255.0f green:124.0f/255.0f blue:145.0f/255.0f alpha:1.0f].CGColor;
    _imgView.layer.cornerRadius = _imgView.frame.size.width/2;
    _imgView.userInteractionEnabled = YES;
    _imgView.layer.masksToBounds = YES;
    [self setPortrait];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
    [_imgView addGestureRecognizer:tapGestureRecognizer];
    //
    _haveLoginView = (BIDHaveLoginView*)[[[NSBundle mainBundle] loadNibNamed:@"BIDHaveLoginView" owner:self options:nil] lastObject];
    CGRect haveLoginViewFrame = _haveLoginView.frame;
    haveLoginViewFrame.origin.x = 123.0f;
    haveLoginViewFrame.origin.y = 69.0f;
    _haveLoginView.frame = haveLoginViewFrame;
    _haveLoginView.hidden = YES;
    [self.view addSubview:_haveLoginView];
    UITapGestureRecognizer *tapGestureRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
    [_haveLoginView addGestureRecognizer:tapGestureRecognizer1];
    //
    _logoutView = (BIDLogoutView*)[[[NSBundle mainBundle] loadNibNamed:@"BIDLogoutView" owner:self options:nil] lastObject];
    _logoutView.delegate = self;
    CGRect logoutViewFrame = _logoutView.frame;
    logoutViewFrame.origin.x = 123.0f;
    logoutViewFrame.origin.y = 69.0f;
    _logoutView.frame = logoutViewFrame;
    [self.view addSubview:_logoutView];
    //
    CGRect tableViewFrame = _tableView.frame;
    tableViewFrame.size.height = [UIScreen mainScreen].bounds.size.height-158;
    _tableView.frame = tableViewFrame;
    _tableView.scrollsToTop = NO;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorColor = [UIColor colorWithRed:67.0f/255.0f green:86.0f/255.0f blue:102.0f/255.0f alpha:1.0f];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    UIView *footerView = [[UIView alloc] init];
    _tableView.tableFooterView = footerView;
    [_tableView reloadData];
}

- (void)refreshUserStatus:(USER_STATUS)userStatus1
{
    switch(userStatus1)
    {
        case STATUS_LOGIN:
        {
            //_haveLoginView.hidden = NO;
            _logoutView.hidden = YES;
            [self setPortraitPositionForLogin];
        }
            break;
        case STATUS_LOGOUT:
        {
            //_haveLoginView.hidden = YES;
            _logoutView.hidden = NO;
            [self setPortraitPositionForLogout];
        }
            break;
    }
}

- (void)refreshUserAccountInfo
{
    if(![BIDAppDelegate isHaveLogin])
    {
        //未登录
        //_haveLoginView.hidden = YES;
        _logoutView.hidden = NO;
        [self setPortraitPositionForLogout];
    }
    else
    {
        //已登录
        //_haveLoginView.hidden = NO;
        _logoutView.hidden = YES;
        [self setPortraitPositionForLogin];
        if(!_bLoading)
        {
            [_haveLoginView.spinnerView startAnimating];
            //[self getUserAssetsAndIncome];
        }
    }
}
/**
 *设置登录后头像的位置
 */
- (void)setPortraitPositionForLogin
{
    //_badgeLabel.hidden = NO;
    CGRect frame = _imgView.frame;
    frame.origin.x = CGRectGetWidth(self.view.frame)/2-CGRectGetWidth(frame)/2;
    _imgView.frame = frame;
    //
    CGRect badgeLabelFrame = _badgeLabel.frame;
    CGFloat radius = CGRectGetWidth(_imgView.frame)/2;
    CGFloat posX = cosf(-M_PI_4) * radius + frame.origin.x + frame.size.width/2;
    CGFloat posY = sinf(-M_PI_4) * radius + frame.origin.y + frame.size.height/2;
    badgeLabelFrame.origin.x = posX - CGRectGetWidth(badgeLabelFrame)/2;
    badgeLabelFrame.origin.y = posY - CGRectGetHeight(badgeLabelFrame)/2;
    _badgeLabel.frame = badgeLabelFrame;
}
/**
 *设置未登录时头像imgView的位置
 */
- (void)setPortraitPositionForLogout
{
    _badgeLabel.hidden = YES;
    CGRect frame = _imgView.frame;
    frame.origin.x = 20;
    frame.origin.y = 62;
    _imgView.frame = frame;
}

/**
 *当手动登录成功后设置头像
 */
- (void)refreshPortrait
{
    [self setPortrait];
}

/**
 *获取用户总资产、总收益
 */
- (void)getUserAssetsAndIncome
{
    _bLoading = YES;
    [self getAccumulatedTenderAndIncome];
}
/**
 *总资产、总收益
 */
- (void)getAccumulatedTenderAndIncome
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        int state = 0;
        state = [BIDCommonMethods isHaveRegisterHFTX];
        if(state==2)
        {
            NSMutableDictionary *incomeDictionary = [[NSMutableDictionary alloc] init];
            NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strAccumulatedTenderAndIncomeURL];
            int rev = [BIDDataCommunication getDataFromNet:strURL toDictionary:incomeDictionary];
            dispatch_async(dispatch_get_main_queue(), ^{
                _bLoading = NO;
                [_haveLoginView.spinnerView stopAnimating];
                if(rev==1)
                {
                    if([[incomeDictionary objectForKey:@"json"] isEqualToString:@"success"])
                    {
                        NSDictionary *subDictionary = [incomeDictionary objectForKey:@"data"];
                        //总收益
                        CGFloat repayAmt = [[subDictionary objectForKey:@"repayAmt"] floatValue];
                        NSString *strIncome = [[NSString alloc] initWithFormat:@"%.2f ", repayAmt];
//                        if(![BIDCommonMethods isShowWithUnitsYuan:strIncome])
//                        {
//                            //以万元为单位显示
//                            strIncome = [[NSString alloc] initWithFormat:@"%@ 万", [subDictionary objectForKey:@"repayAmtWan"]];
//                        }
                        _haveLoginView.totalIncomeLabel.text = [[NSString alloc] initWithFormat:@"总收益: %@元", strIncome];
                        //总资产
                        CGFloat accountTotal = [[subDictionary objectForKey:@"accountTotal"] floatValue];
                        NSString *strAccountTotal = [[NSString alloc] initWithFormat:@"%.2f ", accountTotal];
//                        if(![BIDCommonMethods isShowWithUnitsYuan:strAccountTotal])
//                        {
//                            //以万元为单位显示
//                            strAccountTotal = [[NSString alloc] initWithFormat:@"%@ 万", [subDictionary objectForKey:@"accountTotalWan"]];
//                        }
                        _haveLoginView.totalAssetsLabel.text = [[NSString alloc] initWithFormat:@"总资产: %@元", strAccountTotal];
                    }
                    else
                    {
                        //请求失败
                        _haveLoginView.totalAssetsLabel.text = [[NSString alloc] initWithFormat:@"总资产: %@ 元", @0];
                        _haveLoginView.totalIncomeLabel.text = [[NSString alloc] initWithFormat:@"总收益: %@ 元", @0];
                    }
                }
                else if(rev==2)
                {
                    [BIDCommonMethods showAlertView:err_msg buttonTitle:@"关闭" delegate:self tag:2];
                }
            });
        }
        else if(state==3)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                _bLoading = NO;
                [_haveLoginView.spinnerView stopAnimating];
                [BIDCommonMethods showAlertView:err_msg buttonTitle:@"关闭" delegate:self tag:2];
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                _bLoading = NO;
                [_haveLoginView.spinnerView stopAnimating];
                //未注册
                _haveLoginView.totalAssetsLabel.text = [[NSString alloc] initWithFormat:@"总资产: %@ 元", @0];
                _haveLoginView.totalIncomeLabel.text = [[NSString alloc] initWithFormat:@"总收益: %@ 元", @0];
            });
        }
    });
}

/**
 *设置头像图片
 */
- (void)setPortrait
{
    //从library中找到设置过的头像图片
    NSArray *arr = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    if(arr.count>0)
    {
        NSString *portraitPath = [arr[0] stringByAppendingPathComponent:@"portraitImg/portrait.png"];
        if([[NSFileManager defaultManager] fileExistsAtPath:portraitPath])
        {
            //文件是否存在
            UIImage *img = [UIImage imageWithContentsOfFile:portraitPath];
            if(img && [BIDAppDelegate isHaveLogin])
            {
                _imgView.image = img;
            }
            else
            {
                _imgView.image = [UIImage imageNamed:@"defaultPortrait.png"];
            }
        }
        else
        {
            _imgView.image = [UIImage imageNamed:@"defaultPortrait.png"];
        }
    }
}

- (void)swipeGestureHandler:(UISwipeGestureRecognizer*)recognizer
{
    if(recognizer.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        bHaveShow = NO;
        //[delegate topViewGoBack];
    }
}

/**
 *点击头像显示(账户总览视图)个人设置
 */
- (void)tapGestureHandler:(UITapGestureRecognizer*)gestureRecognizer
{
    if(![BIDAppDelegate isHaveLogin])
    {
        [BIDCommonMethods showAlertView:@"请先登录再继续操作" buttonTitle:@"关闭" delegate:nil tag:0];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:VIEW_CHANGE_EVENT object:self userInfo:@{@"index":@14}];//13账户总览;14个人设置
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

/**
 *总资产
 */
- (void)setTotalAsset:(NSString *)totalAsset
{
    _totalAssetLabel.text = totalAsset;
}

/**
 *总收益
 */
- (void)setTotalIncome:(NSString *)totalIncome
{
    _totalIncomeLabel.text = totalIncome;
}

#pragma mark -UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==2)
    {
        [delegate showTargetVCByIndex:2];
    }
}

#pragma mark -BIDLogoutViewDelegate
- (void)toLoginOrRegisterByType:(ACTION_TYPE)actionType
{
    switch(actionType)
    {
        case ACTION_LOGIN:
        {
            [delegate showTargetVCByIndex:0];
        }
            break;
        case ACTION_REGISTER:
        {
            [delegate showTargetVCByIndex:1];
        }
            break;
    }
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _functionNameArr.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    static NSString *identifier = @"identifier";
    NSUInteger row = indexPath.row;
    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.imageView.image = [UIImage imageNamed:_imgNameArr[row]];
    NSLog(@"%f, %f", cell.imageView.frame.size.width, cell.imageView.frame.size.height);
    cell.textLabel.text = _functionNameArr[row];
    cell.textLabel.textColor = [UIColor whiteColor];
    [cell setBackgroundColor:[UIColor clearColor]];
    UIView *cellBgView = [[UIView alloc] init];
    [cellBgView setBackgroundColor:[UIColor colorWithRed:100.0f/255.0f green:124.0f/255.0f blue:145.0f/255.0f alpha:0.5f]];
    cellBgView.layer.masksToBounds = YES;
    cell.selectedBackgroundView = cellBgView;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUInteger row = indexPath.row;
    if(![BIDAppDelegate isHaveLogin])
    {
        if(row!=0 && row!=6 && row!=7)//客服电话、关于系统
        {
            [BIDCommonMethods showAlertView:@"请先登录再继续操作" buttonTitle:@"关闭" delegate:nil tag:0];
        }
        else
        {
            if(row==6)
            {
                //客服电话
                NSString *str = [[NSString alloc] initWithFormat:@"tel://%@", @"4006019198"];
                NSURL *url = [NSURL URLWithString:str];
                UIWebView *telWebView = [[UIWebView alloc] init];
                [telWebView loadRequest:[NSURLRequest requestWithURL:url]];
                [self.view addSubview:telWebView];
            }
            else
            {
                NSNumber *value = [NSNumber numberWithInt:row];
                [[NSNotificationCenter defaultCenter] postNotificationName:VIEW_CHANGE_EVENT object:self userInfo:@{@"index":value}];
            }
        }
    }
    else
    {
        if(row==6)
        {
            //客服电话
            NSString *str = [[NSString alloc] initWithFormat:@"tel://%@", @"4006019198"];
            NSURL *url = [NSURL URLWithString:str];
            UIWebView *telWebView = [[UIWebView alloc] init];
            [telWebView loadRequest:[NSURLRequest requestWithURL:url]];
            [self.view addSubview:telWebView];
        }
        else
        {
            NSNumber *value = [NSNumber numberWithInt:row];
            [[NSNotificationCenter defaultCenter] postNotificationName:VIEW_CHANGE_EVENT object:self userInfo:@{@"index":value}];
        }
    }
}

@end

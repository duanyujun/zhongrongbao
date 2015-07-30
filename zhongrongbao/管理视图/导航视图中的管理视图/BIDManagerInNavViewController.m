//
//  BIDManagerInNavViewController.m
//  zhongrongbao
//
//  Created by mal on 14-8-20.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDManagerInNavViewController.h"
#import "BIDCategoryListViewController.h"
#import "BIDHomePageViewController.h"
#import "BIDIncomeCalendarViewController.h"
#import "BIDRechargeAndWithdrawalViewController.h"
#import "BIDRechargeAndWithdrawalViewControllerII.h"
#import "BIDCustomKeyboard.h"
#import "UIView+FindFirstResponder.h"
#import "BIDPersonalSettingsViewController.h"
#import "BIDAccountViewController.h"
#import "BIDPopularizeViewController.h"
#import "BIDMyInvestListViewController.h"
#import "BIDMyInvestListView.h"
#import "BIDMyCreditRightListViewController.h"
#import "BIDSystemAboutViewController.h"
#import "BIDMyNotificationViewController.h"
#import "BIDMsgListViewController.h"

#import "BIDTenderDetailInfoViewController.h"
#import "BIDWebPageJumpViewController.h"
#import "BIDMsgDetailViewController.h"
#import "BIDRedPacketListViewController.h"

/**
 *功能列表视图滑动的距离
 */
const int kSlideDistance = 269;

@interface BIDManagerInNavViewController ()
{
    UISwipeGestureRecognizer *_leftSwipeGesture;
    UISwipeGestureRecognizer *_rightSwipeGesture;
    UIView *_maskView;
    /**
     *首页分类列表
     */
    BIDCategoryListViewController *_categoryListVC;
    /**
     *充值提现
     */
    BIDRechargeAndWithdrawalViewControllerII *_rechargeAndWithdrawalVCII;
    /**
     *收益日历
     */
    BIDIncomeCalendarViewController *_incomeCalendarVC;
    /**
     *红包
     */
    BIDRedPacketListViewController *_redPacketListVC;
}

@property (strong, nonatomic) UIViewController *currentVC;
@property (strong, nonatomic) BIDHomePageViewController *homePageVC;
@property (strong, nonatomic) BIDRechargeAndWithdrawalViewController *rechargeAndWithdrawalVC;
@property (strong, nonatomic) BIDPersonalSettingsViewController *personalSettingsVC;
@property (strong, nonatomic) BIDAccountViewController *accountVC;
@property (strong, nonatomic) BIDPopularizeViewController *popularizeVC;
@property (strong, nonatomic) BIDMyInvestListViewController *investLitVC;
@property (strong, nonatomic) BIDMyCreditRightListViewController *creditRightListVC;
@property (strong, nonatomic) BIDSystemAboutViewController *systemAboutVC;
//@property (strong, nonatomic) BIDMyNotificationViewController *notificationVC;
@property (strong, nonatomic) BIDMsgListViewController *notificationVC;

@property (strong, nonatomic) BIDTenderDetailInfoViewController *tenderVC;
@property (strong, nonatomic) BIDWebPageJumpViewController *webVC;
@property (strong, nonatomic) BIDMsgDetailViewController *msgVC;

@end

@implementation BIDManagerInNavViewController

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
    self.navigationController.navigationBarHidden = NO;
    //视图切换的消息监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewChangeEventHandler:) name:VIEW_CHANGE_EVENT object:nil];
    //设置导航栏视图和按钮
    //设置导航栏左按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"more.png"] style:UIBarButtonItemStylePlain target:self action:@selector(moreBtnHandler)];
    //
    _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), [UIScreen mainScreen].bounds.size.height-64)];
    [_maskView setBackgroundColor:[UIColor colorWithWhite:0.1f alpha:0.8f]];
    //
    /**
     *当点击推送消息进入时
     */
    if([BIDAppDelegate getAPNSInfo] && [BIDAppDelegate getAPNSInfo].count>0)
    {
        [self loadAPNSView];
    }
    else
    {
//        if(!_homePageVC)
//        {
//            _homePageVC = [[BIDHomePageViewController alloc] initWithNibName:@"BIDHomePageViewController" bundle:nil];
//            _homePageVC.view.frame = self.view.bounds;
//        }
//        [self.view addSubview:_homePageVC.view];
//        [self addChildViewController:_homePageVC];
//        [_homePageVC didMoveToParentViewController:self];
//        _currentVC = _homePageVC;
        if(!_categoryListVC)
        {
            _categoryListVC = [[BIDCategoryListViewController alloc] initWithNibName:@"BIDCategoryListViewController" bundle:nil];
            _categoryListVC.view.frame = self.view.bounds;
        }
        [self.view addSubview:_categoryListVC.view];
        [self addChildViewController:_categoryListVC];
        [_categoryListVC didMoveToParentViewController:self];
        _currentVC = _categoryListVC;
    }
    //
    //创建手势
    _leftSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureHandler:)];
    _leftSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    _rightSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureHandler:)];
    _rightSwipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:_leftSwipeGesture];
    [self.view addGestureRecognizer:_rightSwipeGesture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
}

- (void)loadAPNSView
{
    NSDictionary *apnsInfo = [BIDAppDelegate getAPNSInfo];
    NSString *strContent = [apnsInfo objectForKey:@"alert"];
    NSString *strTitle = @"新消息";
    if([strContent rangeOfString:@":"].location!=NSNotFound)
    {
        NSInteger index = [strContent rangeOfString:@":"].location;
        strTitle = [strContent substringToIndex:index];
        strContent = [strContent substringFromIndex:index+1];
    }
    //消息
    BIDMsgDetailViewController *vc = [[BIDMsgDetailViewController alloc] initWithNibName:@"BIDMsgDetailViewController" bundle:nil];
    vc.msgTitle = strTitle;
    vc.msgContent = strContent;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    vc.msgDate = strDate;
    vc.view.frame = self.view.bounds;
    [self.view addSubview:vc.view];
    [self addChildViewController:vc];
    [vc didMoveToParentViewController:self];
    _currentVC = vc;
}

/**
 *充值
 */
- (void)topup
{
    if(_currentVC)
    {
        [_currentVC.view removeFromSuperview];
        [_currentVC removeFromParentViewController];
        //_homePageVC = nil;
        _categoryListVC = nil;
        _accountVC = nil;
        //
        //充值提现
        if(!_rechargeAndWithdrawalVC)
        {
            _rechargeAndWithdrawalVC = [[BIDRechargeAndWithdrawalViewController alloc] init];
            _rechargeAndWithdrawalVC.view.frame = self.view.bounds;
        }
        [self.view addSubview:_rechargeAndWithdrawalVC.view];
        [self addChildViewController:_rechargeAndWithdrawalVC];
        [_rechargeAndWithdrawalVC didMoveToParentViewController:self];
        _currentVC = _rechargeAndWithdrawalVC;
    }
}

/**
 *收益日历
 */
- (void)incomeCalendar
{
    if(_currentVC)
    {
        [_currentVC.view removeFromSuperview];
        [_currentVC removeFromParentViewController];
        _categoryListVC = nil;
        if(!_incomeCalendarVC)
        {
            _incomeCalendarVC = [[BIDIncomeCalendarViewController alloc] initWithNibName:@"BIDIncomeCalendarViewController" bundle:nil];
            _incomeCalendarVC.view.frame = self.view.bounds;
        }
        [self.view addSubview:_incomeCalendarVC.view];
        [self addChildViewController:_incomeCalendarVC];
        [_incomeCalendarVC didMoveToParentViewController:self];
        _currentVC = _incomeCalendarVC;
    }
}

/**
 *视图切换消息响应
 */
- (void)viewChangeEventHandler:(NSNotification*)notification
{
    NSNumber *value = [[notification userInfo] objectForKey:@"index"];
    //移除已存在的viewController
    if(_currentVC && [value intValue]!=6)
    {
        [_currentVC.view removeFromSuperview];
        [_currentVC removeFromParentViewController];
        //_homePageVC = nil;
        _categoryListVC = nil;
        _incomeCalendarVC = nil;
        _rechargeAndWithdrawalVCII = nil;
        _accountVC = nil;
        _popularizeVC = nil;
        _investLitVC = nil;
        _creditRightListVC = nil;
        _systemAboutVC = nil;
        _notificationVC = nil;
        _redPacketListVC = nil;
        _personalSettingsVC = nil;
    }
    //
    switch([value intValue])
    {
        case 0:
        {
            //首页
//            if(!_homePageVC)
//            {
//                _homePageVC = [[BIDHomePageViewController alloc] initWithNibName:@"BIDHomePageViewController" bundle:nil];
//                _homePageVC.view.frame = self.view.bounds;
//            }
//            [self.view addSubview:_homePageVC.view];
//            [self addChildViewController:_homePageVC];
//            [_homePageVC didMoveToParentViewController:self];
//            _currentVC = _homePageVC;
            if(!_categoryListVC)
            {
                _categoryListVC = [[BIDCategoryListViewController alloc] initWithNibName:@"BIDCategoryListViewController" bundle:nil];
                _categoryListVC.view.frame = self.view.bounds;
            }
            [self.view addSubview:_categoryListVC.view];
            [self addChildViewController:_categoryListVC];
            [_categoryListVC didMoveToParentViewController:self];
            _currentVC = _categoryListVC;
        }
            break;
        case 1:
        {
            //充值提现
            if(!_rechargeAndWithdrawalVCII)
            {
                _rechargeAndWithdrawalVCII = [[BIDRechargeAndWithdrawalViewControllerII alloc] init];
                _rechargeAndWithdrawalVCII.view.frame = self.view.bounds;
            }
            [self.view addSubview:_rechargeAndWithdrawalVCII.view];
            [self addChildViewController:_rechargeAndWithdrawalVCII];
            [_rechargeAndWithdrawalVCII didMoveToParentViewController:self];
            _currentVC = _rechargeAndWithdrawalVCII;
        }
            break;
        case 2:
        {
            //投资信息
            if(!_investLitVC)
            {
                _investLitVC = [[BIDMyInvestListViewController alloc] init];
                _investLitVC.view.frame = self.view.bounds;
            }
            [self.view addSubview:_investLitVC.view];
            [self addChildViewController:_investLitVC];
            [_investLitVC didMoveToParentViewController:self];
            _currentVC = _investLitVC;
        }
            break;
        case 3:
        {
            //我的债权
            if(!_creditRightListVC)
            {
                _creditRightListVC = [[BIDMyCreditRightListViewController alloc] initWithNibName:@"BIDMyCreditRightListViewController" bundle:nil];
                _creditRightListVC.view.frame = self.view.bounds;
            }
            [self.view addSubview:_creditRightListVC.view];
            [self addChildViewController:_creditRightListVC];
            [_creditRightListVC didMoveToParentViewController:self];
            _currentVC = _creditRightListVC;
        }
            break;
        case 4:
        {
            //推广达人
            if(!_popularizeVC)
            {
                if([UIScreen mainScreen].bounds.size.height>=568.0f)
                {
                    _popularizeVC = [[BIDPopularizeViewController alloc] initWithNibName:@"BIDPopularizeViewController2" bundle:nil];
                }
                else
                {
                    _popularizeVC = [[BIDPopularizeViewController alloc] initWithNibName:@"BIDPopularizeViewController" bundle:nil];
                }
                _popularizeVC.view.frame = self.view.bounds;
            }
            [self.view addSubview:_popularizeVC.view];
            [self addChildViewController:_popularizeVC];
            [_popularizeVC didMoveToParentViewController:self];
            _currentVC = _popularizeVC;
        }
            break;
        case 5:
        {
            //红包
            if(!_redPacketListVC)
            {
                _redPacketListVC = [[BIDRedPacketListViewController alloc] initWithNibName:@"BIDRedPacketListViewController" bundle:nil];
                _redPacketListVC.view.frame = self.view.bounds;
            }
            [self.view addSubview:_redPacketListVC.view];
            [self addChildViewController:_redPacketListVC];
            [_redPacketListVC didMoveToParentViewController:self];
            _currentVC = _redPacketListVC;
        }
            break;
        case 6:
        {
            //客服电话
            NSString *str = [[NSString alloc] initWithFormat:@"tel://%@", @"4006567198"];
            NSURL *url = [NSURL URLWithString:str];
            UIWebView *telWebView = [[UIWebView alloc] init];
            [telWebView loadRequest:[NSURLRequest requestWithURL:url]];
            [self.view addSubview:telWebView];
        }
            break;
//        case 8:
//        {
//            //消息通知
//            if(!_notificationVC)
//            {
//                //_notificationVC = [[BIDMyNotificationViewController alloc] initWithNibName:@"BIDMyNotificationViewController" bundle:nil];
//                _notificationVC = [[BIDMsgListViewController alloc] initWithNibName:@"BIDMsgListViewController" bundle:nil];
//                _notificationVC.view.frame = self.view.bounds;
//            }
//            [self.view addSubview:_notificationVC.view];
//            [self addChildViewController:_notificationVC];
//            [_notificationVC didMoveToParentViewController:self];
//            _currentVC = _notificationVC;
//        }
//            break;
        case 7:
        {
            //关于系统
            if(!_systemAboutVC)
            {
                _systemAboutVC = [[BIDSystemAboutViewController alloc] initWithNibName:@"BIDSystemAboutViewController" bundle:nil];
                _systemAboutVC.view.frame = self.view.bounds;
            }
            [self.view addSubview:_systemAboutVC.view];
            [self addChildViewController:_systemAboutVC];
            [_systemAboutVC didMoveToParentViewController:self];
            _currentVC = _systemAboutVC;
        }
            break;
        case 13:
        {
            //账户总览
            if(!_accountVC)
            {
                _accountVC = [[BIDAccountViewController alloc] init];
                _accountVC.view.frame = self.view.bounds;
            }
            [self.view addSubview:_accountVC.view];
            [self addChildViewController:_accountVC];
            [_accountVC didMoveToParentViewController:self];
            _currentVC = _accountVC;
        }
            break;
        case 14:
        {
            if(!_personalSettingsVC)
            {
                _personalSettingsVC = [[BIDPersonalSettingsViewController alloc] initWithNibName:@"BIDPersonalSettingsViewController" bundle:nil];
                _personalSettingsVC.view.frame = self.view.bounds;
            }
            [self.view addSubview:_personalSettingsVC.view];
            [self addChildViewController:_personalSettingsVC];
            [_personalSettingsVC didMoveToParentViewController:self];
            _currentVC = _personalSettingsVC;
        }
            break;
    }
    [_maskView removeFromSuperview];
    [UIView animateWithDuration:0.3f animations:^{
        self.navigationController.view.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([[UIScreen mainScreen] bounds]));
    } completion:^(BOOL finished){}];
}

- (void)swipeGestureHandler:(UISwipeGestureRecognizer*)recognizer
{
    if(recognizer.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        [self slideToLeft];
    }
    else
    {
        [self slideToRight];
    }
}

/**
 *更多功能
 */
- (void)moreBtnHandler
{
    if(self.navigationController.view.frame.origin.x==0)
    {
        //自定义的键盘是否还在显示
        UIView *firstResponder = [self.view findFirstResponder];
        if(firstResponder) [firstResponder resignFirstResponder];
        [self slideToRight];
    }
    else
    {
        [self slideToLeft];
    }
}

/**
 *视图向左滑动
 */
- (void)slideToLeft
{
    if(self.navigationController.view.frame.origin.x>0)
    {
        //有推送消息的时候
        if([_currentVC isKindOfClass:[BIDTenderDetailInfoViewController class]])
        {
            [(BIDTenderDetailInfoViewController*)_currentVC showBottomView];
        }
        //
        [_maskView removeFromSuperview];
        [UIView animateWithDuration:0.5f animations:^{
            CGRect frame = self.navigationController.view.frame;
            frame.origin.x -= kSlideDistance;
            self.navigationController.view.frame = frame;
        } completion:^(BOOL bFinished){
            if(bFinished)
            {
            }
        }];
    }
}

/**
 *视图向右滑动
 */
- (void)slideToRight
{
    if(self.navigationController.view.frame.origin.x==0)
    {
        //有推送消息的时候
        if([_currentVC isKindOfClass:[BIDTenderDetailInfoViewController class]])
        {
            [(BIDTenderDetailInfoViewController*)_currentVC hideBottomView];
        }
        else if([_currentVC isKindOfClass:[BIDMsgListViewController class]])
        {
            [(BIDMsgListViewController*)_currentVC dismissToolBar];
        }
        //
        [self.view addSubview:_maskView];
        [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_USERACCOUNTINFO_EVENT object:self];
        [UIView animateWithDuration:0.5f animations:^{
            CGRect frame = self.navigationController.view.frame;
            frame.origin.x += kSlideDistance;
            self.navigationController.view.frame = frame;
        } completion:^(BOOL finished){
            if(finished)
            {
            }
        }];
    }
}

- (void)removeMaskView
{
    [_maskView removeFromSuperview];
}

@end

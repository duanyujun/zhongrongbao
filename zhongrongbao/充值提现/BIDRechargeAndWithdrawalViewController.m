//
//  BIDRechargeAndWithdrawalViewController.m
//  zhongrongbao
//
//  Created by mal on 14-8-18.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDRechargeAndWithdrawalViewController.h"
#import "BIDHeaderViewForRechargeAndWithdrawal.h"
#import "BIDRechargeAndWithdrawalCell.h"
#import "BIDWithdrawalHeaderView.h"
#import "BIDWithdrawalFooterView.h"

#import "BIDRechargeViewController.h"
#import "BIDWithdrawalViewController.h"
#import "BIDOpenHFTXViewController.h"
#import "BIDLoginViewController.h"

/**
 *查询客户汇付天下账户信息
 */
static NSString *strQueryUserAccountInfoURL = @"UserPay/PnrCount.shtml";

@interface BIDRechargeAndWithdrawalViewController ()<UIAlertViewDelegate>
{
    BOOL _bRegister;
    BIDWithdrawalHeaderView *_withdrawalHeaderView;
    BIDHeaderViewForRechargeAndWithdrawal *_rechargeHeaderView;
    BIDWithdrawalFooterView *_withdrawalFooterView;
    
}
//充值视图
@property (strong, nonatomic) BIDRechargeViewController *rechargeVC;
//提现视图
@property (strong, nonatomic) BIDWithdrawalViewController *withdrawalVC;

@end

@implementation BIDRechargeAndWithdrawalViewController

//- (id)initWithStyle:(UITableViewStyle)style
//{
//    self = [super initWithStyle:style];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

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
    [_segmentedCtrlBgView setBackgroundColor:[UIColor colorWithRed:52.0f/255.0f green:152.0f/255.0f blue:219.0f/255.0f alpha:1.0f]];
    //
    [_mySegmentedControl addTarget:self action:@selector(segmentedControlValueChangedHandler:) forControlEvents:UIControlEventValueChanged];
    //
    CGRect ownFrame = self.view.frame;
    ownFrame.size.height = [UIScreen mainScreen].bounds.size.height-64;
    self.view.frame = ownFrame;
    //
    _rechargeVC = [[BIDRechargeViewController alloc] initWithNibName:@"BIDRechargeViewController" bundle:nil];
    _rechargeVC.view.frame = CGRectMake(0, 45, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.bounds)-45);
    [self.view addSubview:_rechargeVC.view];
    [self addChildViewController:_rechargeVC];
    [_rechargeVC didMoveToParentViewController:self];
    //初始化提现视图
    _withdrawalVC = [[BIDWithdrawalViewController alloc] init];
    _withdrawalVC.view.frame = CGRectMake(0, 45, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.bounds)-45);
    //
    [self isHaveRegisterHFTX];
}

- (void)viewDidAppear:(BOOL)animated
{
    
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    //
    parent.navigationItem.titleView = nil;
    parent.navigationItem.title = @"充值提现";
    parent.navigationItem.rightBarButtonItem = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *判断是否注册了汇付天下，没注册则跳转汇付注册界面
 */
- (void)isHaveRegisterHFTX
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
                        //未注册
                        [_withdrawalVC setAvailableAmt:@"00.00"];
                        BIDOpenHFTXViewController *vc = [[BIDOpenHFTXViewController alloc] initWithNibName:@"BIDOpenHFTXViewController" bundle:nil];
                        [self.navigationController pushViewController:vc animated:YES];
                    }
                    else
                    {
                        CGFloat availableAmt = [[subDictionary objectForKey:@"avaiableAmt"] floatValue];
                        NSString *strAvailabelAmt = [[NSString alloc] initWithFormat:@"%.2f 元", availableAmt];
//                        if(![BIDCommonMethods isShowWithUnitsYuan:strAvailabelAmt])
//                        {
//                            strAvailabelAmt = [[NSString alloc] initWithFormat:@"%@ 万元", [subDictionary objectForKey:@"avaiableAmtMillion"]];
//                        }
                        [_withdrawalVC setAvailableAmt:strAvailabelAmt];
                    }
                }
                else
                {
                }
            }
            else if(rev==2)
            {
                [BIDCommonMethods showAlertView:err_msg buttonTitle:@"关闭" delegate:self tag:2];
            }
        });
    });
}

- (void)segmentedControlValueChangedHandler:(UISegmentedControl*)segmentedControl
{
    if(segmentedControl.selectedSegmentIndex == 0)
    {
        [_withdrawalVC.view removeFromSuperview];
        [_withdrawalVC removeFromParentViewController];
        //充值
        if(!_rechargeVC)
        {
            _rechargeVC = [[BIDRechargeViewController alloc] initWithNibName:@"BIDRechargeViewController" bundle:nil];
            _rechargeVC.view.frame = CGRectMake(0, 45, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.bounds)-45);
        }
        [self.view addSubview:_rechargeVC.view];
        [self addChildViewController:_rechargeVC];
        [_rechargeVC didMoveToParentViewController:self];
    }
    else
    {
        [_rechargeVC.view removeFromSuperview];
        [_rechargeVC removeFromParentViewController];
        //提现
        if(!_withdrawalVC)
        {
            _withdrawalVC = [[BIDWithdrawalViewController alloc] init];
            _withdrawalVC.view.frame = CGRectMake(0, 45, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.bounds)-45);
        }
        [self.view addSubview:_withdrawalVC.view];
        [self addChildViewController:_withdrawalVC];
        [_withdrawalVC didMoveToParentViewController:self];
    }
}

#pragma mark -UIAlertViewDelegate
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

@end

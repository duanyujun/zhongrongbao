//
//  BIDWithdrawalViewController.m
//  zhongrongbao
//
//  Created by mal on 14-10-16.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDWithdrawalViewController.h"
#import "BIDWithdrawalFooterView.h"
#import "BIDWithdrawalHeaderView.h"
#import "BIDDataCommunication.h"
#import "BIDCommonMethods.h"
#import "BIDAppDelegate.h"
#import "BIDCustomSpinnerView.h"
#import "BIDWebPageJumpViewController.h"
#import "BIDOpenHFTXViewController.h"
#import "BIDLoginViewController.h"
/**
 *查询客户汇付天下账户信息
 */
static NSString *strQueryUserAccountInfoURL = @"UserPay/PnrCount.shtml";
/**
 *提现
 */
static NSString *strWithdrawalURL = @"UserPay/Cash.shtml";
/**
 *判断是否绑定了银行卡
 */
static NSString *queryBankCardInfoURL = @"BankCard/queryBank.shtml";

@interface BIDWithdrawalViewController ()<BIDWithdrawalHeaderViewDelegate, UIAlertViewDelegate>
{
    BIDWithdrawalHeaderView *_headerView;
    BIDWithdrawalFooterView *_footerView;
    BIDCustomSpinnerView *_spinnerView;
    //绑定银行卡的链接地址
    NSString *_bindingBankCardURL;
    
    /**
     *是否注册了汇付天下
     */
    BOOL _bHaveRegisterHFTX;
    /**
     *是否绑定了银行卡
     */
    BOOL _bHaveBindingBankCard;
    /**
     *账户可用余额
     */
    NSString *_availableAmount;
}

@end

@implementation BIDWithdrawalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"取现";
    _bHaveRegisterHFTX = NO;
    _bHaveBindingBankCard = NO;
    //
    _spinnerView = [[BIDCustomSpinnerView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    [_spinnerView initLayout];
    _spinnerView.content = @"";
    //
    _headerView = [[[NSBundle mainBundle] loadNibNamed:@"BIDWithdrawalHeaderView" owner:self options:nil] lastObject];
    [_headerView initView];
    _headerView.delegate = self;
    //
    _footerView = [[[NSBundle mainBundle] loadNibNamed:@"BIDWithdrawalFooterView" owner:self options:nil] lastObject];
    //提现说明
    NSString *strHint = @"1、请输入您要取出金额,我们将在1至3个工作日(国家节假日除外)之内将钱转入您网站上填写的银行账号。\r\n2、如你急需要把钱转到你的账号或者24小时之内网站未将钱转入到你的银行账号,请联系客服中心。\r\n3、确保您的银行账号的姓名和您的网站上的真实姓名一致。";
    [_footerView refreshFooterView:strHint];
    
    _tableView.tableHeaderView = _headerView;
    _tableView.tableFooterView = _footerView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [self getAvailabelAmount];
}
/**
 *获取用户可用余额
 */
- (void)getAvailabelAmount
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
                        //未注册,则提示是否注册
                    }
                    else
                    {
                        _bHaveRegisterHFTX = YES;
                        CGFloat availableAmt = [[subDictionary objectForKey:@"avaiableAmt"] floatValue];
                        NSString *strAvailabelAmt = [[NSString alloc] initWithFormat:@"%.2f 元", availableAmt];
                        _availableAmount = [[NSString alloc] initWithFormat:@"%f", availableAmt];
                        _headerView.availableBalanceLabel.text = strAvailabelAmt;
                        //
                        if(!_bHaveBindingBankCard)
                        {
                            [self queryBankCardInfo];
                        }
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
/**
 *查询银行卡列表
 */
- (void)queryBankCardInfo
{
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], queryBankCardInfoURL];
    [self.spinnerView showTheView];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableDictionary *responseDictionary = [[NSMutableDictionary alloc] init];
        int rev = [BIDDataCommunication getDataFromNet:strURL toDictionary:responseDictionary];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.spinnerView dismissTheView];
            if(rev==1)
            {
                if([[responseDictionary objectForKey:@"json"] isEqualToString:@"success"])
                {
                    //银行卡数目
                    NSNumber *value = [responseDictionary objectForKey:@"exp1"];
                    if([value intValue]>0)
                    {
                        _bHaveBindingBankCard = YES;
                        [_headerView isShowBindingBankView:NO];
                    }
                    else
                    {
                        _bHaveBindingBankCard = NO;
                        [_headerView isShowBindingBankView:YES];
                        _bindingBankCardURL = [responseDictionary objectForKey:@"exp2"];
                    }
                }
                else
                {
                    NSString *strErrorMsg = [responseDictionary objectForKey:@"message"];
                    [BIDCommonMethods showAlertView:strErrorMsg buttonTitle:@"关闭" delegate:nil tag:0];
                }
            }
            else if(rev==2)
            {
                [BIDCommonMethods showAlertView:err_msg buttonTitle:@"关闭" delegate:self tag:2];
            }
            else
            {
                [BIDCommonMethods showAlertView:@"请求失败,请稍后重试" buttonTitle:@"关闭" delegate:nil tag:0];
            }
        });
    });
}

- (void)setAvailableAmt:(NSString *)strAmount
{
    _headerView.availableBalanceLabel.text = strAmount;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1 && alertView.tag==0)
    {
        BIDOpenHFTXViewController *vc = [[BIDOpenHFTXViewController alloc] initWithNibName:@"BIDOpenHFTXViewController" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if(alertView.tag==2)
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

#pragma mark - BIDWithdrawalHeaderViewDelegate
//绑定银行卡
- (void)toBindingBankCard
{
    if(!_bHaveRegisterHFTX)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"需要注册汇付天下才能继续操作,是否注册" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
        alertView.tag = 1;
        [alertView show];
    }
    else
    {
        BIDWebPageJumpViewController *vc = [[BIDWebPageJumpViewController alloc] initWithNibName:@"BIDWebPageJumpViewController" bundle:nil];
        vc.desURL = _bindingBankCardURL;
        [self.navigationController pushViewController:vc animated:YES];
    }
}
//提现
- (void)toWithdrawalWithAmount:(NSString *)strAmount
{
    if([strAmount rangeOfString:@"."].location!=NSNotFound && [strAmount rangeOfString:@"."].location==strAmount.length-1)
    {
        NSRange range = [strAmount rangeOfString:@"."];
        strAmount = [strAmount stringByReplacingCharactersInRange:range withString:@""];
    }
    if(strAmount.length==0)
    {
        [BIDCommonMethods showAlertView:@"请先输入要提取的金额" buttonTitle:@"关闭" delegate:nil tag:0];
        return;
    }
    if([_availableAmount floatValue]<[strAmount floatValue])
    {
        [BIDCommonMethods showAlertView:@"余额不足" buttonTitle:@"关闭" delegate:nil tag:0];
        return;
    }
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strWithdrawalURL];
    NSString *strPost = [[NSString alloc] initWithFormat:@"jsonDataSet={\"transAmt\":\"%@\", \"plantType\":\"PNR_USR\"}", strAmount];
    [_spinnerView showTheView];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        int state = [BIDCommonMethods isHaveRegisterHFTX];
        if(state==1)
        {
            //未注册汇付天下
            dispatch_async(dispatch_get_main_queue(), ^{
                [_spinnerView dismissTheView];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"需要注册汇付天下才能继续操作,是否注册" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
                alertView.tag = 1;
                [alertView show];
            });
        }
        else if(state==2)
        {
            //已注册汇付天下
            int rev = [BIDDataCommunication uploadDataByPostToURL:strURL postValue:strPost toDictionary:dictionary];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_spinnerView dismissTheView];
                if(rev==1)
                {
                    if([[dictionary objectForKey:@"json"] isEqualToString:@"success"])
                    {
                        NSString *strRegisterURL = [dictionary objectForKey:@"data"];
                        BIDWebPageJumpViewController *vc = [[BIDWebPageJumpViewController alloc] initWithNibName:@"BIDWebPageJumpViewController" bundle:nil];
                        vc.desURL = strRegisterURL;
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
        else if(state==3)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_spinnerView dismissTheView];
                [BIDCommonMethods showAlertView:err_msg buttonTitle:@"关闭" delegate:self tag:2];
            });
        }
    });
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

@end

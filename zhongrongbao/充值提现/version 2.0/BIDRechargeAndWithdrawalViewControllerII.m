//
//  BIDRechargeAndWithdrawalViewControllerII.m
//  zhongrongbao
//
//  Created by mal on 15/6/28.
//  Copyright (c) 2015年 cnsoft. All rights reserved.
//

#import "BIDRechargeAndWithdrawalViewControllerII.h"
#import "BIDOpenHFTXViewController.h"
#import "BIDBankCardListViewController.h"
#import "BIDWebPageJumpViewController.h"
#import "BIDRechargeViewController.h"
#import "BIDWithdrawalViewController.h"
#import "BIDLoginViewController.h"

/**
 *查询客户汇付天下账户信息
 */
static NSString *strQueryUserAccountInfoURL = @"UserPay/PnrCount.shtml";
/**
 *获取用户基本信息
 */
static NSString *strGetUserBaseInfoURL = @"UserAccount/queryAccount.shtml";
/**
 *查询银行卡列表
 */
static NSString *queryBankCardInfoURL = @"BankCard/queryBank.shtml";
/**
 *绑定银行卡
 */
static NSString *bindingBankCardURL = @"UserPnr/UserBindCard.shtml";

@interface BIDRechargeAndWithdrawalViewControllerII ()<UIAlertViewDelegate>
{
    /**
     *银行卡数组
     */
    NSArray *bankCardInfoArr;
    /**
     *是否注册了汇付天下
     */
    BOOL _bHaveRegisterHFTX;
}

@end

@implementation BIDRechargeAndWithdrawalViewControllerII

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _portraitImgView.image = [BIDCommonMethods getPortrait];
    _portraitImgView.layer.cornerRadius = CGRectGetWidth(_portraitImgView.frame)/2;
    _portraitImgView.clipsToBounds = YES;
    //[self getUserBaseInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getUserBaseInfo];
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    parent.navigationItem.titleView = nil;
    parent.navigationItem.title = @"充值提现";
    parent.navigationItem.rightBarButtonItem = nil;
}

/**
 *添加或管理银行卡
 */
- (IBAction)addOrManageBtnHandler:(id)sender
{
    if(bankCardInfoArr.count>0)
    {
        //管理银行卡
        BIDBankCardListViewController *vc = [[BIDBankCardListViewController alloc] initWithNibName:@"BIDBankCardListViewController" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        //添加银行卡
        NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], bindingBankCardURL];
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
                        NSString *strJumpURL = [responseDictionary objectForKey:@"data"];
                        BIDWebPageJumpViewController *vc = [[BIDWebPageJumpViewController alloc] initWithNibName:@"BIDWebPageJumpViewController" bundle:nil];
                        vc.desURL = strJumpURL;
                        [self.navigationController pushViewController:vc animated:YES];
                    }
                    else
                    {
                        [BIDCommonMethods showAlertView:[responseDictionary objectForKey:@"message"] buttonTitle:@"关闭" delegate:nil tag:0];
                    }
                }
                else if(rev==2)
                {
                    [BIDCommonMethods showAlertView:err_msg buttonTitle:@"关闭" delegate:nil tag:0];
                }
                else
                {
                    [BIDCommonMethods showAlertView:@"请求失败" buttonTitle:@"关闭" delegate:nil tag:0];
                }
            });
        });
    }
}
/**
 *充值
 */
- (IBAction)rechargeBtnHandler:(id)sender
{
    if(!_bHaveRegisterHFTX)
    {
        [self hintToRegisterHFTX];
        return;
    }
    BIDRechargeViewController *vc = [[BIDRechargeViewController alloc] initWithNibName:@"BIDRechargeViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}
/**
 *提现
 */
- (IBAction)withdrawalBtnHandler:(id)sender
{
    if(!_bHaveRegisterHFTX)
    {
        [self hintToRegisterHFTX];
        return;
    }
    BIDWithdrawalViewController *vc = [[BIDWithdrawalViewController alloc] initWithNibName:@"BIDWithdrawalViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 *获取用户基本信息
 */
- (void)getUserBaseInfo
{
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strGetUserBaseInfoURL];
    [self.spinnerView showTheView];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableDictionary *dicitonary = [[NSMutableDictionary alloc] init];
        int rev = [BIDDataCommunication getDataFromNet:strURL toDictionary:dicitonary];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.spinnerView dismissTheView];
            if(rev==1)
            {
                if([[dicitonary objectForKey:@"json"] isEqualToString:@"success"])
                {
                    NSDictionary *userInfo = [[NSDictionary alloc] initWithDictionary:[dicitonary objectForKey:@"data"] copyItems:YES];
                    NSString *strName = [userInfo objectForKey:@"nickName"];
                    if(strName.length==0)
                    {
                        strName = [userInfo objectForKey:@"userId"];
                    }
                    _nameLabel.text = strName;
                    _accountLabel.text = [userInfo objectForKey:@"email"];
                    //
                    [self isHaveRegisterHFTX];
                }
                else
                {}
            }
            else if(rev==2)
            {
                [BIDCommonMethods showAlertView:err_msg buttonTitle:@"关闭" delegate:self tag:2];
            }
            else
            {}
        });
    });
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
                        //未注册,则提示是否注册
                        [self hintToRegisterHFTX];
                    }
                    else
                    {
                        _bHaveRegisterHFTX = YES;
                        CGFloat availableAmt = [[subDictionary objectForKey:@"avaiableAmt"] floatValue];
                        NSString *strAvailabelAmt = [[NSString alloc] initWithFormat:@"%.2f 元", availableAmt];
                        _balanceLabel.text = strAvailabelAmt;
                        //查询银行卡列表
                        [self queryBankCardInfo];
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
                    _bankcardCountLabel.text = [[NSString alloc] initWithFormat:@"%@张", value];
                    bankCardInfoArr = [[NSArray alloc] initWithArray:[responseDictionary objectForKey:@"dataList"]];
                    if([value intValue]>0)
                    {
                        [_addOrManageBtn setTitle:@"[管 理]" forState:UIControlStateNormal];
                    }
                    else
                    {
                        [_addOrManageBtn setTitle:@"[添 加]" forState:UIControlStateNormal];
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
                [BIDCommonMethods showAlertView:err_msg buttonTitle:@"关闭" delegate:nil tag:0];
            }
            else
            {
                [BIDCommonMethods showAlertView:@"请求失败,请稍后重试" buttonTitle:@"关闭" delegate:nil tag:0];
            }
        });
    });
}
/**
 *提示还未注册汇付天下
 */
- (void)hintToRegisterHFTX
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"尚未注册汇付天下，是否注册" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
    alertView.tag = 1;
    [alertView show];
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==1)
    {
        //注册汇付天下
        if(buttonIndex==1)
        {
            BIDOpenHFTXViewController *vc = [[BIDOpenHFTXViewController alloc] initWithNibName:@"BIDOpenHFTXViewController" bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else if(alertView.tag==2)
    {
        //返回登录界面
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

@end

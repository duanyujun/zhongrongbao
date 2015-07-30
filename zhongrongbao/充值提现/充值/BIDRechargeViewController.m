//
//  BIDRechargeViewController.m
//  zhongrongbao
//
//  Created by mal on 14-10-16.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDRechargeViewController.h"
#import "BIDCustomKeyboard.h"
#import "BIDWebPageJumpViewController.h"
#import "BIDOpenHFTXViewController.h"
#import "BIDLoginViewController.h"
#import "BIDPaymentMethodListViewController.h"

/**
 *充值
 */
static NSString *strRechargeURL = @"UserPay/ReCharge.shtml";

@interface BIDRechargeViewController ()<BIDCustomKeyboardDelegate, UIAlertViewDelegate>

@end

@implementation BIDRechargeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"充值";
    //[self.view setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:240.0f/255.0f blue:241.0f/255.0f alpha:1.0f]];
    //
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [label setText:@"元"];
    [label setTextColor:[UIColor whiteColor]];
    [label setTextColor:[UIColor lightGrayColor]];
    [label setFont:[UIFont systemFontOfSize:12.0f]];
    _amountTF.rightView = label;
    _amountTF.rightViewMode = UITextFieldViewModeAlways;
    //_amountTF.layer.borderWidth = 1;
    //_amountTF.layer.borderColor = [UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0f].CGColor;
    _customKeyboard = (BIDCustomKeyboard*)[[[NSBundle mainBundle] loadNibNamed:@"BIDCustomKeyboard" owner:self options:nil] lastObject];
    [_customKeyboard initView];
    _customKeyboard.delegate = self;
    _customKeyboard.textField = _amountTF;
    _amountTF.inputView = _customKeyboard;
    //
    [BIDCommonMethods setImgForBtn:_rechargeBtn imgForNormal:@"redBtnBgNormal.png" imgForPress:@"redBtnBgPress.png" inset:UIEdgeInsetsMake(10, 10, 11, 11)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//充值
- (IBAction)rechargeBtnHandler:(id)sender
{
    [self toRecharge];
}

- (void)toRecharge
{
    NSString *strAmount = _amountTF.text;
    if(strAmount.length==0)
    {
        [BIDCommonMethods showAlertView:@"请先输入要充值的金额" buttonTitle:@"关闭" delegate:nil tag:0];
        return;
    }
    if([strAmount rangeOfString:@"."].location!=NSNotFound && [strAmount rangeOfString:@"."].location==strAmount.length-1)
    {
        NSRange range = [strAmount rangeOfString:@"."];
        strAmount = [strAmount stringByReplacingCharactersInRange:range withString:@""];
    }
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strRechargeURL];
    NSString *strPost = [[NSString alloc] initWithFormat:@"jsonDataSet={\"transAmt\":\"%@\", \"plantType\":\"PNR_USR\"}", strAmount];
    [self.spinnerView showTheView];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        //int state = [BIDCommonMethods isHaveRegisterHFTX];
        //上一步已经判断过是否注册了汇付天下，所以此处无需再次判断
        int state = 2;
        if(state==1)
        {
            //未开通汇付天下
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.spinnerView dismissTheView];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"需要注册汇付天下才能继续操作,是否注册" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
                alertView.tag = 1;
                [alertView show];
            });
        }
        else if(state==2)
        {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.spinnerView dismissTheView];
//                BIDPaymentMethodListViewController *vc = [[BIDPaymentMethodListViewController alloc] initWithNibName:@"BIDPaymentMethodListViewController" bundle:nil];
//                vc.rechargeAmount = strAmount;
//                [self.navigationController pushViewController:vc animated:YES];
//            });
            //已开通汇付天下
            int rev = [BIDDataCommunication uploadDataByPostToURL:strURL postValue:strPost toDictionary:dictionary];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.spinnerView dismissTheView];
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
                        [BIDCommonMethods showAlertView:[dictionary objectForKey:@"message"] buttonTitle:@"关闭" delegate:self tag:0];
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
        }
        else if(state==3)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.spinnerView dismissTheView];
                [BIDCommonMethods showAlertView:err_msg buttonTitle:@"关闭" delegate:self tag:2];
            });
        }
    });
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
        //返回登录界面
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

#pragma mark BIDCustomKeyboardDelegate

- (void)dismissKeyboard
{
    [_amountTF resignFirstResponder];
}
/**
 *充值
 */
- (void)rechargeOrWithdrawal
{
    [self toRecharge];
}

@end

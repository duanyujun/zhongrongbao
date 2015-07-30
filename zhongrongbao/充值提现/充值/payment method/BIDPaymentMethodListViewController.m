//
//  BIDPaymentMethodListViewController.m
//  zhongrongbao
//
//  Created by mal on 15/6/29.
//  Copyright (c) 2015年 cnsoft. All rights reserved.
//

#import "BIDPaymentMethodListViewController.h"
#import "BIDWebPageJumpViewController.h"
#import "BIDLoginViewController.h"

/**
 *充值
 */
static NSString *strRechargeURL = @"UserPay/ReCharge.shtml";

@interface BIDPaymentMethodListViewController ()<UIAlertViewDelegate>
{
    NSArray *_dataSourceArr;
}
@end

@implementation BIDPaymentMethodListViewController
@synthesize rechargeAmount;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"充值方式";
    // Do any additional setup after loading the view from its nib.
    _dataSourceArr = @[@{@"title":@"银行卡快捷充值(推荐)", @"subTitle":@"无需网银、无手续费、快捷安全"}, @{@"title":@"汇付天下", @"subTitle":@"登录汇付天下，网银支付"}];
    _tableView.tableFooterView = [[UIView alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *汇付天下充值
 */
- (void)rechargeByHFTX
{
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strRechargeURL];
    NSString *strPost = [[NSString alloc] initWithFormat:@"jsonDataSet={\"transAmt\":\"%@\", \"plantType\":\"PNR_USR\"}", rechargeAmount];
    [self.spinnerView showTheView];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        int rev = [BIDDataCommunication uploadDataByPostWithoutCookie:strURL postValue:strPost toDictionary:dictionary];
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
    });
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==2)
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
    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    NSDictionary *dictionary = _dataSourceArr[row];
    cell.textLabel.text = [dictionary objectForKey:@"title"];
    cell.detailTextLabel.text = [dictionary objectForKey:@"subTitle"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUInteger row = indexPath.row;
    switch(row)
    {
        case 0:
        {
            //
        }
            break;
        case 1:
        {
            //汇付天下
            [self rechargeByHFTX];
        }
            break;
    }
}

@end

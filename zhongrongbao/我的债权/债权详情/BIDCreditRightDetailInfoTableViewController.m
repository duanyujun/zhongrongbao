//
//  BIDCreditRightDetailInfoTableViewController.m
//  zhongrongbao
//
//  Created by mal on 14-10-16.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDCreditRightDetailInfoTableViewController.h"
#import "BIDDetailInfoCell.h"
#import "BIDDataCommunication.h"
#import "BIDCommonMethods.h"
#import "BIDAppDelegate.h"
#import "BIDCustomSpinnerView.h"
#import "BIDLoginViewController.h"
#import "BIDTransferCreditRightViewController.h"

/**
 *债权详情
 */
static NSString *strDetailInfoURL = @"DebtTransfer/queryTransfer.shtml";
/**
 *发布债权
 */
static NSString *strPublishURL = @"DebtTransfer/releaseTrans.shtml";
/**
 *撤销债权
 */
static NSString *strWithdrawURL = @"DebtTransfer/repealTrans.shtml";

@interface BIDCreditRightDetailInfoTableViewController ()<UIAlertViewDelegate>
{
    //
    NSString *_debtStatus;
    //
    NSArray *_titleArr;
    //
    NSArray *_fieldArr;
    //
    BUTTON_TYPE _btnType;
    //
    CGFloat _firstRowHeight;
    //
    NSMutableDictionary *_investDictionary;
    //
    BIDCustomSpinnerView *_spinnerView;
    //
    BOOL _bRegister;
}

@end

@implementation BIDCreditRightDetailInfoTableViewController
@synthesize investId;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"债权转让记录";
    [self.tableView setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:240.0f/255.0f blue:241.0f/255.0f alpha:1.0f]];
    //
    //返回按钮设置
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backBtnHandler)];
    //
    self.tableView.allowsSelection = NO;
    //
    _spinnerView = [[BIDCustomSpinnerView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    [_spinnerView initLayout];
    _spinnerView.content = @"";
    //
    [self prepareForData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *返回按钮
 */
- (void)backBtnHandler
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)prepareForData
{
    _btnType = BUTTON_NULL;
    _firstRowHeight = 0.0f;
    _investDictionary = [[NSMutableDictionary alloc] init];
    _titleArr = @[@"标题", @"债权总额", @"成交价格", @"标的期数", @"转让状态", @"手续费", @"预期收益总额", @"转让截止日期", @"操作"];
    _fieldArr = @[@"borrowName", @"debtAmt", @"dealAmt", @"deadline", @"debtStatusName", @"fee", @"profitAmt", @"closingDate"];
    //
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strDetailInfoURL];
    NSString *strPost = [[NSString alloc] initWithFormat:@"jsonDataSet={\"investId\":\"%@\"}", investId];
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
                    NSDictionary *infoDictionary = [dictionary objectForKey:@"data"];
                    CGSize constraintSize = CGSizeMake(CGRectGetWidth(self.view.frame)-95-8, MAXFLOAT);
                    UIFont *font = [UIFont systemFontOfSize:13.0f];
                    NSString *strBorrowName = [infoDictionary objectForKey:@"borrowName"];
                    _firstRowHeight = [BIDCommonMethods getHeightWithString:strBorrowName font:font constraintSize:constraintSize];
                    _debtStatus = [infoDictionary objectForKey:@"debtStatus"];
                    if([_debtStatus isEqualToString:@"01"])
                    {
                        _btnType = BUTTON_PUBLISH;
                    }
                    else if([_debtStatus isEqualToString:@"02"])
                    {
                        _btnType = BUTTON_WITHDRAW;
                    }
                    else if([_debtStatus isEqualToString:@"04"])
                    {
                        _btnType = BUTTON_EDIT;
                    }
                    else
                    {
                        _btnType = BUTTON_NULL;
                    }
                    [_investDictionary setDictionary:infoDictionary];
                    [self.tableView reloadData];
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
    });
}

- (void)functionBtnHandler
{
    switch(_btnType)
    {
        case BUTTON_PUBLISH:
        {
            [self publishCreditRight];
        }
            break;
        case BUTTON_WITHDRAW:
        {
            [self withdrawCreditRight];
        }
            break;
        case BUTTON_EDIT:
        {
            [self editCreditRight];
        }
        case BUTTON_NULL:
        {}
            break;
    }
}
/**
 *发布债权
 */
- (void)publishCreditRight
{
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strPublishURL];
    NSString *strPost = [[NSString alloc] initWithFormat:@"jsonDataSet={\"investId\":\"%@\"}", investId];
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
                    [BIDCommonMethods showAlertView:[dictionary objectForKey:@"message"] buttonTitle:@"关闭" delegate:self tag:0];
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
    });
}
/**
 *撤销债权
 */
- (void)withdrawCreditRight
{
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strWithdrawURL];
    NSString *strPost = [[NSString alloc] initWithFormat:@"jsonDataSet={\"investId\":\"%@\"}", investId];
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
                    [BIDCommonMethods showAlertView:[dictionary objectForKey:@"message"] buttonTitle:@"关闭" delegate:self tag:0];
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
    });
}
/**
 *修改债权
 */
- (void)editCreditRight
{
    BIDTransferCreditRightViewController *vc = [[BIDTransferCreditRightViewController alloc] init];
    vc.investId = self.investId;
    vc.title = @"修改债权";
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==2)
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
    else if(alertView.tag==0)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _titleArr.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    NSUInteger row = indexPath.row;
    static NSString *identifier = @"identifier";
    if(!_bRegister)
    {
        UINib *nib1 = [UINib nibWithNibName:@"BIDDetailInfoCell" bundle:nil];
        [tableView registerNib:nib1 forCellReuseIdentifier:identifier];
    }

    BIDDetailInfoCell *detailInfoCell = (BIDDetailInfoCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if(row==0)
    {
        CGRect titleLabelFrame = detailInfoCell.titleLabel.frame;
        if(_firstRowHeight+10*2 > 44.0f)
        {
            titleLabelFrame.size.height = _firstRowHeight+10*2;
            detailInfoCell.titleLabel.frame = titleLabelFrame;
        }
        //
        CGRect contentLabelFrame = detailInfoCell.contentLabel.frame;
        contentLabelFrame.size.height = _firstRowHeight;
        detailInfoCell.contentLabel.frame = contentLabelFrame;
        detailInfoCell.contentLabel.numberOfLines = 0;
        detailInfoCell.contentLabel.center = CGPointMake(detailInfoCell.contentLabel.center.x, detailInfoCell.titleLabel.center.y);
    }
    detailInfoCell.titleLabel.text = _titleArr[row];
    if(row==_titleArr.count-1)
    {
        detailInfoCell.contentLabel.hidden = YES;
        detailInfoCell.functionBtn.hidden = NO;
        [detailInfoCell.functionBtn addTarget:self action:@selector(functionBtnHandler) forControlEvents:UIControlEventTouchUpInside];
        switch(_btnType)
        {
            case BUTTON_PUBLISH:
            {
                [BIDCommonMethods setImgForBtn:detailInfoCell.functionBtn imgForNormal:@"blueBtnBgNormal.png" imgForPress:@"blueBtnBgPress.png" inset:UIEdgeInsetsMake(10, 10, 11, 11)];
                [detailInfoCell.functionBtn setTitle:@"发   布" forState:UIControlStateNormal];
                detailInfoCell.functionBtn.enabled = YES;
            }
                break;
            case BUTTON_WITHDRAW:
            {
                [BIDCommonMethods setImgForBtn:detailInfoCell.functionBtn imgForNormal:@"redBtnBgNormal.png" imgForPress:@"redBtnBgPress.png" inset:UIEdgeInsetsMake(10, 10, 11, 11)];
                [detailInfoCell.functionBtn setTitle:@"撤   销" forState:UIControlStateNormal];
                detailInfoCell.functionBtn.enabled = YES;
            }
                break;
            case BUTTON_EDIT:
            {
                [BIDCommonMethods setImgForBtn:detailInfoCell.functionBtn imgForNormal:@"blueBtnBgNormal.png" imgForPress:@"blueBtnBgPress.png" inset:UIEdgeInsetsMake(10, 10, 11, 11)];
                [detailInfoCell.functionBtn setTitle:@"修   改" forState:UIControlStateNormal];
                detailInfoCell.functionBtn.enabled = YES;
            }
                break;
            case BUTTON_NULL:
            {
                [BIDCommonMethods setImgForBtn:detailInfoCell.functionBtn imgForNormal:@"grayBtnBgNormal.png" imgForPress:@"grayBtnBgPress.png" inset:UIEdgeInsetsMake(10, 10, 11, 11)];
                [detailInfoCell.functionBtn setTitle:@"撤   销" forState:UIControlStateNormal];
                detailInfoCell.functionBtn.enabled = NO;
            }
                break;
        }
    }
    else
    {
        detailInfoCell.contentLabel.hidden = NO;
        detailInfoCell.functionBtn.hidden = YES;
        NSString *strField = _fieldArr[row];
        detailInfoCell.contentLabel.text = [[NSString alloc] initWithFormat:@"%@", [_investDictionary objectForKey:strField]];
    }
    cell = detailInfoCell;
    [cell setBackgroundColor:[UIColor clearColor]];
    return cell;
}

@end

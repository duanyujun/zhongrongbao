//
//  BIDInvestInfoViewController.m
//  zhongrongbao
//
//  Created by mal on 14-10-15.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDInvestInfoViewController.h"
#import "BIDInvestInfoCell.h"
#import "BIDAppDelegate.h"
#import "BIDDataCommunication.h"
#import "BIDCommonMethods.h"
#import "BIDCustomSpinnerView.h"
#import "BIDRepaymentCell.h"
#import "BIDTransferCreditRightViewController.h"
#import "BIDWebPageJumpViewController.h"
#import "BIDLoginViewController.h"

/**
 *投资详情
 */
static NSString *strInvestInfoURL = @"Invest/queryInvestDetails.shtml";
/**
 *撤销投资
 */
static NSString *strWithdrawURL = @"UserPnr/TenderCancle.shtml";

@interface BIDInvestInfoViewController ()<UIAlertViewDelegate>
{
    BOOL _bRegister;
    //
    BIDCustomSpinnerView *_spinnerView;
    /**
     *投资信息
     */
    NSMutableDictionary *_investDictionary;
    /**
     *还款列表
     */
    NSMutableArray *_repaymentArr;
    /**
     *投资信息第一行的高度
     */
    CGFloat _firstRowHeight;
    /**
     *标题arr
     */
    NSArray *_titleArr;
    /**
     *字段arr
     */
    NSArray *_fieldArr;
    //
    NSString *_borrowStatus;
    NSString *_debtStatus;
    NSString *_investStatus;
    //
    BUTTON_TYPE _btnType;
}

@end

@implementation BIDInvestInfoViewController
@synthesize investId;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"投资信息";
    [self.tableView setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:240.0f/255.0f blue:241.0f/255.0f alpha:1.0f]];
    self.tableView.separatorColor = UITableViewCellSeparatorStyleNone;
    //
    _spinnerView = [[BIDCustomSpinnerView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    [_spinnerView initLayout];
    _spinnerView.content = @"";
    
    //返回按钮设置
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backBtnHandler)];
    //
    [self prepareForData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForData
{
    _btnType = BUTTON_NULL;
    _firstRowHeight = 0.0f;
    _investDictionary = [[NSMutableDictionary alloc] init];
    _repaymentArr = [[NSMutableArray alloc] init];
    _titleArr = @[@"标题", @"投标时间", @"计息时间", @"标的状态", @"投标状态", @"已还期数", @"投标金额"];
    _fieldArr = @[@"borrowName", @"investTime", @"examineTime", @"borrowStatusName", @"investStatusName", @"hasDeadlineRepayment", @"investAmt"];
    //
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strInvestInfoURL];
    NSString *strPost = [[NSString alloc] initWithFormat:@"jsonDataSet={\"id\":\"%@\"}", investId];
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
                    NSArray *repaymentArr = [dictionary objectForKey:@"dataList"];
                    CGSize constraintSize = CGSizeMake(CGRectGetWidth(self.view.frame)-70-8, MAXFLOAT);
                    UIFont *font = [UIFont systemFontOfSize:13.0f];
                    NSString *strBorrowName = [infoDictionary objectForKey:@"borrowName"];
                    _firstRowHeight = [BIDCommonMethods getHeightWithString:strBorrowName font:font constraintSize:constraintSize];
                    _borrowStatus = [infoDictionary objectForKey:@"borrowStatus"];
                    _debtStatus = [infoDictionary objectForKey:@"debtStatus"];
                    _investStatus = [infoDictionary objectForKey:@"investStatus"];
                    [_investDictionary setDictionary:infoDictionary];
                    [_repaymentArr setArray:repaymentArr];
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

/**
 *返回按钮
 */
- (void)backBtnHandler
{
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *转让债券或取消投资
 */
- (void)functionBtnHandler
{
    switch(_btnType)
    {
        case BUTTON_TRANSFER:
        {
            //转让债权
            BIDTransferCreditRightViewController *vc = [[BIDTransferCreditRightViewController alloc] init];
            vc.investId = self.investId;
            vc.title = @"转让债权";
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case BUTTON_WITHDRAW:
        {
            //撤销投资
            [self withdrawInvest];
        }
            break;
        case BUTTON_NULL:
        {}
            break;
    }
}
/**
 *撤销投资
 */
- (void)withdrawInvest
{
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strWithdrawURL];
    NSString *strPost = [[NSString alloc] initWithFormat:@"jsonDataSet={\"id\":\"%@\"}", investId];
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
                    BIDWebPageJumpViewController *vc = [[BIDWebPageJumpViewController alloc] initWithNibName:@"BIDWebPageJumpViewController" bundle:nil];
                    vc.desURL = [dictionary objectForKey:@"data"];
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
    });
}

#pragma mark -UIAlertViewDelegate
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
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if([_borrowStatus isEqualToString:@"02"] || [_borrowStatus isEqualToString:@"04"])
    {
        return 2;
    }
    else
    {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger rows = 0;
    if(section==0)
    {
        rows = _titleArr.count;
    }
    else if(section==1)
    {
        rows = _repaymentArr.count+1;
    }
    return rows;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.row;
    static NSString *identifier1 = @"identifier1";
    static NSString *identifier2 = @"identifier2";
    if(!_bRegister)
    {
        UINib *nib1 = [UINib nibWithNibName:@"BIDInvestInfoCell" bundle:nil];
        [tableView registerNib:nib1 forCellReuseIdentifier:identifier1];
        UINib *nib2 = [UINib nibWithNibName:@"BIDRepaymentCell" bundle:nil];
        [tableView registerNib:nib2 forCellReuseIdentifier:identifier2];
    }
    if(section==0)
    {
        BIDInvestInfoCell *investInfoCell = (BIDInvestInfoCell*)[tableView dequeueReusableCellWithIdentifier:identifier1];
        if(row==0)
        {
            CGRect titleLabelFrame = investInfoCell.titleLabel.frame;
            if(_firstRowHeight+10*2 > 44.0f)
            {
                titleLabelFrame.size.height = _firstRowHeight+10*2;
                investInfoCell.titleLabel.frame = titleLabelFrame;
                CGRect lineLabelFrame = investInfoCell.lineLabel.frame;
                lineLabelFrame.origin.y = titleLabelFrame.size.height-1;
                investInfoCell.lineLabel.frame = lineLabelFrame;
            }
            //
            CGRect contentLabelFrame = investInfoCell.contentLabel.frame;
            contentLabelFrame.size.height = _firstRowHeight;
            investInfoCell.contentLabel.frame = contentLabelFrame;
            investInfoCell.contentLabel.numberOfLines = 0;
            investInfoCell.contentLabel.center = CGPointMake(investInfoCell.contentLabel.center.x, investInfoCell.titleLabel.center.y);
        }
        investInfoCell.titleLabel.text = _titleArr[row];
        NSString *strField = _fieldArr[row];
        NSString *strContent = [[NSString alloc] initWithFormat:@"%@", [_investDictionary objectForKey:strField]];
        if(row==_titleArr.count-1)
        {
            strContent = [[NSString alloc] initWithFormat:@"%@元", strContent];
        }
        investInfoCell.contentLabel.text = strContent;
        cell = investInfoCell;
        [cell setBackgroundColor:[UIColor clearColor]];
    }
    else if(section==1)
    {
        BIDRepaymentCell *repaymentCell = (BIDRepaymentCell*)[tableView dequeueReusableCellWithIdentifier:identifier2];
        if(row==0)
        {
            [repaymentCell setBackgroundColor:[UIColor colorWithRed:227.0f/255.0f green:231.0f/255.0f blue:232.0f/255.0f alpha:1.0f]];
            repaymentCell.repayDateLabel.text = @"规定还款时间";
            repaymentCell.repayStatusNameLabel.text = @"还款状态";
            repaymentCell.repayTypeNameLabel.text = @"还款类型";
            repaymentCell.repayAmtLabel.text = @"还款金额";
        }
        else
        {
            //for(NSDictionary *dictionary in _repaymentArr)
            NSDictionary *dictionary = _repaymentArr[row-1];
            {
                repaymentCell.repayDateLabel.text = [dictionary objectForKey:@"repayDate"];
                repaymentCell.repayStatusNameLabel.text = [dictionary objectForKey:@"repayStatusName"];
                repaymentCell.repayTypeNameLabel.text = [dictionary objectForKey:@"repayTypeName"];
                repaymentCell.repayAmtLabel.text = [[NSString alloc] initWithFormat:@"%@", [dictionary objectForKey:@"repayAmt"]];
            }
            [repaymentCell setBackgroundColor:[UIColor clearColor]];
        }
        cell = repaymentCell;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rowHeight = 0.0f;
    NSUInteger row = indexPath.row;
    NSUInteger section = indexPath.section;
    if(section == 0)
    {
        if(row==0)
        {
            rowHeight = _firstRowHeight+10*2<44.0f?44.0f:_firstRowHeight+10*2;
        }
        else
        {
            rowHeight = 44.0f;
        }
    }
    else if(section == 1)
    {
        rowHeight = 30.0f;
    }
    return rowHeight;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 44.0f)];
    [label setTextAlignment:NSTextAlignmentLeft];
    [label setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:240.0f/255.0f blue:241.0f/255.0f alpha:1.0f]];
    [label setTextColor:[UIColor darkGrayColor]];
    [label setFont:[UIFont systemFontOfSize:18.0f]];
    NSString *strTitle = @"还款详情";
    [label setText:[[NSString alloc] initWithFormat:@"   %@", strTitle]];
    return label;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    CGFloat viewHeight = 100.0f;
    CGSize btnSize = CGSizeMake(160.0f, 40.0f);
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), viewHeight)];
    [footerView setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:240.0f/255.0f blue:241.0f/255.0f alpha:1.0f]];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width-btnSize.width)/2, (viewHeight-btnSize.height)/2, btnSize.width, btnSize.height)];
    [btn addTarget:self action:@selector(functionBtnHandler) forControlEvents:UIControlEventTouchUpInside];
    [BIDCommonMethods setImgForBtn:btn imgForNormal:@"blueBtnBgNormal.png" imgForPress:@"blueBtnBgPress.png" inset:UIEdgeInsetsMake(10, 10, 11, 11)];
    NSString *strBtnTitle = @"撤销投资";
    //2015-4-21 取消"撤销投资"功能
//    if([_borrowStatus isEqualToString:@"02"] && [_investStatus isEqualToString:@"01"])
//    {
//        btn.enabled = YES;
//        strBtnTitle = @"撤销投资";
//        _btnType = BUTTON_WITHDRAW;
//    }
    //2015-4-21
    if([_borrowStatus isEqualToString:@"04"])
    {
        _btnType = BUTTON_TRANSFER;
        strBtnTitle = @"转让债权";
        if(_debtStatus.length==0 && [_investStatus isEqualToString:@"02"])
        {
            btn.enabled = YES;
        }
        else
        {
            [BIDCommonMethods setImgForBtn:btn imgForNormal:@"grayBtnBgNormal.png" imgForPress:@"grayBtnBgPress.png" inset:UIEdgeInsetsMake(10, 10, 11, 11)];
            btn.enabled = NO;
        }
    }
    else
    {
        [BIDCommonMethods setImgForBtn:btn imgForNormal:@"grayBtnBgNormal.png" imgForPress:@"grayBtnBgPress.png" inset:UIEdgeInsetsMake(10, 10, 11, 11)];
        btn.enabled = NO;
    }
    [btn setTitle:strBtnTitle forState:UIControlStateNormal];
    [btn.titleLabel setTextColor:[UIColor whiteColor]];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:13.0f]];
    [footerView addSubview:btn];
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat headerHeight = 0.0f;
    if(section==0)
    {
        headerHeight = 0.0f;
    }
    else if(section == 1)
    {
        headerHeight = 44.0f;
    }
    return headerHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat footerHeight = 0.0f;
    if(section == 0)
    {
        footerHeight = 100.0f;
    }
    else if(section == 1)
    {
        footerHeight = 0.0f;
    }
    return footerHeight;
}

@end

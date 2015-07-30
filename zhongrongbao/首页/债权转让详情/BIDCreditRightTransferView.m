//
//  BIDCreditRightTransferView.m
//  zhongrongbao
//
//  Created by mal on 14-10-15.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDCreditRightTransferView.h"
#import "BIDDataCommunication.h"
#import "BIDCommonMethods.h"
#import "BIDCustomSpinnerView.h"
#import "BIDAppDelegate.h"
#import "BIDCreditRightTransferCell.h"
#import "BIDWebPageJumpViewController.h"
#import "BIDLoginAndRegisterViewController.h"
#import "BIDOpenHFTXViewController.h"
#import "BIDLoginViewController.h"

const CGFloat kTransferCellFontSize = 13.0f;
/**
 *债权转让详情
 */
static NSString *strCreditRightInfoURL = @"transferDetails/queryTransDetails.shtml";
/**
 *转让债权
 */
static NSString *strTransferURL = @"UserPnr/CreditAssign.shtml";

@interface BIDCreditRightTransferView ()<UIAlertViewDelegate>
{
    /**
     *标题arr
     */
    NSArray *_titleArr;
    /**
     *字段arr
     */
    NSArray *_fieldArr;
    /**
     *债权转让详情
     */
    NSMutableDictionary *_infoDictionary;
    //
    BIDCustomSpinnerView *_spinnerView;
    /**
     *企业信息label的高度
     */
    CGFloat _enterpriseInfoLabelHeight;
    /**
     *抵质押信息label的高度
     */
    CGFloat _guaranteeInfoLabelHeight;
    //
    BOOL _bRegister;
}

@end

@implementation BIDCreditRightTransferView
@synthesize creditRightTransferId;

- (void)viewDidLoad {
    [super viewDidLoad];
    //
    self.title = @"债权转让详情";
    //返回按钮设置
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backBtnHandler)];
    //
    _spinnerView = [[BIDCustomSpinnerView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    [_spinnerView initLayout];
    _spinnerView.content = @"";
    //
    self.tableView.allowsSelection = NO;
    [self.tableView setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:240.0f/255.0f blue:241.0f/255.0f alpha:1.0f]];
    [self prepareData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backBtnHandler
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)prepareData
{
    _enterpriseInfoLabelHeight = 0.0f;
    _guaranteeInfoLabelHeight = 0.0f;
    _infoDictionary = [[NSMutableDictionary alloc] init];
    _titleArr = @[@"借款日期", @"满标日期", @"融资金额", @"年化收益", @"融资期限", @"转让债权", @"转让价格", @"预期收益", @"结束日期", @"借款描述", @"债权描述"];
    _fieldArr = @[@"publishTime", @"examineTime", @"debtAmt", @"annualRate", @"deadline", @"debtAmt", @"dealAmt", @"profitAmt", @"closingDate", @"borrowSummary", @"debtDetail"];
    //加载详情
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strCreditRightInfoURL];
    NSString *strPost = [[NSString alloc] initWithFormat:@"jsonDataSet={\"id\":\"%@\"}", creditRightTransferId];
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
                    [_infoDictionary setDictionary:[dictionary objectForKey:@"data"]];
                    NSString *strEnterpriseInfo = [_infoDictionary objectForKey:@"borrowSummary"];
                    NSString *strGuaranteeInfo = [_infoDictionary objectForKey:@"debtDetail"];
                    CGSize constraintSize = CGSizeMake(CGRectGetWidth(self.view.frame)-14, MAXFLOAT);
                    _enterpriseInfoLabelHeight = [BIDCommonMethods getHeightWithString:strEnterpriseInfo font:[UIFont systemFontOfSize:kTransferCellFontSize] constraintSize:constraintSize];
                    _guaranteeInfoLabelHeight = [BIDCommonMethods getHeightWithString:strGuaranteeInfo font:[UIFont systemFontOfSize:kTransferCellFontSize] constraintSize:constraintSize];
                    self.tableView.tableHeaderView = [self prepareForTenderHeaderView];
                    self.tableView.tableFooterView = [self prepareForTenderFooterView];
                    [self.tableView reloadData];
                }
                else
                {
                    [BIDCommonMethods showAlertView:[dictionary objectForKey:@"message"] buttonTitle:@"关闭" delegate:nil tag:0];
                }
            }
            else
            {
                [BIDCommonMethods showAlertView:@"请求失败" buttonTitle:@"关闭" delegate:nil tag:0];
            }
        });
    });
}
/**
 *设置标头视图
 */
- (UIView*)prepareForTenderHeaderView
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    UIView *headerView = [[UIView alloc] init];
    UIFont *nameLabelFont = [UIFont systemFontOfSize:20.0f];
    CGFloat topSpacing = 20.0f;
    CGFloat leftSpacing = 10.0f;
    CGFloat rightSpacing = 10.0f;
    //CGFloat itemSpacing = 5.0f;
    //CGFloat lineSpacing = 15.0f;
    CGFloat bottomSpacing = 10.0f;
    //
    CGSize nameLabelSize = CGSizeMake(screenSize.width-leftSpacing-rightSpacing, 0);
    NSDictionary *attributeDictionary = @{NSFontAttributeName:nameLabelFont};
    NSString *tenderName = [_infoDictionary objectForKey:@"borrowName"];
    CGSize tenderNameSize = [tenderName boundingRectWithSize:CGSizeMake(nameLabelSize.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributeDictionary context:nil].size;
    CGFloat tenderNameHeight = ceil(tenderNameSize.height);
    nameLabelSize.height = tenderNameHeight;
    //创建标题名字label
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftSpacing, topSpacing, nameLabelSize.width, nameLabelSize.height)];
    nameLabel.numberOfLines = 0;
    [nameLabel setTextColor:[UIColor darkGrayColor]];
    nameLabel.text = tenderName;
    [nameLabel setFont:nameLabelFont];
    [headerView addSubview:nameLabel];
    //
    CGFloat headerViewHeight = CGRectGetMaxY(nameLabel.frame) + bottomSpacing;
    CGRect headerViewFrame = CGRectMake(0, 0, screenSize.width, headerViewHeight);
    headerView.frame = headerViewFrame;
    [headerView setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:240.0f/255.0f blue:241.0f/255.0f alpha:1.0f]];
    return headerView;
}
/**
 *设置标底视图
 */
- (UIView*)prepareForTenderFooterView
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 65.0f)];
    [footerView setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:240.0f/255.0f blue:241.0f/255.0f alpha:1.0f]];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(14, 10, CGRectGetWidth(self.view.frame)-14*2, 45.0f)];
    [footerView addSubview:btn];
    [btn addTarget:self action:@selector(buyCreditRightBtnHandler) forControlEvents:UIControlEventTouchUpInside];
    [btn.titleLabel setTextColor:[UIColor whiteColor]];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];

    NSString *strStatus = [_infoDictionary objectForKey:@"debtStatus"];
    if([strStatus isEqualToString:@"02"])
    {
        //转让中
        [BIDCommonMethods setImgForBtn:btn imgForNormal:@"redBtnBgNormal.png" imgForPress:@"redBtnBgPress.png" inset:UIEdgeInsetsMake(10, 10, 11, 11)];
        btn.enabled = YES;
        [btn setTitle:@"购买债权" forState:UIControlStateNormal];
    }
    else
    {
        //转让完成
        [BIDCommonMethods setImgForBtn:btn imgForNormal:@"grayBtnBgNormal.png" imgForPress:@"grayBtnBgPress.png" inset:UIEdgeInsetsMake(10, 10, 11, 11)];
        btn.enabled = NO;
        [btn setTitle:@"结束" forState:UIControlStateNormal];
    }
    return footerView;
}
/**
 *购买债权
 */
- (void)buyCreditRightBtnHandler
{
    if(![BIDAppDelegate isHaveLogin])
    {
        //未登录,则提示需要登录才能投标，是否登录
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"登录后才可以继续操作，是否登录" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
        alertView.tag = 0;
        [alertView show];
    }
    else
    {
        NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strTransferURL];
        NSString *strPost = [[NSString alloc] initWithFormat:@"jsonDataSet={\"id\":\"%@\"}", creditRightTransferId];
        [_spinnerView showTheView];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
            int state = [BIDCommonMethods isHaveRegisterHFTX];
            if(state==0)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_spinnerView dismissTheView];
                    [BIDCommonMethods showAlertView:@"请求失败" buttonTitle:@"关闭" delegate:nil tag:0];
                });
            }
            else if(state==1)
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
                            NSString *desURL = [dictionary objectForKey:@"data"];
                            BIDWebPageJumpViewController *vc = [[BIDWebPageJumpViewController alloc] initWithNibName:@"BIDWebPageJumpViewController" bundle:nil];
                            vc.desURL = desURL;
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
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)
    {
        if(alertView.tag==0)
        {
            //登录注册
            BIDLoginAndRegisterViewController *vc = [[BIDLoginAndRegisterViewController alloc] initWithNibName:@"BIDLoginAndRegisterViewController" bundle:nil];
            [self.navigationController setViewControllers:@[vc] animated:YES];
        }
        else
        {
            //开通汇付天下
            BIDOpenHFTXViewController *vc = [[BIDOpenHFTXViewController alloc] initWithNibName:@"BIDOpenHFTXViewController" bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else
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
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _titleArr.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    NSUInteger row = indexPath.row;
    static NSString *identifier1 = @"identifier1";
    static NSString *identifier2 = @"identifier2";
    if(!_bRegister)
    {
        _bRegister = YES;
        UINib *nib = [UINib nibWithNibName:@"BIDCreditRightTransferCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:identifier2];
    }
    if(row<_titleArr.count-2)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
        if(!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1];
        }
        NSString *strAttach = @"";
        switch(row)
        {
            case 2:
            case 5:
            case 6:
            case 7:
            {
                strAttach = @"元";
            }
                break;
            case 3:
            {
                strAttach = @"%";
            }
                break;
            case 4:
            {
                strAttach = @"个月";
            }
                break;
        }
        NSString *strTitle = _titleArr[row];
        NSString *strField = _fieldArr[row];
        NSString *strContent = [[NSString alloc] initWithFormat:@"%@", [_infoDictionary objectForKey:strField]];
        cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.textLabel.text = [[NSString alloc] initWithFormat:@"%@: %@%@", strTitle, strContent, strAttach];
    }
    else
    {
        BIDCreditRightTransferCell *transferCell = (BIDCreditRightTransferCell*)[tableView dequeueReusableCellWithIdentifier:identifier2];
        transferCell.titleLabel.text = _titleArr[row];
        NSString *strContent = [_infoDictionary objectForKey:_fieldArr[row]];
        transferCell.contentLabel.text = strContent;
        CGRect frame = transferCell.contentLabel.frame;
        CGFloat labelHeight = 0.0f;
        if(row==_titleArr.count-2) labelHeight = _enterpriseInfoLabelHeight;
        else if(row==_titleArr.count-1) labelHeight = _guaranteeInfoLabelHeight;
        frame.size.height = labelHeight;
        transferCell.contentLabel.numberOfLines = 0;
        transferCell.contentLabel.frame = frame;
        cell = transferCell;
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = indexPath.row;
    CGFloat cellHeight = 0.0f;
    if(row<_titleArr.count-2)
    {
        cellHeight = 44.0f;
    }
    else if(row==_titleArr.count-2)
    {
        cellHeight = 15 + _enterpriseInfoLabelHeight + 3*8;
    }
    else if(row==_titleArr.count-1)
    {
        cellHeight = 15 + _guaranteeInfoLabelHeight + 3*8;
    }
    return cellHeight<44.0f?44.0f:cellHeight;
}

@end

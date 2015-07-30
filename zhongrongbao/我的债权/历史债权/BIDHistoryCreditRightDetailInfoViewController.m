//
//  BIDHistoryCreditRightDetailInfoViewController.m
//  zhongrongbao
//
//  Created by mal on 14-10-16.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDHistoryCreditRightDetailInfoViewController.h"
#import "BIDDetailInfoCell.h"
#import "BIDDataCommunication.h"
#import "BIDCommonMethods.h"
#import "BIDAppDelegate.h"
#import "BIDCustomSpinnerView.h"
#import "BIDLoginViewController.h"

/**
 *债权详情
 */
static NSString *strDetailInfoURL = @"debtHistory/queryDebtHisDetails.shtml";

@interface BIDHistoryCreditRightDetailInfoViewController ()<UIAlertViewDelegate>
{
    //
    NSArray *_titleArr;
    //
    NSArray *_fieldArr;
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

@implementation BIDHistoryCreditRightDetailInfoViewController
@synthesize investId;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"债权购买记录";
    [self.tableView setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:240.0f/255.0f blue:241.0f/255.0f alpha:1.0f]];
    self.tableView.tableFooterView = [[UIView alloc] init];
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
    _firstRowHeight = 0.0f;
    _investDictionary = [[NSMutableDictionary alloc] init];
    _titleArr = @[@"标题", @"购买金额", @"手续费", @"时间", @"状态"];
    _fieldArr = @[@"borrowName", @"investAmt", @"fee", @"investTime", @"investStatusName"];
    //
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strDetailInfoURL];
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
                    CGSize constraintSize = CGSizeMake(CGRectGetWidth(self.view.frame)-95-8, MAXFLOAT);
                    UIFont *font = [UIFont systemFontOfSize:13.0f];
                    NSString *strBorrowName = [infoDictionary objectForKey:@"borrowName"];
                    _firstRowHeight = [BIDCommonMethods getHeightWithString:strBorrowName font:font constraintSize:constraintSize];
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
    NSString *strField = _fieldArr[row];
    detailInfoCell.contentLabel.text = [[NSString alloc] initWithFormat:@"%@", [_investDictionary objectForKey:strField]];
    cell = detailInfoCell;
    [cell setBackgroundColor:[UIColor clearColor]];
    return cell;
}

@end

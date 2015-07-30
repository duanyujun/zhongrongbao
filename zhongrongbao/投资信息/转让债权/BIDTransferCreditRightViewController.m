//
//  BIDTransferCreditRightViewController.m
//  zhongrongbao
//
//  Created by mal on 14-10-15.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDTransferCreditRightViewController.h"
#import "BIDDataCommunication.h"
#import "BIDCommonMethods.h"
#import "BIDCustomSpinnerView.h"
#import "BIDAppDelegate.h"
#import "BIDCellWithTextField.h"
#import "BIDCellWithTextView.h"
#import "BIDWebPageJumpViewController.h"
#import "BIDLoginViewController.h"

/**
 *债权信息(8.3.6.2)
 */
static NSString *strCreditRightInfoURL = @"Invest/queryTransferMes.shtml";
/**
 *添加债权转让(8.3.6.3)
 */
static NSString *strAddCreditRightTransferURL = @"DebtTransfer/add.shtml";

@interface BIDTransferCreditRightViewController ()<UIAlertViewDelegate, UITextViewDelegate, UITextFieldDelegate>
{
    /**
     *标题arr
     */
    NSArray *_titleArr;
    /**
     *字段arr
     */
    NSArray *_fieldArr;
    //
    BIDCustomSpinnerView *_spinnerView;
    /**
     *债权信息
     */
    NSMutableDictionary *_creditRightDictionary;
    //
    BOOL _bRegister;
    //
    UIToolbar *_keyboardToolBar;
    //转让价格
    NSString *_transferPrice;
    //转让期限
    NSString *_transferDeadLine;
    //转让描述
    NSString *_transferDescription;
}

@end

@implementation BIDTransferCreditRightViewController
@synthesize investId;

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.title = @"转让债权";
    //
    _spinnerView = [[BIDCustomSpinnerView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    [_spinnerView initLayout];
    _spinnerView.content = @"";
    //
    CGSize toolBarSize = CGSizeMake(320, 30);
    CGRect toolBarFrame = CGRectMake(0, 0, toolBarSize.width, toolBarSize.height);
    _keyboardToolBar = [[UIToolbar alloc] initWithFrame:toolBarFrame];
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"关闭键盘" style:UIBarButtonItemStyleBordered target:self action:@selector(closeKeyboardHandler)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [_keyboardToolBar setItems:[[NSArray alloc] initWithObjects:item2, item1, nil]];
    _keyboardToolBar.barStyle = UIBarStyleBlack;
    _keyboardToolBar.translucent = YES;
    //返回按钮设置
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backBtnHandler)];
    //
    [self.tableView setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:240.0f/255.0f blue:241.0f/255.0f alpha:1.0f]];
    self.tableView.tableFooterView = [self prepareForFooterView];
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

- (UIView *)prepareForFooterView
{
    CGFloat footerViewHeight = 60.0f;
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), footerViewHeight)];
    [footerView setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:240.0f/255.0f blue:241.0f/255.0f alpha:1.0f]];
    CGSize btnSize = CGSizeMake(160.0f, 40.0f);
    UIButton *saveBtn = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width-btnSize.width)/2, (footerViewHeight-btnSize.height)/2, btnSize.width, btnSize.height)];
    [saveBtn setTitle:@"保  存" forState:UIControlStateNormal];
    [saveBtn.titleLabel setTextColor:[UIColor whiteColor]];
    [saveBtn.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [BIDCommonMethods setImgForBtn:saveBtn imgForNormal:@"blueBtnBgNormal.png" imgForPress:@"blueBtnBgPress.png" inset:UIEdgeInsetsMake(10, 10, 11, 11)];
    [saveBtn addTarget:self action:@selector(saveBtnHandler) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:saveBtn];
    return footerView;
}

//保存债权
- (void)saveBtnHandler
{
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strAddCreditRightTransferURL];
    //投资id
    NSString *strInvestId = investId;
    //投资金额
    NSString *strInvestAmt = [[NSString alloc] initWithFormat:@"%@", [_creditRightDictionary objectForKey:@"investAmt"]];
    //预期收益总额
    NSString *strRepayAmt = [[NSString alloc] initWithFormat:@"%@", [_creditRightDictionary objectForKey:@"repayAmt"]];
    //转让价格
    NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:_titleArr.count-3 inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath1];
    UITextField *tf = (UITextField*)[cell viewWithTag:99];
    NSString *strDealAmt = tf.text;
    //标的期数
    NSString *strDeadline = [[NSString alloc] initWithFormat:@"%@", [_creditRightDictionary objectForKey:@"deadline"]];
    //转让期限
    NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:_titleArr.count-2 inSection:0];
    cell = [self.tableView cellForRowAtIndexPath:indexPath2];
    tf = (UITextField*)[cell viewWithTag:100];
    NSString *strClosing = tf.text;
    //手续费
    NSString *strFee = [[NSString alloc] initWithFormat:@"%@", [_creditRightDictionary objectForKey:@"fee"]];
    //借款id
    NSString *strBid = [_creditRightDictionary objectForKey:@"bid"];
    //转让介绍
    NSIndexPath *indexPath3 = [NSIndexPath indexPathForRow:_titleArr.count-1 inSection:0];
    cell = [self.tableView cellForRowAtIndexPath:indexPath3];
    UITextView *tv = (UITextView*)[cell viewWithTag:101];
    NSString *strDebtDetail = tv.text;
    //满标时间
    NSString *strExamineTime = [_creditRightDictionary objectForKey:@"examineTime"];
    //
    NSString *strPost = [[NSString alloc] initWithFormat:@"jsonDataSet={\"id\":\"%@\", \"investAmt\":\"%@\", \"repayAmt\":\"%@\", \"dealAmt\":\"%@\", \"deadline\":\"%@\", \"closing\":\"%@\", \"fee\":\"%@\", \"bid\":\"%@\", \"debtDetail\":\"%@\", \"examineTime\":\"%@\"}", strInvestId, strInvestAmt, strRepayAmt, strDealAmt, strDeadline, strClosing, strFee, strBid, strDebtDetail, strExamineTime];
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

//关闭键盘
- (void)closeKeyboardHandler
{
    NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:_titleArr.count-3 inSection:0];
    NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:_titleArr.count-2 inSection:0];
    NSIndexPath *indexPath3 = [NSIndexPath indexPathForRow:_titleArr.count-1 inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath1];
    UITextField *tf = (UITextField*)[cell viewWithTag:99];
    [tf resignFirstResponder];
    cell = [self.tableView cellForRowAtIndexPath:indexPath2];
    tf = (UITextField*)[cell viewWithTag:100];
    [tf resignFirstResponder];
    cell = [self.tableView cellForRowAtIndexPath:indexPath3];
    UITextView *tv = (UITextView*)[cell viewWithTag:101];
    [tv resignFirstResponder];
}

- (void)prepareForData
{
    _transferPrice = @"";
    _transferDeadLine = @"";
    _transferDescription = @"";
    
    _creditRightDictionary = [[NSMutableDictionary alloc] init];
    _titleArr = @[@"借款日期", @"融资金额", @"年化收益", @"融资期限", @"预期收益总额", @"投标金额", @"转让手续费", @"可转让金额", @"转让价格", @"转让期限", @"转让介绍"];
    _fieldArr = @[@"examineTime", @"borrowAmt", @"annualRate", @"deadline", @"repayAmt", @"investAmt", @"fee", @"transferAmt", @"dealAmt", @"validDay", @"debtDetail"];
    //
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strCreditRightInfoURL];
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
                    [_creditRightDictionary setDictionary:infoDictionary];
                    _transferPrice = [[NSString alloc] initWithFormat:@"%@", [_creditRightDictionary objectForKey:@"dealAmt"]];
                    _transferDeadLine = [[NSString alloc] initWithFormat:@"%@", [_creditRightDictionary objectForKey:@"validDay"]];
                    _transferDescription = [[NSString alloc] initWithFormat:@"%@", [_creditRightDictionary objectForKey:@"debtDetail"]];
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
    else if(alertView.tag==0)
    {
        //修改债权成功
        //[self.navigationController popViewControllerAnimated:YES];
        NSArray *arr = self.navigationController.viewControllers;
        NSMutableArray *vcArr = [[NSMutableArray alloc] initWithArray:arr];
        [vcArr removeObjectsInRange:NSMakeRange(vcArr.count-2, 2)];
        [self.navigationController setViewControllers:vcArr animated:YES];
        NSNumber *value = [NSNumber numberWithInt:3];
        [[NSNotificationCenter defaultCenter] postNotificationName:VIEW_CHANGE_EVENT object:self userInfo:@{@"index":value}];
    }
}

#pragma mark - UITextViewDelegate UITextFieldDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    _transferDescription = textView.text;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField.tag == 99)
    {
        _transferPrice = textField.text;
    }
    else if(textField.tag == 100)
    {
        _transferDeadLine = textField.text;
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
    static NSString *identifier = @"identifier";
    static NSString *identifierWithTextField = @"identifierWithTextField";
    static NSString *identifierWithTextView = @"identifierWithTextView";
    NSUInteger row = indexPath.row;
    if(!_bRegister)
    {
        _bRegister = YES;
        UINib *nib1 = [UINib nibWithNibName:@"BIDCellWithTextField" bundle:nil];
        [tableView registerNib:nib1 forCellReuseIdentifier:identifierWithTextField];
        UINib *nib2 = [UINib nibWithNibName:@"BIDCellWithTextView" bundle:nil];
        [tableView registerNib:nib2 forCellReuseIdentifier:identifierWithTextView];
    }
    if(row < _titleArr.count-3)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if(!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        NSString *strTitle = _titleArr[row];
        NSString *strField = _fieldArr[row];
        NSString *strContent = [[NSString alloc] initWithFormat:@"%@", [_creditRightDictionary objectForKey:strField]];
        NSString *strAttach = @"";
        switch(row)
        {
            case 1:
            case 4:
            case 5:
            case 6:
            case 7:
            {
                strAttach = @"元";
            }
                break;
            case 2:
            {
                strAttach = @"%";
            }
                break;
            case 3:
            {
                strAttach = @"个月";
            }
                break;
        }
        cell.textLabel.text = [[NSString alloc] initWithFormat:@"%@: %@%@", strTitle, strContent, strAttach];
        cell.textLabel.textColor = [UIColor darkGrayColor];
    }
    else if(row < _titleArr.count-1)
    {
        BIDCellWithTextField *cellWithTF = (BIDCellWithTextField*)[tableView dequeueReusableCellWithIdentifier:identifierWithTextField];
        if(row == _titleArr.count-3)
        {
            cellWithTF.titleLabel.text = @"转让价格";
            cellWithTF.unitsLabel.text = @"元";
            cellWithTF.contentTF.tag = 99;
            cellWithTF.contentTF.text = _transferPrice;
        }
        else if(row == _titleArr.count-2)
        {
            cellWithTF.titleLabel.text = @"转让期限";
            cellWithTF.unitsLabel.text = @"天";
            cellWithTF.contentTF.tag = 100;
            cellWithTF.contentTF.text = _transferDeadLine;
        }
        cellWithTF.contentTF.delegate = self;
        cellWithTF.contentTF.layer.borderWidth = 1;
        cellWithTF.contentTF.layer.borderColor = [UIColor colorWithRed:230.0f/255.0f green:231.0f/255.0f blue:232.0f/255.0f alpha:1.0f].CGColor;
        cellWithTF.contentTF.inputAccessoryView = _keyboardToolBar;
        //NSString *strField = _fieldArr[row];
        //cellWithTF.contentTF.text = [[NSString alloc] initWithFormat:@"%@", [_creditRightDictionary objectForKey:strField]];
        cell = cellWithTF;
    }
    else if(row < _titleArr.count)
    {
        BIDCellWithTextView *cellWithTextView = (BIDCellWithTextView*)[tableView dequeueReusableCellWithIdentifier:identifierWithTextView];
        cellWithTextView.contentTextView.delegate = self;
        cellWithTextView.contentTextView.inputAccessoryView = _keyboardToolBar;
        cellWithTextView.contentTextView.layer.borderWidth = 1;
        cellWithTextView.contentTextView.layer.borderColor = [UIColor colorWithRed:230.0f/255.0f green:231.0f/255.0f blue:232.0f/255.0f alpha:1.0f].CGColor;
        //NSString *strField = _fieldArr[row];
        //cellWithTextView.contentTextView.text = [[NSString alloc] initWithFormat:@"%@", [_creditRightDictionary objectForKey:strField]];
        cellWithTextView.contentTextView.text = _transferDescription;
        cell = cellWithTextView;
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rowHeight = 44.0f;
    NSUInteger row = indexPath.row;
    if(row == _titleArr.count-3 || row == _titleArr.count-2)
    {
        rowHeight = 60.0f;
    }
    else if(row == _titleArr.count-1)
    {
        rowHeight = 141.0f;
    }
    return rowHeight;
}

@end

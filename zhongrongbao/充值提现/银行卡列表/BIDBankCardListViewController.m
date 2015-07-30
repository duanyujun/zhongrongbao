//
//  BIDBankCardListViewController.m
//  zhongrongbao
//
//  Created by mal on 15/6/28.
//  Copyright (c) 2015年 cnsoft. All rights reserved.
//

#import "BIDBankCardListViewController.h"
#import "BIDWebPageJumpViewController.h"
#import "BIDLoginViewController.h"
#import "BIDBankCardInfoView.h"
#import "BIDNode.h"
#import "BIDImgDownloader.h"

/**
 *查询银行卡列表
 */
static NSString *queryBankCardInfoURL = @"BankCard/queryBank.shtml";
/**
 *绑定银行卡
 */
static NSString *bindingBankCardURL = @"UserPnr/UserBindCard.shtml";
/**
 *删除银行卡
 */
static NSString *removeBindingBankCardURL = @"UserPnr/DelCard.shtml";

@interface BIDBankCardListViewController ()<UITableViewDataSource, UITableViewDelegate, BIDBankCardInfoViewDelegate, UIAlertViewDelegate>
{
    /**
     *银行卡列表
     */
    NSArray *_bankCardInfoArr;
    NSMutableArray *_nodeArr;
    NSMutableDictionary *_imgDownloadInProgress;
}
@end

@implementation BIDBankCardListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"已绑定银行卡";
    _bankCardInfoArr = [[NSArray alloc] init];
    _nodeArr = [[NSMutableArray alloc] init];
    //
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(addBankCard)];
    //
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self queryBankCardInfo];
}

/**
 *添加银行卡
 */
- (void)addBankCard
{
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
                    _bankCardInfoArr = [[NSArray alloc] initWithArray:[responseDictionary objectForKey:@"dataList"]];
                    [_nodeArr removeAllObjects];
                    for(NSDictionary *dictonary in _bankCardInfoArr)
                    {
                        BIDNode *node = [[BIDNode alloc] init];
                        node.img = nil;
                        node.imgDownloadURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], [dictonary objectForKey:@"logoImg"]];
                        [_nodeArr addObject:node];
                    }
                    [_tableView reloadData];
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

- (void)startIconDownload:(BIDNode *)node forIndexPath:(NSIndexPath *)indexPath
{
    BIDImgDownloader *imgDownloader = (_imgDownloadInProgress)[indexPath];
    if (imgDownloader == nil)
    {
        imgDownloader = [[BIDImgDownloader alloc] init];
        imgDownloader.node = node;
        [imgDownloader setCompletionHandler:^{
            
            UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
            BIDBankCardInfoView *infoView = (BIDBankCardInfoView*)[cell.contentView viewWithTag:100];
            infoView.bankImgView.image = node.img;
            // Display the newly loaded image
            // Remove the IconDownloader from the in progress list.
            // This will result in it being deallocated.
            [_imgDownloadInProgress removeObjectForKey:indexPath];
            
        }];
        (_imgDownloadInProgress)[indexPath] = imgDownloader;
        [imgDownloader startDownload];
    }
}
// -------------------------------------------------------------------------------
//	terminateAllDownloads
// -------------------------------------------------------------------------------
- (void)terminateAllDownloads
{
    // terminate all pending download connections
    NSArray *allDownloads = [_imgDownloadInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    [_imgDownloadInProgress removeAllObjects];
}

#pragma mark - BIDBankCardInfoViewDelegate
/**
 *解绑银行卡
 */
- (void)removeBinding:(int)row
{
    NSDictionary *dictionary = _bankCardInfoArr[row];
    NSString *strCardId = dictionary[@"cardId"];
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], removeBindingBankCardURL];
    NSString *strPost = [[NSString alloc] initWithFormat:@"jsonDataSet={\"cardId\":\"%@\"}", strCardId];
    [self.spinnerView showTheView];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        int rev = [BIDDataCommunication uploadDataByPostWithoutCookie:strURL postValue:strPost toDictionary:dictionary];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.spinnerView dismissTheView];
            if(rev==1)
            {
                if([[dictionary objectForKey:@"json"] isEqualToString:@"success"])
                {}
                else
                {
                    [BIDCommonMethods showAlertView:[dictionary objectForKey:@"message"] buttonTitle:@"关闭" delegate:nil tag:0];
                }
            }
            else if(rev==2)
            {
                [BIDCommonMethods showAlertView:[dictionary objectForKey:@"message"] buttonTitle:@"关闭" delegate:self tag:2];
            }
            else
            {
                [BIDCommonMethods showAlertView:@"请求失败" buttonTitle:@"关闭" delegate:nil tag:0];
            }
        });
    });
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _bankCardInfoArr?_bankCardInfoArr.count:0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    static NSString *identifier = @"identifier";
    NSUInteger row = indexPath.row;
    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    BIDBankCardInfoView *infoView = (BIDBankCardInfoView*)[cell.contentView viewWithTag:100];
    if(!infoView)
    {
        infoView = [[[NSBundle mainBundle] loadNibNamed:@"BIDBankCardInfoView" owner:self options:nil] lastObject];
        infoView.tag = 100;
        CGRect frame = infoView.frame;
        frame.origin.x = 10;
        frame.origin.y = 20;
        infoView.frame = frame;
        [cell.contentView addSubview:infoView];
    }
    infoView.delegate = self;
    infoView.row = row;
    BIDNode *node = _nodeArr[row];
    if(!node.img)
    {
        [self startIconDownload:node forIndexPath:indexPath];
    }
    else
    {
        infoView.bankImgView.image = node.img;
    }
    NSDictionary *dictionary = _bankCardInfoArr[row];
    NSString *strCardNumber = [dictionary objectForKey:@"cardId"];
    infoView.bankCardNumberLabel.text = [[NSString alloc] initWithFormat:@"**** **** **** %@", [strCardNumber substringFromIndex:strCardNumber.length-4]];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.contentView.autoresizesSubviews = NO;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110.0f;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==2)
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
@end

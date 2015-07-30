//
//  BIDRedPacketListViewController.m
//  zhongrongbao
//
//  Created by mal on 15/6/29.
//  Copyright (c) 2015年 cnsoft. All rights reserved.
//

#import "BIDRedPacketListViewController.h"
#import "BIDLoginViewController.h"
#import "BIDRedPacketView.h"
#import "BIDMyTableView.h"

/**
 *红包
 */
static NSString *redPacketListURL = @"ActivityUser/onePage.shtml";

@interface BIDRedPacketListViewController ()<UIAlertViewDelegate, BIDMyTableViewDelegate>
{
}

@end

@implementation BIDRedPacketListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"红包";
    [_tableView initView];
    _tableView.myDelegate = self;
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], redPacketListURL];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [BIDDataCommunication setCountPerPage:20];
    [_tableView firstLoadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    parent.navigationItem.titleView = nil;
    parent.navigationItem.title = @"我的红包";
    parent.navigationItem.rightBarButtonItem = nil;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _tableView.itemsArr.count;
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
    BIDRedPacketView *redPacketView = (BIDRedPacketView*)[cell.contentView viewWithTag:100];
    if(!redPacketView)
    {
        redPacketView = [[[NSBundle mainBundle] loadNibNamed:@"BIDRedPacketView" owner:self options:nil] lastObject];
        redPacketView.tag = 100;
        CGRect frame = redPacketView.frame;
        frame.origin.x = 10;
        frame.origin.y = 20;
        redPacketView.frame = frame;
        [cell.contentView addSubview:redPacketView];
    }
    NSDictionary *dictionary = _tableView.itemsArr[row];
    NSString *strType = [dictionary objectForKey:@"actType"];
    if([strType isEqualToString:@"01"])
    {
        redPacketView.imgView.image = [UIImage imageNamed:@"redpackage.png"];
    }
    else
    {
        redPacketView.imgView.image = [UIImage imageNamed:@"tiyanjin.png"];
    }
    redPacketView.nameLabel.text = [dictionary objectForKey:@"actName"];
    NSString *strLimit = [dictionary objectForKey:@"limitAmt"];
    redPacketView.limitLabel.text = [[NSString alloc] initWithFormat:@"投资满%@元可用", strLimit];
    NSString *strAmt = [dictionary objectForKey:@"amt"];
    redPacketView.amountLabel.text = [[NSString alloc] initWithFormat:@"%@元", strAmt];
    NSString *strLimitDate = [[NSString alloc] initWithFormat:@"有效期:%@", [dictionary objectForKey:@"useEndTime"]];
    redPacketView.limitDateLabel.text = strLimitDate;
    redPacketView.statusLabel.text = [dictionary objectForKey:@"inUse"];
    cell.contentView.autoresizesSubviews = NO;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 92.0f;
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

//
//  BIDMyCreditRightListViewController.m
//  zhongrongbao
//
//  Created by mal on 14-10-16.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDMyCreditRightListViewController.h"
#import "BIDInvestListCell.h"
#import "BIDCreditRightDetailInfoTableViewController.h"
#import "BIDHistoryCreditRightDetailInfoViewController.h"

/**
 *债权列表
 */
static NSString *strCreditRightListURL = @"DebtTransfer/onePageConditions.shtml";
/**
 *转让历史列表
 */
static NSString *strHistoryListURL = @"debtHistory/onePage.shtml";

@interface BIDMyCreditRightListViewController()<BIDMyTableViewDelegate>
{
    BIDInvestListCell *_temporaryCell;
    BOOL _bRegister;
}

@end

@implementation BIDMyCreditRightListViewController
@synthesize selectedIndex;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [BIDDataCommunication setCountPerPage:15];
    //[_bgView setBackgroundColor:[UIColor colorWithRed:255.0f/255.0f green:57.0f/255.0f blue:66.0f/255.0f alpha:1.0f]];
    [_creditRightListView setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:240.0f/255.0f blue:241.0f/255.0f alpha:1.0f]];
    [_creditRightListView initView];
    _creditRightListView.myDelegate = self;
    _creditRightListView.tableFooterView = [[UIView alloc] init];
    [_segmentedControl addTarget:self action:@selector(segmentedCtrlChangeHandler:) forControlEvents:UIControlEventValueChanged];
    //
    _temporaryCell = (BIDInvestListCell*)[[[NSBundle mainBundle] loadNibNamed:@"BIDInvestListCell" owner:self options:nil] lastObject];
    //
    [self prepareForData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    parent.navigationItem.titleView = nil;
    parent.navigationItem.rightBarButtonItem = nil;
    parent.navigationItem.title = @"我的债权";
}

- (void)prepareForData
{
    selectedIndex = 0;
    _creditRightListView.strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strCreditRightListURL];
    [_creditRightListView firstLoadData];
}

- (void)segmentedCtrlChangeHandler:(UISegmentedControl*)segmentedCtrl
{
    selectedIndex = segmentedCtrl.selectedSegmentIndex;
    if(segmentedCtrl.selectedSegmentIndex==0)
    {
        _creditRightListView.strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strCreditRightListURL];
        [_creditRightListView firstLoadData];
    }
    else if(segmentedCtrl.selectedSegmentIndex==1)
    {
        _creditRightListView.strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strHistoryListURL];
        [_creditRightListView firstLoadData];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ((BIDMyTableView*)tableView).itemsArr.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    NSUInteger row = indexPath.row;
    static NSString *identifier = @"identifier";
    if(!_bRegister)
    {
        _bRegister = YES;
        UINib *nib = [UINib nibWithNibName:@"BIDInvestListCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:identifier];
    }
    BIDInvestListCell *listCell = [tableView dequeueReusableCellWithIdentifier:identifier];
    //listCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSDictionary *dictionary = ((BIDMyTableView*)tableView).itemsArr[row];
    NSString *borrowName = [dictionary objectForKey:@"borrowName"];
    listCell.titleLabel.text = borrowName;
    listCell.flagLabel.text = @"金额";
    if(selectedIndex==0)
    {
        //截止日期
        listCell.dateLabel.text = dictionary[@"closingDate"];
        //债权总额
        listCell.amountLabel.text = dictionary[@"debtAmt"];
    }
    else
    {
        listCell.dateLabel.text = dictionary[@"investTime"];
        listCell.amountLabel.text = dictionary[@"investAmt"];
    }

    cell = listCell;
    [cell setBackgroundColor:[UIColor whiteColor]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSUInteger row = indexPath.row;
    NSDictionary *dictionary = ((BIDMyTableView*)tableView).itemsArr[row];
    NSString *strId;
    if(selectedIndex==0)
    {
        strId = [dictionary objectForKey:@"investId"];
        BIDCreditRightDetailInfoTableViewController *vc = [[BIDCreditRightDetailInfoTableViewController alloc] init];
        vc.investId = strId;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        strId = [dictionary objectForKey:@"debtId"];
        BIDHistoryCreditRightDetailInfoViewController *vc = [[BIDHistoryCreditRightDetailInfoViewController alloc] init];
        vc.investId = strId;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    CGFloat rowHeight = 0.0f;
    //    NSUInteger row = indexPath.row;
    //    NSNumber *heightValue = self.heightArr[row];
    //    CGFloat height = [heightValue floatValue] + 10*2;
    //    rowHeight = height<44.0f?44.0f:height;
    //    return rowHeight;
    CGFloat rowHeight = 0.0f;
    NSUInteger row = indexPath.row;
    NSDictionary *dic = ((BIDMyTableView*)tableView).itemsArr[row];
    _temporaryCell.titleLabel.preferredMaxLayoutWidth = CGRectGetWidth(tableView.frame)-16-14-74;
    _temporaryCell.titleLabel.text = dic[@"borrowName"];
    CGSize size = [_temporaryCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    rowHeight = size.height+1;
    return rowHeight;
}
@end


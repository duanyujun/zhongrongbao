//
//  BIDMyInvestListView.m
//  zhongrongbao
//
//  Created by mal on 14-10-15.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDMyInvestListView.h"
#import "BIDInvestListCell.h"
#import "BIDInvestInfoViewController.h"
/**
 *投资列表
 */
static NSString *strInvestListURL = @"Invest/onePage.shtml";

@interface BIDMyInvestListView ()<UIAlertViewDelegate>
{
    //
    BOOL _bRegister;
    BIDInvestListCell *_temporaryCell;
}

@end

@implementation BIDMyInvestListView

- (void)viewDidLoad {
    [super viewDidLoad];
    [BIDDataCommunication setCountPerPage:15];
    [self.tableView setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:240.0f/255.0f blue:241.0f/255.0f alpha:1.0f]];
    _temporaryCell = (BIDInvestListCell*)[[[NSBundle mainBundle] loadNibNamed:@"BIDInvestListCell" owner:self options:nil] lastObject];
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
    parent.navigationItem.title = @"投资信息";
}

- (void)prepareForData
{
    self.strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strInvestListURL];
    [self firstLoadData];
}

//普通加载
- (void)commonLoadDataForPage
{
    if(self.bLoadFirstPageData && !_refreshControl.refreshing)
    {
        [self.spinnerView showTheView];
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSInteger value = [BIDDataCommunication getDataFromNet:self.strURL toArray:self.itemsArr page:self.pageNumber];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(self.bLoadFirstPageData)
            {
                self.bLoadFirstPageData = NO;
                if(!_refreshControl.refreshing)
                {
                    [self.spinnerView dismissTheView];
                }
                else
                {
                    [_refreshControl endRefreshing];
                    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新"];
                }
            }
            [self loadDataComplete];
            //成功
            if(value==1)
            {
                //计算每个标题的高度
                for(NSDictionary *dictionary in self.itemsArr)
                {
                    CGSize constraintSize = CGSizeMake(CGRectGetWidth(self.view.frame)-14-30, MAXFLOAT);
                    NSString *strTitle = [dictionary objectForKey:@"borrowName"];
                    CGFloat height = [BIDCommonMethods getHeightWithString:strTitle font:[UIFont systemFontOfSize:15.0f] constraintSize:constraintSize];
                    NSNumber *value = [NSNumber numberWithFloat:height];
                    [self.heightArr addObject:value];
                }
                [self.tableView reloadData];
                if(self.itemsArr.count<self.pageNumber*[BIDDataCommunication getCountPerPage])
                {
                    self.bHasMore = NO;
                    self.pageNumber==1?1:self.pageNumber--;
                }
            }
            else if(value==2)
            {
                [BIDCommonMethods showAlertView:err_msg buttonTitle:@"关闭" delegate:self tag:2];
            }
            else
            {
                self.pageNumber==1?1:self.pageNumber--;
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"加载失败" delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil, nil];
                [alert show];
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

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.itemsArr.count;
}

#pragma mark UITableViewDelegate
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
    NSDictionary *dictionary = self.itemsArr[row];
    NSString *borrowName = [dictionary objectForKey:@"borrowName"];
//    NSNumber *heightValue = self.heightArr[row];
//    CGRect frame = listCell.titleLabel.frame;
//    frame.size.height = [heightValue floatValue];
//    listCell.titleLabel.frame = frame;
//    listCell.titleLabel.text = borrowName;
//    listCell.titleLabel.numberOfLines = 0;
    listCell.titleLabel.text = borrowName;
    listCell.dateLabel.text = dictionary[@"investTime"];
    listCell.amountLabel.text = [[NSString alloc] initWithFormat:@"%@", dictionary[@"investAmt"]];
    cell = listCell;
    [cell setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:240.0f/255.0f blue:241.0f/255.0f alpha:1.0f]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSUInteger row = indexPath.row;
    NSDictionary *dictionary = self.itemsArr[row];
    BIDInvestInfoViewController *vc = [[BIDInvestInfoViewController alloc] init];
    vc.investId = [dictionary objectForKey:@"id"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rowHeight = 0.0f;
    NSUInteger row = indexPath.row;
//    NSNumber *heightValue = self.heightArr[row];
//    CGFloat height = [heightValue floatValue] + 10*2;
//    rowHeight = height<44.0f?44.0f:height;
    NSDictionary *dic = self.itemsArr[row];
    _temporaryCell.titleLabel.preferredMaxLayoutWidth = CGRectGetWidth(tableView.frame)-16-14-74;
    _temporaryCell.titleLabel.text = dic[@"borrowName"];
    CGSize size = [_temporaryCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    rowHeight = size.height+1;
    return rowHeight;
}

@end

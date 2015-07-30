//
//  BIDMyInvestListViewController.m
//  zhongrongbao
//
//  Created by mal on 15/7/7.
//  Copyright (c) 2015年 cnsoft. All rights reserved.
//

#import "BIDMyInvestListViewController.h"
#import "BIDInvestInfoViewController.h"
#import "BIDSubCategoryCollectionCell.h"
#import "BIDInvestListCell.h"
#import "BIDMyTableView.h"

/**
 *投资列表
 */
static NSString *strInvestListURL = @"Invest/onePage.shtml";

@interface BIDMyInvestListViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, BIDMyTableViewDelegate>
{
    UICollectionView *_collectionView;
    NSMutableArray *_dataSourceArr;
    //保存tableView的滚动行数
    NSMutableArray *_offsetArr;
    BIDInvestListCell *_temporaryCell;
    CGFloat _tableViewWidth;
    CGFloat _tableViewHeight;
    BOOL _bRegister;
}
@end

@implementation BIDMyInvestListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [BIDDataCommunication setCountPerPage:15];
    _dataSourceArr = [[NSMutableArray alloc] init];
    _offsetArr = [[NSMutableArray alloc] init];
    for(int i=0; i<4; i++)
    {
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        [_dataSourceArr addObject:arr];
        NSNumber *value = [NSNumber numberWithFloat:0.f];
        [_offsetArr addObject:value];
    }
    //
    _temporaryCell = (BIDInvestListCell*)[[[NSBundle mainBundle] loadNibNamed:@"BIDInvestListCell" owner:self options:nil] lastObject];
    //
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat ownWidth = screenSize.width;
    CGFloat ownHeight = screenSize.height - 64;
    _tableViewWidth = ownWidth;
    _tableViewHeight = ownHeight - CGRectGetHeight(_segmentedControl.frame) - 8*2;
    //create collectionView
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setMinimumInteritemSpacing:0.0f];
    [flowLayout setMinimumLineSpacing:0.f];
    [flowLayout setItemSize:CGSizeMake(_tableViewWidth, _tableViewHeight)];
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_segmentedControl.frame)+8, ownWidth, _tableViewHeight) collectionViewLayout:flowLayout];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.bounces = NO;
    [self.view addSubview:_collectionView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    parent.navigationItem.titleView = nil;
    parent.navigationItem.title = @"投资信息";
    parent.navigationItem.rightBarButtonItem = nil;
}

#pragma mark UISegmentedControlChangeEvent
- (IBAction)segmentedControlChangeHandler:(UISegmentedControl*)segmentedControl
{
    int selectIndex = segmentedControl.selectedSegmentIndex;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:segmentedControl.selectedSegmentIndex inSection:0];
    [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}

#pragma mark -UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(![scrollView isKindOfClass:[UICollectionView class]]) return;
    CGFloat pageWidth = scrollView.frame.size.width;
    NSInteger page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if(_segmentedControl.selectedSegmentIndex != page)
    {
        _segmentedControl.selectedSegmentIndex = page;
        //
        UICollectionView *tempView = (UICollectionView*)scrollView;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:page inSection:0];
        UICollectionViewCell *tempCell = [tempView cellForItemAtIndexPath:indexPath];
        BIDMyTableView *tempTableView = (BIDMyTableView*)[tempCell.contentView viewWithTag:100];
        NSArray *dataSource = _dataSourceArr[page];
        if(tempTableView && (!dataSource || dataSource.count==0))
        {
            [tempTableView firstLoadData];
        }
    }
}

#pragma mark -UIcollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 4;
}
- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    static NSString *identifier = @"identifier";
    if(!_bRegister)
    {
        _bRegister = YES;
        [collectionView registerClass:[BIDSubCategoryCollectionCell class] forCellWithReuseIdentifier:identifier];
    }
    NSUInteger row = indexPath.row;
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    BIDMyTableView *tableView = (BIDMyTableView*)[cell.contentView viewWithTag:100];
    if(!tableView)
    {
        tableView = [[BIDMyTableView alloc] initWithFrame:CGRectMake(0, 0, _tableViewWidth, _tableViewHeight)];
        tableView.tag = 100;
        tableView.myDelegate = self;
        [tableView setBackgroundColor:[UIColor colorWithRed:244.0f/255.0f green:244.0f/255.0f blue:244.0f/255.0f alpha:1.0f]];
        [cell.contentView addSubview:tableView];
    }
    tableView.tableFooterView = [[UIView alloc] init];
    NSArray *dataSource = _dataSourceArr[row];
    if(!dataSource || dataSource.count==0)
    {
        NSString *strURL = @"";
        switch(indexPath.row)
        {
            case 0:
            {
                strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strInvestListURL];
            }
                break;
            case 1:
            {
                strURL = [[NSString alloc] initWithFormat:@"%@/%@?borrowStatus=%@", [BIDAppDelegate getServerAddr], strInvestListURL, @"02"];
            }
                break;
            case 2:
            {
                strURL = [[NSString alloc] initWithFormat:@"%@/%@?borrowStatus=%@", [BIDAppDelegate getServerAddr], strInvestListURL, @"04"];
            }
                break;
            case 3:
            {
                strURL = [[NSString alloc] initWithFormat:@"%@/%@?borrowStatus=%@", [BIDAppDelegate getServerAddr], strInvestListURL, @"05"];
            }
                break;
        }
        tableView.strURL = strURL;
        if(!collectionView.dragging && !collectionView.decelerating)
        {
            [tableView firstLoadData];
        }
    }
    else
    {
        [tableView.itemsArr setArray:dataSource];
        [tableView reloadData];
        //获取该tableView的内容偏移高度
        NSNumber *value = _offsetArr[indexPath.row];
        tableView.contentOffset = CGPointMake(0, [value floatValue]);
    }
    cell.contentView.autoresizesSubviews = NO;
    return cell;
}

#pragma mark - BIDMyTableViewDelegate
- (void)updateDataSource:(NSMutableArray *)arr
{
    NSMutableArray *desArr = _dataSourceArr[_segmentedControl.selectedSegmentIndex];
    [desArr setArray:arr];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ((BIDMyTableView*)tableView).itemsArr.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //tableview内容的偏移
    NSNumber *value = [NSNumber numberWithFloat:tableView.contentOffset.y];
    [_offsetArr replaceObjectAtIndex:_segmentedControl.selectedSegmentIndex withObject:value];
    //
    UITableViewCell *cell = nil;
    NSUInteger row = indexPath.row;
    static NSString *identifier = @"identifier";
//    if(!_bRegister)
//    {
//        _bRegister = YES;
//        UINib *nib = [UINib nibWithNibName:@"BIDInvestListCell" bundle:nil];
//        [tableView registerNib:nib forCellReuseIdentifier:identifier];
//    }
    BIDInvestListCell *listCell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!listCell)
    {
        UINib *nib = [UINib nibWithNibName:@"BIDInvestListCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:identifier];
        listCell = [tableView dequeueReusableCellWithIdentifier:identifier];
    }
    NSDictionary *dictionary = ((BIDMyTableView*)tableView).itemsArr[row];
    NSString *borrowName = [dictionary objectForKey:@"borrowName"];
    listCell.titleLabel.text = borrowName;
    listCell.dateLabel.text = dictionary[@"investTime"];
    listCell.amountLabel.text = [[NSString alloc] initWithFormat:@"%@", dictionary[@"investAmt"]];
    listCell.flagLabel.text = @"投资金额";
    cell = listCell;
    [cell setBackgroundColor:[UIColor whiteColor]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSUInteger row = indexPath.row;
    NSDictionary *dictionary = ((BIDMyTableView*)tableView).itemsArr[row];
    BIDInvestInfoViewController *vc = [[BIDInvestInfoViewController alloc] init];
    vc.investId = [dictionary objectForKey:@"id"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
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

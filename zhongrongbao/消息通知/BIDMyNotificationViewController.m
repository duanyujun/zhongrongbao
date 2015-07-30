//
//  BIDMyNotificationViewController.m
//  zhongrongbao
//
//  Created by mal on 14/12/26.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDMyNotificationViewController.h"
#import "BIDMsgCategoryView.h"
#import "BIDMsgCell.h"
#import "BIDMsgDetailViewController.h"

@interface BIDMyNotificationViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate, BIDMsgCategoryViewDelegate>
{
    UICollectionView *_myCollectionView;
    /**
     *用户消息
     */
    NSArray *msgForUserArr;
    /**
     *系统消息
     */
    NSArray *msgForSystemArr;
    /**
     *广播消息
     */
    NSArray *msgForBroadcastArr;
    /**
     *注册collection cell
     */
    BOOL _bRegister1;
    /**
     *注册table view cell
     */
    BOOL _bRegister2;
    /**
     *
     */
    BIDMsgCategoryView *_msgCategoryView;
    /**
     *
     */
    NSMutableArray *_dataSourceArr;
    /**
     *
     */
    NSUInteger categoryType;
}

@end

@implementation BIDMyNotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"消息通知";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self prepareForData];
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    //
    _msgCategoryView = [[BIDMsgCategoryView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, 45)];
    _msgCategoryView.delegate = self;
    [_msgCategoryView changeStateByIndex:0];
    //[self.view addSubview:_msgCategoryView];
    //
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshMsgList)];
    //
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(screenSize.width, screenSize.height-64)];
    [flowLayout setMinimumInteritemSpacing:0];
    [flowLayout setMinimumLineSpacing:0];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _myCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height-64) collectionViewLayout:flowLayout];
    _myCollectionView.dataSource = self;
    _myCollectionView.delegate = self;
    _myCollectionView.pagingEnabled = YES;
    [_myCollectionView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [_myCollectionView setBackgroundColor:[UIColor clearColor]];
    _myCollectionView.bounces = NO;
    _myCollectionView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_myCollectionView];
    
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    //
    parent.navigationItem.titleView = nil;
    parent.navigationItem.title = @"消息通知";
    parent.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshMsgList)];
}

- (void)prepareForData
{
    categoryType = 0;
    msgForUserArr = [[NSArray alloc] init];
    //msgForSystemArr = [[NSArray alloc] init];
    //msgForBroadcastArr = [[NSArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self refreshMsgList];
}

- (void)loadData
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *strMsgRootPath = @"";
        NSArray *pathArr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        strMsgRootPath = pathArr[0];
        NSString *strMsgForUserPath = [strMsgRootPath stringByAppendingPathComponent:@"msg_user.plist"];
       // NSString *strMsgForSystemPath = [strMsgRootPath stringByAppendingPathComponent:@"msg_system.plist"];
        //NSString *strMsgForBroadcastPath = [strMsgRootPath stringByAppendingPathComponent:@"msg_broadcast.plist"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if([fileManager fileExistsAtPath:strMsgForUserPath])
        {
            msgForUserArr = [[NSArray alloc] initWithContentsOfFile:strMsgForUserPath];
            _dataSourceArr = [[NSMutableArray alloc] initWithArray:msgForUserArr];
        }
//        if([fileManager fileExistsAtPath:strMsgForSystemPath])
//        {
//            msgForSystemArr = [[NSArray alloc] initWithContentsOfFile:strMsgForSystemPath];
//        }
//        if([fileManager fileExistsAtPath:strMsgForBroadcastPath])
//        {
//            msgForBroadcastArr = [[NSArray alloc] initWithContentsOfFile:strMsgForBroadcastPath];
//        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [_myCollectionView reloadData];
        });
    });
}
/**
 *刷新当前的消息列表
 */
- (void)refreshMsgList
{
    [_dataSourceArr removeAllObjects];
    NSString *strMsgRootPath = @"";
    NSArray *pathArr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    strMsgRootPath = pathArr[0];
    NSString *strMsgForUserPath = [strMsgRootPath stringByAppendingPathComponent:@"msg_user.plist"];
    NSString *strMsgForSystemPath = [strMsgRootPath stringByAppendingPathComponent:@"msg_system.plist"];
    NSString *strMsgForBroadcastPath = [strMsgRootPath stringByAppendingPathComponent:@"msg_broadcast.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:strMsgForUserPath])
    {
        msgForUserArr = [[NSArray alloc] initWithContentsOfFile:strMsgForUserPath];
        //_dataSourceArr = [[NSMutableArray alloc] initWithArray:msgForUserArr];
    }
    if([fileManager fileExistsAtPath:strMsgForSystemPath])
    {
        msgForSystemArr = [[NSArray alloc] initWithContentsOfFile:strMsgForSystemPath];
    }
    if([fileManager fileExistsAtPath:strMsgForBroadcastPath])
    {
        msgForBroadcastArr = [[NSArray alloc] initWithContentsOfFile:strMsgForBroadcastPath];
    }

    NSArray *arr1 = [_myCollectionView indexPathsForVisibleItems];
    if(arr1.count>0)
    {
        NSIndexPath *indexPath = arr1[0];
        NSArray *arr = nil;
        switch(indexPath.row)
        {
            case 0:
            {
                arr = msgForUserArr;
                //[_dataSourceArr setArray:msgForUserArr];
            }
                break;
            case 1:
            {
                arr = msgForSystemArr;
                //[_dataSourceArr setArray:msgForSystemArr];
            }
                break;
            case 2:
            {
                arr = msgForBroadcastArr;
                //[_dataSourceArr setArray:msgForBroadcastArr];
            }
                break;
        }
        for(int i=arr.count-1; i>=0; i--)
        {
            [_dataSourceArr addObject:arr[i]];
        }
        [_myCollectionView reloadItemsAtIndexPaths:@[indexPath]];
    }
}

#pragma mark - BIDMsgCategoryViewDelegate
- (void)chooseCategoryWithIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [_myCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionRight animated:NO];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //
    if([scrollView isKindOfClass:[UICollectionView class]])
    {
        CGFloat pageWidth = scrollView.frame.size.width;
        NSInteger page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        [_msgCategoryView changeStateByIndex:page];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    NSUInteger row = indexPath.row;
    categoryType = row;
    NSArray *arr = nil;
    [_dataSourceArr removeAllObjects];
    switch(row)
    {
        case 0:
        {
            arr = msgForUserArr;
            //[_dataSourceArr setArray:msgForUserArr];
        }
            break;
        case 1:
        {
            arr = msgForSystemArr;
            //[_dataSourceArr setArray:msgForSystemArr];
        }
            break;
        case 2:
        {
            arr = msgForBroadcastArr;
            //[_dataSourceArr setArray:msgForBroadcastArr];
        }
            break;
    }
    for(int i=arr.count-1; i>=0; i--)
    {
        [_dataSourceArr addObject:arr[i]];
    }
    static NSString *identifier = @"identifier";
    if(!_bRegister1)
    {
        _bRegister1 = YES;
        UINib *nib = [UINib nibWithNibName:@"BIDMsgForCollectionCell" bundle:nil];
        [collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
    }
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    UIView *subView = [cell.contentView viewWithTag:100];
    if(!subView)
    {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(collectionView.frame), CGRectGetHeight(collectionView.frame))];
        tableView.dataSource = self;
        tableView.delegate = self;
        [cell.contentView addSubview:tableView];
        subView = tableView;
    }
    UITableView *tableView1 = (UITableView*)subView;
    [tableView1 reloadData];
    return cell;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch(categoryType)
    {
        case 0:
        {
            return msgForUserArr.count;
        }
            break;
        case 1:
        {
            return msgForSystemArr.count;
        }
            break;
        case 2:
        {
            return msgForBroadcastArr.count;
        }
            break;
    }
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    NSUInteger row = indexPath.row;
    static NSString *identifier = @"identifier";
    //if(!_bRegister2)
    {
        //_bRegister2 = YES;
        UINib *nib = [UINib nibWithNibName:@"BIDMsgCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:identifier];
    }
    BIDMsgCell *msgCell = (BIDMsgCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    NSDictionary *dictionary = _dataSourceArr[row];
    UIImage *img = nil;
    switch(categoryType)
    {
        case 0:
        {
            img = [UIImage imageNamed:@"msg_user.png"];
        }
            break;
        case 1:
        {
            img = [UIImage imageNamed:@"msg_system.png"];
        }
            break;
        case 2:
        {
            img = [UIImage imageNamed:@"msg_broadcast.png"];
        }
            break;
    }
    msgCell.imgView.image = img;
    msgCell.titleLabel.text = [dictionary objectForKey:@"title"];
    msgCell.dateLabel.text = [dictionary objectForKey:@"date"];
    msgCell.contentLabel.text = [dictionary objectForKey:@"content"];
    [cell setBackgroundColor:[UIColor clearColor]];
    cell = msgCell;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUInteger row = indexPath.row;
    NSDictionary *dictionary = _dataSourceArr[row];
    BIDMsgDetailViewController *vc = [[BIDMsgDetailViewController alloc] initWithNibName:@"BIDMsgDetailViewController" bundle:nil];
    vc.msgTitle = [dictionary objectForKey:@"title"];
    vc.msgDate = [dictionary objectForKey:@"date"];
    vc.msgContent = [dictionary objectForKey:@"content"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 88;
    return height;
}

@end

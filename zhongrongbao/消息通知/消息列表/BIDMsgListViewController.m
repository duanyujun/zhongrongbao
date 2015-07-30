//
//  BIDMsgListViewController.m
//  zhongrongbao
//
//  Created by mal on 15/1/7.
//  Copyright (c) 2015年 cnsoft. All rights reserved.
//

#import "BIDMsgListViewController.h"
#import "BIDHeaderViewForRefresh.h"
#import "BIDMsgCell.h"
#import "BIDMsgDetailViewController.h"

@interface BIDMsgListViewController ()<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
{
    BOOL _bRefreshing;
    BOOL _bRegister;
    BOOL _bEditing;
    BIDHeaderViewForRefresh *_headerViewForRefresh;
    NSMutableArray *_dataSourceArr;
    UIToolbar *_toolBar;
}
@end

@implementation BIDMsgListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _dataSourceArr = [[NSMutableArray alloc] init];
    //
    _headerViewForRefresh = (BIDHeaderViewForRefresh*)[[[NSBundle mainBundle] loadNibNamed:@"BIDHeaderViewForRefresh" owner:self options:nil] lastObject];
    CGRect headerViewForRefreshFrame = _headerViewForRefresh.frame;
    headerViewForRefreshFrame.origin.y = -CGRectGetHeight(headerViewForRefreshFrame);
    _headerViewForRefresh.frame = headerViewForRefreshFrame;
    [_myTableView addSubview:_headerViewForRefresh];
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    //_myTableView.frame = CGRectMake(0, 0, screenSize.width, screenSize.height-64);
    //
    //设置toolbar
    CGSize toolBarSize = CGSizeMake(screenSize.width, 30);
    CGRect toolBarFrame = CGRectMake(0, screenSize.height-toolBarSize.height, toolBarSize.width, toolBarSize.height);
    _toolBar = [[UIToolbar alloc] initWithFrame:toolBarFrame];
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"标记" style:UIBarButtonItemStylePlain target:self action:@selector(signHandler)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:@"删除" style:UIBarButtonItemStylePlain target:self action:@selector(deleteHandler)];
    UIBarButtonItem *item3 = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelHandler)];
    UIBarButtonItem *blankItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [_toolBar setItems:[[NSArray alloc] initWithObjects:item1, blankItem, item2, blankItem, item3, nil]];
    //
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
    parent.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editHandler)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self loadData];
}

- (void)loadData
{
    [_dataSourceArr removeAllObjects];
    _bRefreshing = YES;
    NSString *strMsgRootPath = @"";
    NSArray *pathArr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    strMsgRootPath = pathArr[0];
    NSString *strMsgForUserPath = [strMsgRootPath stringByAppendingPathComponent:@"msg_user.plist"];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:strMsgForUserPath];
    [self performSelector:@selector(loadComplete) withObject:nil afterDelay:0.5f];
    if(dictionary)
    {
        NSString *strKey = [BIDAppDelegate getUserId];
        _dataSourceArr = dictionary[strKey];
        [_myTableView reloadData];
    }
}

/**
 *加载数据完毕
 */
- (void)loadComplete
{
    _bRefreshing = NO;
    [_headerViewForRefresh completeRefresh];
    [_myTableView setContentInset:UIEdgeInsetsZero];
}

//编辑
- (void)editHandler
{
    if(!_bEditing && _dataSourceArr.count>0)
    {
        _myTableView.allowsMultipleSelectionDuringEditing = YES;
        _bEditing = YES;
        [self showToolBar];
        [_myTableView setEditing:_bEditing animated:YES];
    }
}

//toolbar中的标记
- (void)signHandler
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"全部标记", @"取消标记", nil];
    [actionSheet showInView:self.view];
}

//toolbar中的删除
- (void)deleteHandler
{
    NSArray *arr = [_myTableView indexPathsForSelectedRows];
    NSInteger count = _dataSourceArr.count;
    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
    for(NSIndexPath *indexPath in arr)
    {
        NSUInteger row = indexPath.row;
        NSUInteger index = count-1-row;
        [indexSet addIndex:index];
    }
    [_dataSourceArr removeObjectsAtIndexes:indexSet];
    //将删除后的内容更新到文件中
    NSString *strMsgRootPath = @"";
    NSArray *pathArr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    strMsgRootPath = pathArr[0];
    NSString *strMsgForUserPath = [strMsgRootPath stringByAppendingPathComponent:@"msg_user.plist"];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:strMsgForUserPath];
    if(!dictionary) dictionary = [[NSMutableDictionary alloc] init];
    NSString *strKey = [BIDAppDelegate getUserId];
    dictionary[strKey] = _dataSourceArr;
    [dictionary writeToFile:strMsgForUserPath atomically:YES];
    //
    [_myTableView deleteRowsAtIndexPaths:arr withRowAnimation:UITableViewRowAnimationNone];
}

//toolbar中的取消
- (void)cancelHandler
{
    [self dismissToolBar];
}

//显示功能栏
- (void)showToolBar
{
    CGRect frame = _myTableView.frame;
    frame.size.height = frame.size.height-_toolBar.frame.size.height;
    _myTableView.frame = frame;
    //
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:_toolBar];
}
//隐藏功能栏
- (void)dismissToolBar
{
    CGRect frame = _myTableView.frame;
    frame.size.height += _toolBar.frame.size.height;
    _myTableView.frame = frame;
    //
    [_toolBar removeFromSuperview];
    [_myTableView setEditing:NO animated:YES];
    _myTableView.allowsSelectionDuringEditing = NO;
    _bEditing = NO;
}

//全部标记
- (void)allChoose
{
    NSArray *arr = [_myTableView indexPathsForVisibleRows];
    for(NSIndexPath *indexPath in arr)
    {
        [_myTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
}
//取消全部标记
- (void)allInChoose
{
    NSArray *arr = [_myTableView indexPathsForSelectedRows];
    for(NSIndexPath *indexPath in arr)
    {
        [_myTableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch(buttonIndex)
    {
        case 0:
        {
            //全部标记
            [self allChoose];
        }
            break;
        case 1:
        {
            //取消标记
            [self allInChoose];
        }
            break;
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //下拉并且不是正在刷新
    if(scrollView.contentOffset.y < 0 && !_bRefreshing)
    {
        if(scrollView.contentOffset.y < -CGRectGetHeight(_headerViewForRefresh.frame))
        {
            [_headerViewForRefresh canRefresh];
        }
        else if(scrollView.contentOffset.y > -CGRectGetHeight(_headerViewForRefresh.frame))
        {
            [_headerViewForRefresh readyRefresh];
        }
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(_bRefreshing)
    {
        return;
    }
    else
    {
        if(scrollView.contentOffset.y>0 && scrollView.contentOffset.y+CGRectGetHeight(self.view.frame)-scrollView.contentSize.height>60)
        {
        }
        else if(scrollView.contentOffset.y<0 && scrollView.contentOffset.y < -CGRectGetHeight(_headerViewForRefresh.frame))
        {
            [scrollView setContentInset:UIEdgeInsetsMake(CGRectGetHeight(_headerViewForRefresh.frame), 0, 0, 0)];
            [_headerViewForRefresh isRefreshing];
            [self loadData];
        }
    }
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSourceArr.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    NSUInteger row = indexPath.row;
    static NSString *identifier = @"identifier";
    if(!_bRegister)
    {
        _bRegister = YES;
        UINib *nib = [UINib nibWithNibName:@"BIDMsgCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:identifier];
    }
    BIDMsgCell *msgCell = (BIDMsgCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    //反向排列
    NSInteger count = _dataSourceArr.count;
    NSDictionary *dictionary = _dataSourceArr[count-1-row];
    UIImage *img = img = [UIImage imageNamed:@"msg_user.png"];
    msgCell.imgView.image = img;
    msgCell.titleLabel.text = [dictionary objectForKey:@"title"];
    msgCell.dateLabel.text = [dictionary objectForKey:@"date"];
    msgCell.contentLabel.text = [dictionary objectForKey:@"content"];
    [cell setBackgroundColor:[UIColor clearColor]];
    cell = msgCell;
    cell.multipleSelectionBackgroundView = nil;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!_bEditing)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        NSUInteger row = indexPath.row;
        NSInteger count = _dataSourceArr.count;
        NSDictionary *dictionary = _dataSourceArr[count-1-row];
        BIDMsgDetailViewController *vc = [[BIDMsgDetailViewController alloc] initWithNibName:@"BIDMsgDetailViewController" bundle:nil];
        vc.msgTitle = [dictionary objectForKey:@"title"];
        vc.msgDate = [dictionary objectForKey:@"date"];
        vc.msgContent = [dictionary objectForKey:@"content"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 88;
    return height;
}

@end

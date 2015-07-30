  //
//  BIDMyTableViewController.m
//  TestViewControlelr
//
//  Created by mal on 13-10-28.
//  Copyright (c) 2013年 mal. All rights reserved.
//

#import "BIDMyTableViewController.h"
#import "BIDDataCommunication.h"

#define REFRESH_HEIGHT 44.0f
#define HEADER_HEIGHT 35.0f

@interface BIDMyTableViewController ()

@end

@implementation BIDMyTableViewController
@synthesize navController;
@synthesize customView;
@synthesize label;
@synthesize arrowView;
@synthesize spinner1;
@synthesize strPull;
@synthesize strRelease;
@synthesize strRefresh;
@synthesize strNoMore;
@synthesize myScrollView;
@synthesize bLoading;
@synthesize bHasMore;
@synthesize bDragging;
@synthesize bLoadFirstPageData;

@synthesize customHeaderView;
@synthesize headerBtn;
@synthesize bShowHeaderView;
//@synthesize searchViewController;

@synthesize strURL;
@synthesize type;
@synthesize pageNumber;
@synthesize pageNumberForSearch;
@synthesize itemsArr;
@synthesize flagArr;
@synthesize bSearchForCondition;
@synthesize strBelongTo;

@synthesize paramsArr;
@synthesize spinnerView;

@synthesize appDelegate;
@synthesize bgImgView;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    if(myScrollView!=nil)
    {
        myScrollView.contentInset = UIEdgeInsetsZero;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    _edgeInsets = self.tableView.contentInset;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新"];
    [_refreshControl addTarget:self action:@selector(refreshControlHandler:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = _refreshControl;
    
    self.itemsArr = [NSMutableArray arrayWithCapacity:1];
    self.flagArr = [NSMutableArray arrayWithCapacity:1];
    self.heightArr = [NSMutableArray arrayWithCapacity:1];
    self.paramsArr = [NSMutableArray arrayWithCapacity:3];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:self action:@selector(backBtnHandler)];
    
    appDelegate = (BIDAppDelegate*)[UIApplication sharedApplication].delegate;
    self.navController = self.navigationController;
    
    self.bLoadFirstPageData = YES;
    self.pageNumber = 1;
    
    self.spinnerView = [[BIDCustomSpinnerView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 60.0f, 60.0f)];
    [spinnerView initLayout];
    
    self.bLoading = NO;
    self.bHasMore = YES;
    self.bDragging = NO;
    self.bShowHeaderView = NO;
    self.bSearchForCondition = NO;
    
    self.strPull = @"上拉刷新";
    self.strRelease = @"释放开始刷新";
    self.strRefresh = @"正在加载";
    self.strNoMore = @"没有更多内容了...";
    
    self.customView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, REFRESH_HEIGHT)];
    [self.customView setBackgroundColor:[UIColor clearColor]];
    
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, REFRESH_HEIGHT)];
    [self.label setText:self.strPull];
    [self.label setTextAlignment:NSTextAlignmentCenter];
    [self.label setTextColor:[UIColor colorWithRed:234.0f/255.0f green:72.0f/255.0f blue:90.0f/255.0f alpha:1.0f]];
    [self.label setBackgroundColor:[UIColor clearColor]];
    [self.customView addSubview:self.label];
    
    self.arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
    [self.arrowView setFrame:CGRectMake(40.0f, 0.0f, 44.0f, REFRESH_HEIGHT)];
    [self.customView addSubview:self.arrowView];
    
    self.spinner1 = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGRect frame = CGRectMake(0.0f, 0.0f, 20.0f, 20.0f);
    frame.origin.x = 40;
    frame.origin.y = self.customView.frame.size.height/2 - frame.size.height/2;
    self.spinner1.frame = frame;
    self.spinner1.hidesWhenStopped = YES;
    [self.customView addSubview:self.spinner1];
    
    self.customView.hidden = YES;
    [self.tableView addSubview:self.customView];
    //设置检索按钮视图
    self.customHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0.0f, -HEADER_HEIGHT, self.tableView.frame.size.width, HEADER_HEIGHT)];
    [self.customHeaderView setBackgroundColor:[UIColor clearColor]];
    self.customHeaderView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.customHeaderView.layer.borderWidth = 3.0f;
    self.customHeaderView.layer.cornerRadius = 8.0f;
    self.customHeaderView.hidden = YES;
    
    CGSize headerBtnSize = CGSizeMake(60.0f, 30.0f);
    self.headerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect headerBtnFrame = CGRectMake(self.customHeaderView.frame.size.width/2-headerBtnSize.width/2, self.customHeaderView.frame.size.height/2-headerBtnSize.height/2, headerBtnSize.width, headerBtnSize.height);
    headerBtn.frame = headerBtnFrame;
    UIImageView *imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"magnifier.png"]];
    imgView.frame = CGRectMake(15.0f, 0.0f, 30.0f, 30.0f);
    [headerBtn addSubview:imgView];
    [self.headerBtn addTarget:self action:@selector(showSearchView) forControlEvents:UIControlEventTouchUpInside];
    [self.customHeaderView addSubview:self.headerBtn];
    //[self.tableView addSubview:self.customHeaderView];
    
    //创建检索条件视图
//    searchViewController = [[BIDSearchViewController alloc] initWithNibName:@"BIDSearchViewController" bundle:nil];
//    searchViewController.strType = strBelongTo;
//    searchViewController.passValueDelegate = self;
//    [searchViewController defaultInit];
        
    //添加背景
    if([UIScreen mainScreen].bounds.size.height>=568)
    {
        //bgImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[BIDAppDelegate getViewBgImg2]]];
    }
    else
    {
        //bgImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[BIDAppDelegate getViewBgImg]]];
    }
    
    bgImgView.frame = self.tableView.frame;
    self.tableView.backgroundView = bgImgView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.arrowView = nil;
    self.customView = nil;
    self.arrowView = nil;
    self.myScrollView = nil;
    self.spinner1 = nil;
    self.headerBtn = nil;
    self.customHeaderView = nil;
    //self.searchViewController = nil;
    
    self.itemsArr = nil;
    self.flagArr = nil;
    self.paramsArr = nil;
    
    self.spinnerView = nil;
    self.navController = nil;
    
    self.appDelegate = nil;
}

//返回按钮事件
- (void)backBtnHandler
{
    [self.navController popViewControllerAnimated:YES];
}

//下拉刷新
- (void)refreshControlHandler:(UIRefreshControl*)refreshControl
{
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"刷新中"];
    [self firstLoadData];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if(bLoading) return;
    if(scrollView.contentOffset.y>0)
    {
        self.bDragging = YES;
    }
    self.myScrollView = scrollView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView.contentOffset.y<=0)
    {
        //self.bHasMore = NO;
//        if(scrollView.contentOffset.y<=-HEADER_HEIGHT)
//        {
//            self.bShowHeaderView = YES;
//            scrollView.contentInset = UIEdgeInsetsMake(HEADER_HEIGHT, 0.0f, 0.0f, 0.0f);
//        }
//        else if(scrollView.contentOffset.y<=0 && scrollView.contentOffset.y>-HEADER_HEIGHT)
//        {
//            self.bShowHeaderView = NO;
//            scrollView.contentInset = UIEdgeInsetsZero;
//        }
    }
    else
    {
        if(scrollView.contentSize.height>self.tableView.frame.size.height)
        {
            self.customView.hidden = NO;
            CGRect frame = self.customView.frame;
            frame.origin.y = scrollView.contentSize.height;
            self.customView.frame = frame;
        }
        else
        {
            self.bHasMore = NO;
            return;
        }
        //上拉执行
        if(self.bLoading && scrollView.contentOffset.y>0)
        {
            scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, REFRESH_HEIGHT, 0.0f);
        }
        else if(!self.bHasMore)
        {
            self.arrowView.hidden = YES;
            self.label.hidden = NO;
            self.label.text = self.strNoMore;
        }
        else if(bDragging && (scrollView.contentOffset.y+self.tableView.frame.size.height-scrollView.contentSize.height)>0)
        {
            self.arrowView.hidden = NO;
            self.label.hidden = NO;
            [UIView beginAnimations:nil context:nil];
            if(scrollView.contentOffset.y+self.tableView.frame.size.height-scrollView.contentSize.height<REFRESH_HEIGHT)
            {
                self.label.text = self.strPull;
                [self.arrowView layer].transform = CATransform3DMakeRotation(M_PI*2, 0.0f, 0.0f, 1.0f);
            }
            else
            {
                self.label.text = self.strRelease;
                [self.arrowView layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
            }
            [UIView commitAnimations];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(self.bHasMore && scrollView.contentOffset.y>0 && (scrollView.contentOffset.y+self.tableView.frame.size.height-scrollView.contentSize.height>=REFRESH_HEIGHT))
    {
        self.arrowView.hidden = YES;
        self.spinner1.hidden = NO;
        [self.spinner1 startAnimating];
        self.label.text = self.strRefresh;
        self.bLoading = YES;
        if(bSearchForCondition)
        {
            //[self performSelector:@selector(searchData:) withObject:paramsArr afterDelay:0.5f];
        }
        else
        {
            [self performSelector:@selector(loadData) withObject:nil afterDelay:0.5f];
        }
    }
}
//普通加载
- (void)commonLoadDataForPage
{
    if(bLoadFirstPageData && !_refreshControl.refreshing)
    {
        [spinnerView showTheView];
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSInteger value = [BIDDataCommunication getDataFromNet:strURL toArray:self.itemsArr page:self.pageNumber];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(bLoadFirstPageData)
            {
                bLoadFirstPageData = NO;
                if(!_refreshControl.refreshing)
                {
                    [spinnerView dismissTheView];
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
                [self.tableView reloadData];
                if(self.itemsArr.count<pageNumber*ROWS_PER_PAGE)
                {
                    self.bHasMore = NO;
                    pageNumber==1?1:pageNumber--;
                }
            }
            else
            {
                pageNumber==1?1:pageNumber--;
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"加载失败" delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil, nil];
                [alert show];
            }
        });
    });
}

//视图首次显示时加载的第一页数据
- (void)firstLoadData
{
    self.pageNumber = 1;
    self.bHasMore = YES;
    self.bLoadFirstPageData = YES;
    self.bSearchForCondition = NO;
    //2015-4-21
    NSMutableArray *indexPathArr = [[NSMutableArray alloc] init];
    for(NSUInteger i=0; i<itemsArr.count; i++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [indexPathArr addObject:indexPath];
    }
    [self.itemsArr removeAllObjects];
    if(indexPathArr.count>0)
    {
        [self.tableView deleteRowsAtIndexPaths:indexPathArr withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [self.heightArr removeAllObjects];
    [self commonLoadDataForPage];
}

//获取json数据 分页加载时调用
- (void)loadData
{
    pageNumber++;
    [self commonLoadDataForPage];
}

- (void)loadDataComplete
{
    self.bLoading = NO;
    self.myScrollView.contentInset = _edgeInsets;
    [self.spinner1 stopAnimating];
    self.arrowView.hidden = YES;
    self.label.hidden = YES;
    self.customView.hidden = YES;
}

- (void)showSearchView
{
    //[searchViewController show];
}

#pragma mark BIDPassValueDelegate
//- (void)passValue:(NSString *)value1 value2:(NSString *)value2 value3:(NSString *)value3
//{
//    [self.paramsArr removeAllObjects];
//    [self.itemsArr removeAllObjects];
//    self.pageNumber = 1;
//    self.bHasMore =YES;
//    //全部查找
//    if(value1.length==0 && value2.length==0 && value3.length==0)
//    {
//        bSearchForCondition = NO;
//        [self firstLoadData];
//    }
//    //按条件查找
//    else
//    {
//        bSearchForCondition = YES;
//        [paramsArr addObject:value1];
//        [paramsArr addObject:value2];
//        [paramsArr addObject:value3];
//        [self firstLoadDataForSearch:value1 createTime:value2 param3:value3];
//    }
//}

- (void)passValue:(int)param1
{}

@end

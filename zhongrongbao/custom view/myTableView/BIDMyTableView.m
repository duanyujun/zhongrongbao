//
//  BIDMyTableView.m
//  商务厅
//
//  Created by mal on 13-12-16.
//  Copyright (c) 2013年 mal. All rights reserved.
//

#import "BIDMyTableView.h"

#import "BIDDataCommunication.h"

#define REFRESH_HEIGHT 44.0f
#define HEADER_HEIGHT 44.0f
/**
 *下拉刷新的响应距离
 */
#define PULL_DISTANCE 60.0f

@implementation BIDMyTableView

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
@synthesize strURL;
@synthesize type;
@synthesize pageNumber;
@synthesize pageNumberForSearch;
@synthesize itemsArr;
@synthesize heightArr;
@synthesize spinnerView;
@synthesize bgImgView;

@synthesize appDelegate;
@synthesize myDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        itemsArr = [[NSMutableArray alloc] initWithCapacity:1];
        heightArr = [[NSMutableArray alloc] init];
        [self initView];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)initView
{
    if(!itemsArr) itemsArr = [[NSMutableArray alloc] init];
    if(!heightArr) heightArr = [[NSMutableArray alloc] init];
    self.dataSource = (id)self;
    self.delegate = (id)self;
    appDelegate = (BIDAppDelegate*)[UIApplication sharedApplication].delegate;
    
    self.bLoadFirstPageData = YES;
    self.pageNumber = 1;
    
    self.spinnerView = [[BIDCustomSpinnerView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 60.0f, 60.0f)];
    [spinnerView initLayout];
    
    self.bLoading = NO;
    self.bHasMore = YES;
    self.bDragging = NO;
    
    _pullDownRefreshing = NO;
    
    self.strPull = @"上拉加载更多";
    self.strRelease = @"释放开始加载";
    self.strRefresh = @"正在加载";
    self.strNoMore = @"没有更多内容了...";
    
    self.customView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, REFRESH_HEIGHT)];
    [self.customView setBackgroundColor:[UIColor clearColor]];
    
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, REFRESH_HEIGHT)];
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
    [self addSubview:self.customView];
    //设置下拉刷新视图
    self.customHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0.0f, -HEADER_HEIGHT, self.frame.size.width, HEADER_HEIGHT)];
    [self.customHeaderView setBackgroundColor:[UIColor clearColor]];
    //self.customHeaderView.hidden = YES;
    _pullDownRefreshSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGRect pullDownRefreshSpinnerFrame = CGRectMake(0, 0, 20.0f, 20.0f);
    pullDownRefreshSpinnerFrame.origin.x = self.customHeaderView.frame.size.width/2 - pullDownRefreshSpinnerFrame.size.width/2;
    pullDownRefreshSpinnerFrame.origin.y = 5.0f;
    _pullDownRefreshSpinner.frame = pullDownRefreshSpinnerFrame;
    //_pullDownRefreshSpinner.hidesWhenStopped = YES;
    [self.customHeaderView addSubview:_pullDownRefreshSpinner];
    //
    _pullDownRefreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _pullDownRefreshSpinner.frame.origin.y+_pullDownRefreshSpinner.frame.size.height+5, customHeaderView.frame.size.width, 14)];
    [_pullDownRefreshLabel setText:@"下拉刷新"];
    [_pullDownRefreshLabel setTextAlignment:NSTextAlignmentCenter];
    [_pullDownRefreshLabel setTextColor:[UIColor grayColor]];
    [_pullDownRefreshLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [self.customHeaderView addSubview:_pullDownRefreshLabel];
    [self addSubview:self.customHeaderView];
    //
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
        //self.bHasMore = YES;
        [_pullDownRefreshSpinner startAnimating];
        if(scrollView.contentOffset.y<=-PULL_DISTANCE)
        {
            if(_pullDownRefreshing)
            {
                _pullDownRefreshLabel.text = @"刷新中";
            }
            else
            {
                _pullDownRefreshLabel.text = @"释放开始刷新";
            }
        }
        else if(scrollView.contentOffset.y<=0 && scrollView.contentOffset.y>-PULL_DISTANCE)
        {
            if(_pullDownRefreshing)
            {
                _pullDownRefreshLabel.text = @"刷新中";
            }
            else
            {
                _pullDownRefreshLabel.text = @"下拉刷新";
            }
        }
    }
    else
    {
        if(scrollView.contentSize.height>self.frame.size.height)
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
        else if(bDragging && (scrollView.contentOffset.y+self.frame.size.height-scrollView.contentSize.height)>0)
        {
            self.arrowView.hidden = NO;
            self.label.hidden = NO;
            [UIView beginAnimations:nil context:nil];
            if(scrollView.contentOffset.y+self.frame.size.height-scrollView.contentSize.height<REFRESH_HEIGHT)
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
    //
    if(scrollView.contentOffset.y<=-PULL_DISTANCE && !_pullDownRefreshing)
    {
        scrollView.contentInset = UIEdgeInsetsMake(HEADER_HEIGHT, 0.0f, 0.0f, 0.0f);
        _pullDownRefreshLabel.text = @"刷新中";
        _pullDownRefreshing = YES;
        //重新加载数据
        [self firstLoadData];
    }
    //
    if(self.bHasMore && scrollView.contentOffset.y>0 && (scrollView.contentOffset.y+self.frame.size.height-scrollView.contentSize.height>=REFRESH_HEIGHT))
    {
        self.arrowView.hidden = YES;
        self.spinner1.hidden = NO;
        [self.spinner1 startAnimating];
        self.label.text = self.strRefresh;
        self.bLoading = YES;
        
        [self performSelector:@selector(loadData) withObject:nil afterDelay:0.5f];
    }
}

//视图首次显示时加载的第一页数据
- (void)firstLoadData
{
    self.pageNumber = 1;
    self.bHasMore = YES;
    self.bLoadFirstPageData = YES;
    //2015-7-7
    NSMutableArray *indexPathArr = [[NSMutableArray alloc] init];
    for(NSUInteger i=0; i<itemsArr.count; i++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [indexPathArr addObject:indexPath];
    }
    [self.itemsArr removeAllObjects];
    if(indexPathArr.count>0)
    {
        [self deleteRowsAtIndexPaths:indexPathArr withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [self.heightArr removeAllObjects];
    //
    [self commonLoadDataForPage];
}

//获取json数据 分页加载时调用
- (void)loadData
{
    pageNumber++;
    [self commonLoadDataForPage];
}
//普通加载
- (void)commonLoadDataForPage
{
    if(bLoadFirstPageData && !_pullDownRefreshing)
    {
        [spinnerView showTheView];
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        int value = [BIDDataCommunication getDataFromNet:strURL toArray:self.itemsArr page:self.pageNumber];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(bLoadFirstPageData)
            {
                bLoadFirstPageData = NO;
                if(!_pullDownRefreshing)
                {
                    [spinnerView dismissTheView];
                }
                else
                {
                    // _pullDownRefreshLabel.text = @"下拉刷新";
                    [_pullDownRefreshSpinner stopAnimating];
                    _pullDownRefreshing = NO;
                    [self setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
                }
            }
            [self loadDataComplete];
            //成功
            if(value==1)
            {
                [self reloadData];
                //告知tableView所在viewcontroller数据源发生了改变，该方法可选
                if([myDelegate respondsToSelector:@selector(updateDataSource:)])
                {
                    [self.myDelegate updateDataSource:self.itemsArr];
                }
                //
                if(self.itemsArr.count<pageNumber*[BIDDataCommunication getCountPerPage])
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

- (void)loadDataComplete
{
    self.bLoading = NO;
    self.myScrollView.contentInset = UIEdgeInsetsZero;
    [self.spinner1 stopAnimating];
    self.arrowView.hidden = YES;
    self.label.hidden = YES;
    self.customView.hidden = YES;
}

#pragma mark -UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if([myDelegate respondsToSelector:@selector(numberOfSectionsInTableView:)])
    {
        return [myDelegate numberOfSectionsInTableView:tableView];
    }
    else
    {
        return 1;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rows = [myDelegate tableView:tableView numberOfRowsInSection:section];
    return rows;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [myDelegate tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.f;
    height = [myDelegate tableView:tableView heightForRowAtIndexPath:indexPath];
    return height;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [myDelegate tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if([myDelegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)])
    {
        return [myDelegate tableView:tableView heightForHeaderInSection:section];
    }
    else
    {
        return 0;
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if([myDelegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)])
    {
        return [myDelegate tableView:tableView viewForHeaderInSection:section];
    }
    else
    {
        return nil;
    }
}

@end

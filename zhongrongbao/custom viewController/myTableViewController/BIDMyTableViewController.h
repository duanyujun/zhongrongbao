//
//  BIDMyTableViewController.h
//  TestViewControlelr
//
//  Created by mal on 13-10-28.
//  Copyright (c) 2013年 mal. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "BIDSearchViewController.h"
#import "BIDPassValueDelegate.h"
#import "BIDCustomSpinnerView.h"
#import "BIDAppDelegate.h"
#import "BIDLoginViewController.h"

@interface BIDMyTableViewController : UITableViewController<BIDPassValueDelegate>
{
    UIRefreshControl *_refreshControl;
    UIEdgeInsets _edgeInsets;
}
@property (strong, nonatomic) UIView *customView;
@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UIImageView *arrowView;
@property (strong, nonatomic) UIActivityIndicatorView *spinner1;
@property (strong, nonatomic) NSString *strPull;
@property (strong, nonatomic) NSString *strRelease;
@property (strong, nonatomic) NSString *strRefresh;
@property (strong, nonatomic) NSString *strNoMore;
@property (strong, nonatomic) UIScrollView *myScrollView;
@property (strong, nonatomic) BIDAppDelegate *appDelegate;

@property (strong, nonatomic) UINavigationController *navController;

//@property (strong, nonatomic) BIDSearchViewController *searchViewController;

@property (strong, nonatomic) UIView *customHeaderView;
@property (strong, nonatomic) UIButton *headerBtn;

@property (strong, nonatomic)UIImageView *bgImgView;

@property BOOL bLoading;
@property BOOL bHasMore;
@property BOOL bDragging;
//是否是加载第一页的数据
@property BOOL bLoadFirstPageData;

@property BOOL bShowHeaderView;

//表示图所属模块
@property (strong, nonatomic)NSString *strBelongTo;

//加载数据相关属性
@property (strong, nonatomic) NSString *strURL;
@property NSInteger type;
@property NSUInteger pageNumber;
@property NSUInteger pageNumberForSearch;
@property (strong, nonatomic) NSMutableArray *itemsArr;
@property (strong, nonatomic) NSMutableArray *flagArr;
@property (strong, nonatomic) NSMutableArray *heightArr;
//是否是按条件进行检索
@property BOOL bSearchForCondition;

//
@property (strong, nonatomic)BIDCustomSpinnerView *spinnerView;

//用来保存参数的数组
@property (strong, nonatomic)NSMutableArray *paramsArr;

- (void)loadData;
- (void)firstLoadData;
- (void)commonLoadDataForPage;
- (void)showSearchView;
- (void)loadDataComplete;

//
//返回按钮事件
- (void)backBtnHandler;
@end

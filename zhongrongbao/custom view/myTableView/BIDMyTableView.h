//
//  BIDMyTableView.h
//  商务厅
//
//  Created by mal on 13-12-16.
//  Copyright (c) 2013年 mal. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BIDPassValueDelegate.h"
#import "BIDCustomSpinnerView.h"
#import "BIDAppDelegate.h"
#import "BIDLoginViewController.h"

@protocol BIDMyTableViewDelegate <NSObject>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
@optional
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
@optional
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
@optional
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
@optional
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
@optional
- (void)startRefresh;
@optional
- (void)updateDataSource:(NSMutableArray*)arr;
@optional//当前tableView滚动到哪一行了
- (void)updateScrollRow:(NSIndexPath*)indexPath;

@end

@interface BIDMyTableView : UITableView<BIDPassValueDelegate>
{
    UIActivityIndicatorView *_pullDownRefreshSpinner;
    UILabel *_pullDownRefreshLabel;
    BOOL _pullDownRefreshing;
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

@property (strong, nonatomic) UIView *customHeaderView;
@property (strong, nonatomic) UIButton *headerBtn;

@property (strong, nonatomic)UIImageView *bgImgView;

@property BOOL bLoading;
@property BOOL bHasMore;
@property BOOL bDragging;
//是否是加载第一页的数据
@property BOOL bLoadFirstPageData;

//加载数据相关属性
@property (strong, nonatomic) NSString *strURL;
@property NSInteger type;
@property NSUInteger pageNumber;
@property NSUInteger pageNumberForSearch;
@property (strong, nonatomic) NSMutableArray *itemsArr;
@property (strong, nonatomic) NSMutableArray *heightArr;

//
@property (strong, nonatomic)BIDCustomSpinnerView *spinnerView;
//
@property (assign, nonatomic) id<BIDMyTableViewDelegate> myDelegate;
//
- (void)initView;
//分页加载
- (void)loadData;
- (void)firstLoadData;
- (void)commonLoadDataForPage;
- (void)loadDataComplete;

@end

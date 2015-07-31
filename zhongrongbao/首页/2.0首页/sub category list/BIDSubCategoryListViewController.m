//
//  BIDSubCategoryListViewController.m
//  zhongrongbao
//
//  Created by mal on 15/6/30.
//  Copyright (c) 2015年 cnsoft. All rights reserved.
//

#import "BIDSubCategoryListViewController.h"
#import "BIDTenderDetailViewControllerII.h"
#import "BIDSubCategoryHeaderView.h"
#import "BIDSubCategoryCollectionCell.h"
#import "BIDMyTableViewForHomePage.h"
#import "BIDTenderViewII.h"
#import "BIDTabBar.h"
#import "BIDTenderAmountView.h"
#import "BIDActivityListView.h"
#import "BIDWebPageJumpViewController.h"
#import "BIDOpenHFTXViewController.h"

/**
 *获取红包和体验金列表
 */
static NSString *getActivityList = @"ActivityUser/ActList.shtml";
/**
 *投标
 */
static NSString *strTenderURL = @"userInvest.shtml";
/**
 *查询客户汇付天下账户信息
 */
static NSString *strQueryUserAccountInfoURL = @"UserPay/PnrCount.shtml";
/**
 *某个标的当前可投金额
 */
static NSString *canInvestAmtForTenderURL = @"borrows/getCanInvestAmt.shtml";

@interface BIDSubCategoryListViewController ()<UITabBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate, BIDMyTableViewDelegate, BIDTenderViewIIDelegate, BIDTenderAmountViewDelegate, UIAlertViewDelegate>
{
    NSMutableArray *_dataSourceArr;
    BIDTabBar *_tabBar;
    UIScrollView *_scrollViewForTabBar;
    /**
     *category文字宽度
     */
    NSMutableArray *_categoryWidthArr;
    /**
     *category‘s font
     */
    UIFont *_categoryFont;
    /**
     *category font size
     */
    CGFloat _categoryFontSize;
    /**
     *
     */
    CGFloat _tableViewWidth;
    CGFloat _tableViewHeight;
    /**
     *
     */
    BIDSubCategoryHeaderView *_categoryHeaderView;
    /**
     *
     */
    int _selectIndex;
    UICollectionView *_collectionView;
    UIView *_underLine;
    BOOL _bRegister;
    //保存每个tableView内容的偏移
    NSMutableArray *_offsetArr;
    //
    BIDTenderAmountView *_tenderAmountView;
    BIDActivityListView *_activityListView;
    UIView *_maskView;
    //红包和体验金信息
    NSMutableDictionary *_activityInfoDic;
    //
    NSString *_tenderId;
}
@end

@implementation BIDSubCategoryListViewController
@synthesize categoryColor;
@synthesize categoryImg;
@synthesize subCategoryDictionary;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = self.subCategoryDictionary[@"name"];
    _dataSourceArr = [[NSMutableArray alloc] init];
    _offsetArr = [[NSMutableArray alloc] init];
    _activityInfoDic = [[NSMutableDictionary alloc] init];
    _selectIndex = 0;
    [BIDDataCommunication setCountPerPage:10];
    [self initData];
    [self initLayout];
    [self initUnderLine];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 * {"Head":{"channelType":"04","interfaceVersion":"1.0","funCode":"mobileIndex","sid":"6DB3C83DFCBCA9D2E1B56827BC435F3A"},"Body":{"pageInfo":{"pageNum": "13" },"param":{"group":"enterprise","sort":"02"}}}
 */

- (void)initData
{
    NSArray *arr = [subCategoryDictionary objectForKey:@"sort"];
    _categoryFontSize = 15.0f;
    _categoryFont = [UIFont fontWithName:@"Helvetica-Bold" size:_categoryFontSize];
    _categoryWidthArr = [[NSMutableArray alloc] initWithCapacity:arr.count];
    for(NSDictionary *dictionary in arr)
    {
        NSString *strCategory = [dictionary objectForKey:@"name"];
        CGFloat width = [BIDCommonMethods getWidthWithString:strCategory font:_categoryFont constraintSize:CGSizeMake(MAXFLOAT, 50)];
        NSNumber *value = [NSNumber numberWithFloat:width];
        [_categoryWidthArr addObject:value];
        //为每个分类的tableView创建数据源
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        [_dataSourceArr addObject:arr];
        //
        NSNumber *offsetValue = [NSNumber numberWithFloat:0.f];
        [_offsetArr addObject:offsetValue];
    }
}

- (void)initLayout
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat ownWidth = screenSize.width;
    CGFloat ownHeight = screenSize.height-64;
    //create tenderAmountView
    _tenderAmountView = (BIDTenderAmountView*)[[[NSBundle mainBundle] loadNibNamed:@"BIDTenderAmountView" owner:self options:nil] lastObject];
    _tenderAmountView.delegate = self;
    _tenderAmountView.center = CGPointMake(screenSize.width/2, screenSize.height/2);
    //
    _activityListView = [[BIDActivityListView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_tenderAmountView.frame), 0, CGRectGetWidth(_tenderAmountView.frame), 100)];
    _activityListView.delegate = (BIDTenderAmountView<BIDActivityListViewDelegate>*)_tenderAmountView;
    //
    _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
    [_maskView setBackgroundColor:[UIColor colorWithWhite:0.2f alpha:0.8f]];
    //
    NSInteger tabBarHeight = 35;
    NSArray *subCategoryArr = [subCategoryDictionary objectForKey:@"sort"];
    
    //create category header view
    _categoryHeaderView = (BIDSubCategoryHeaderView*)[[[NSBundle mainBundle] loadNibNamed:@"BIDSubCategoryHeaderView" owner:self options:nil] lastObject];
    _categoryHeaderView.headTitleLabel.text = [subCategoryDictionary objectForKey:@"name"];
    _categoryHeaderView.subTitleLabel.text = [subCategoryDictionary objectForKey:@"des"];
    _categoryHeaderView.categoryImgView.image = self.categoryImg;
    CGRect headerFrame = _categoryHeaderView.frame;
    headerFrame.origin.x = 0;
    headerFrame.origin.y = 0;
    _categoryHeaderView.frame = headerFrame;
    [_categoryHeaderView setBackgroundColor:categoryColor];
    [self.view addSubview:_categoryHeaderView];
    
    //create tabBar
    //_tabBar = [[BIDTabBar alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headerFrame), ownWidth, tabBarHeight)];
    _scrollViewForTabBar = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headerFrame), ownWidth, tabBarHeight)];
    //_scrollViewForTabBar.bounces = NO;
    _scrollViewForTabBar.showsHorizontalScrollIndicator = NO;
    _tabBar = [[BIDTabBar alloc] initWithFrame:CGRectMake(0, 0, ownWidth, tabBarHeight)];
    _tabBar.barTintColor = [UIColor whiteColor];
    int maxWidth = 0;
    NSMutableArray *tabBarItemArr = [[NSMutableArray alloc] initWithCapacity:subCategoryArr.count];
    for(NSUInteger i=0; i<subCategoryArr.count; i++)
    {
        NSDictionary *dictionary = subCategoryArr[i];
        NSString *strCategory = [dictionary objectForKey:@"name"];
        CGFloat categoryWidth = [BIDCommonMethods getWidthWithString:strCategory font:_categoryFont constraintSize:CGSizeMake(MAXFLOAT, tabBarHeight)];
        if(categoryWidth>maxWidth) maxWidth = categoryWidth;
        UITabBarItem *tabBarItem = [[UITabBarItem alloc] init];
        tabBarItem.tag = i;
        [tabBarItem setTitle:strCategory];
        UIColor *normalColor = [UIColor grayColor];
        UIColor *selectedColor = [UIColor colorWithRed:255.0f/255.0f green:57.0f/255.0f blue:66.0f/255.0f alpha:1.0f];
        NSDictionary *attributeDictionaryNormal = @{NSFontAttributeName:_categoryFont, NSForegroundColorAttributeName:normalColor};
        NSDictionary *attributeDictionarySelect = @{NSFontAttributeName:_categoryFont, NSForegroundColorAttributeName:selectedColor};
        [tabBarItem setTitleTextAttributes:attributeDictionaryNormal forState:UIControlStateNormal];
        [tabBarItem setTitleTextAttributes:attributeDictionarySelect forState:UIControlStateSelected];
        int textHeight = [BIDCommonMethods getHeightWithString:strCategory font:_categoryFont constraintSize:CGSizeMake(ownWidth, CGFLOAT_MAX)];
        CGFloat offsetY = -(tabBarHeight-textHeight)/2;
        [tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, offsetY)];
        [tabBarItemArr addObject:tabBarItem];
    }
    if(((20+maxWidth)*subCategoryArr.count)>ownWidth)
    {
        CGRect tabbarFrame = _tabBar.frame;
        tabbarFrame.size.width = (20+maxWidth)*subCategoryArr.count;
        _tabBar.frame = tabbarFrame;
        [_scrollViewForTabBar setContentSize:CGSizeMake((20+maxWidth)*subCategoryArr.count, tabBarHeight)];
    }
    else
    {
        [_scrollViewForTabBar setContentSize:CGSizeMake(ownWidth, tabBarHeight)];
    }
    //[_tabBar setBackgroundImage:[UIImage imageNamed:@"tabBarBg.png"]];
    [_tabBar setItems:tabBarItemArr];
    _tabBar.delegate = self;
    [_scrollViewForTabBar addSubview:_tabBar];
    [self.view addSubview:_scrollViewForTabBar];
    //[self.view addSubview:_tabBar];
    //
    _tableViewWidth = ownWidth;
    _tableViewHeight = ownHeight - CGRectGetHeight(_tabBar.frame) - CGRectGetHeight(headerFrame);
    //create collectionView
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setMinimumInteritemSpacing:0.0f];
    [flowLayout setMinimumLineSpacing:0.f];
    [flowLayout setItemSize:CGSizeMake(ownWidth, ownHeight-tabBarHeight-CGRectGetHeight(headerFrame))];
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_scrollViewForTabBar.frame), ownWidth, ownHeight-tabBarHeight-CGRectGetHeight(headerFrame)) collectionViewLayout:flowLayout];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.bounces = NO;
    [self.view addSubview:_collectionView];
    //
}
/**
 *UITabBarItem被选中时，该项下对应的横线
 */
- (void)initUnderLine
{
    CGFloat lineHeight = 2.0f;
    CGFloat lineWidth = 10.0f;
    _underLine = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_scrollViewForTabBar.frame)-lineHeight, lineWidth, lineHeight)];
    [_underLine setBackgroundColor:[UIColor colorWithRed:255.0f/255.0f green:57.0f/255.0f blue:66.0f/255.0f alpha:1.0f]];
    NSArray *items = _tabBar.items;
    [_tabBar setSelectedItem:items[0]];
    CGFloat posX = [self calculateUnderLinePosX:0];
    NSNumber *value = _categoryWidthArr[0];
    CGRect frame = _underLine.frame;
    frame.origin.x = posX;
    frame.size.width = [value floatValue];
    _underLine.frame = frame;
    //[self.view addSubview:_underLine];
    [_scrollViewForTabBar addSubview:_underLine];
}
/**
 *计算tabBarItem对应横线的长度
 */
- (CGFloat)calculateUnderLinePosX:(NSUInteger)index
{
    NSArray *arr = self.subCategoryDictionary[@"sort"];
    CGFloat average = _scrollViewForTabBar.contentSize.width/arr.count;
    NSNumber *value = _categoryWidthArr[index];
    CGFloat posX = index * average + (average-[value floatValue])/2;
    return posX;
}

#pragma mark -UITabBarDelegate
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    CGFloat posX = [self calculateUnderLinePosX:item.tag];
    NSNumber *value = _categoryWidthArr[item.tag];
    CGRect frame = _underLine.frame;
    frame.origin.x = posX;
    frame.size.width = [value floatValue];
    _underLine.frame = frame;
    //
    _selectIndex = item.tag;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:item.tag inSection:0];
    [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}

#pragma mark -UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(![scrollView isKindOfClass:[UICollectionView class]]) return;
    CGFloat pageWidth = scrollView.frame.size.width;
    NSInteger page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    UITabBarItem *item = _tabBar.selectedItem;
    if(item.tag!=page)
    {
        _selectIndex = page;
        NSArray *items = _tabBar.items;
        [_tabBar setSelectedItem:items[page]];
        //
        CGFloat posX = [self calculateUnderLinePosX:page];
        NSNumber *value = _categoryWidthArr[page];
        CGRect frame = _underLine.frame;
        frame.origin.x = posX;
        frame.size.width = [value floatValue];
        _underLine.frame = frame;
        //
        UICollectionView *tempView = (UICollectionView*)scrollView;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:page inSection:0];
        UICollectionViewCell *tempCell = [tempView cellForItemAtIndexPath:indexPath];
        BIDMyTableViewForHomePage *tempTableView = (BIDMyTableViewForHomePage*)[tempCell.contentView viewWithTag:100];
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
    NSArray *arr = self.subCategoryDictionary[@"sort"];
    return arr.count;
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
    NSArray *infoArr = self.subCategoryDictionary[@"sort"];
    NSDictionary *info = infoArr[row];
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    BIDMyTableViewForHomePage *tableView = (BIDMyTableViewForHomePage*)[cell.contentView viewWithTag:100];
    if(!tableView)
    {
        tableView = [[BIDMyTableViewForHomePage alloc] initWithFrame:CGRectMake(0, 0, _tableViewWidth, _tableViewHeight)];
        tableView.tag = 100;
        tableView.myDelegate = self;
        [tableView setBackgroundColor:[UIColor colorWithRed:244.0f/255.0f green:244.0f/255.0f blue:244.0f/255.0f alpha:1.0f]];
        [cell.contentView addSubview:tableView];
    }
    tableView.strURL = [BIDAppDelegate SERVER_ADDR];
    tableView.param1 = self.subCategoryDictionary[@"id"];
    tableView.param2 = info[@"id"];
    NSArray *dataSource = _dataSourceArr[row];
    if(!dataSource || dataSource.count==0)
    {
        if(!collectionView.dragging && !collectionView.decelerating)
        {
            [tableView firstLoadData];
        }
    }
    else
    {
        [tableView.itemsArr setArray:dataSource];
        [tableView reloadData];
        //
        NSNumber *offsetValue = _offsetArr[indexPath.row];
        tableView.contentOffset = CGPointMake(0, [offsetValue floatValue]);
    }
    cell.contentView.autoresizesSubviews = NO;
    return cell;
}

//显示投标视图
- (void)showTenderAmountView
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:_maskView];
    [keyWindow addSubview:_tenderAmountView];
}
//移除投标视图
- (void)hideTenderAmountView
{
    [_maskView removeFromSuperview];
    [_tenderAmountView removeFromSuperview];
}

#pragma mark - BIDTenderViewIIDelegate
//当标的状态为投标中，才可以投标
- (void)toTenderAtIndex:(NSUInteger)index
{
    NSLog(@"%d", index);
    NSMutableArray *desArr = _dataSourceArr[_selectIndex];
    NSDictionary *dic = desArr[index];
    NSString *strStatus = dic[@"borrowStatus"];
    BIDTenderDetailViewControllerII *vc = [[BIDTenderDetailViewControllerII alloc] initWithNibName:@"BIDTenderDetailViewControllerII" bundle:nil];
    if(![strStatus isEqualToString:@"02"])
    {
        vc.tenderId = dic[@"bid"];
        NSString *strStatus = dic[@"borrowStatus"];
        if([strStatus isEqualToString:@"01"] || [strStatus isEqualToString:@"07"])
        {
            vc.bShowOpenTime = YES;
            vc.openTime = [[NSString alloc] initWithFormat:@"开标时间:%@", dic[@"openTime"]];
        }
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    _tenderId = dic[@"bid"];
    if(![BIDAppDelegate isHaveLogin])
    {
        //未登录,则提示需要登录才能投标，是否登录
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"登录后才可以继续操作，是否登录" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
        alertView.tag = 0;
        [alertView show];
    }
    else
    {
        NSString *strBidType = dic[@"bidType"];
        if([strBidType isEqualToString:@"01"])
        {
            //团体标需要显示密码
            [_tenderAmountView showOrHidePasswordOption:YES];
        }
        else
        {
            [_tenderAmountView showOrHidePasswordOption:NO];
        }
        //
        [self.spinnerView showTheView];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            int state = [BIDCommonMethods isHaveRegisterHFTX];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.spinnerView dismissTheView];
                if(state==2)
                {
                    NSMutableDictionary *userAmtInfoDictionary = [[NSMutableDictionary alloc] init];
                    NSMutableDictionary *tenderInfoDic = [[NSMutableDictionary alloc] init];
                    NSString *strUserAmtInfoURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strQueryUserAccountInfoURL];
                    NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], getActivityList];
                    NSString *strCanInvestAmtURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], canInvestAmtForTenderURL];
                    NSString *strPost = [[NSString alloc] initWithFormat:@"jsonDataSet={\"bid\":\"%@\"}", _tenderId];
                    [self.spinnerView showTheView];
                    __block int rev = 0;
                    dispatch_group_t group = dispatch_group_create();
                    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
                        //获取用户汇付信息
                        [BIDDataCommunication getDataFromNet:strUserAmtInfoURL toDictionary:userAmtInfoDictionary];
                    });
                    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
                        rev = [BIDDataCommunication uploadDataByPostWithoutCookie:strCanInvestAmtURL postValue:strPost toDictionary:tenderInfoDic];
                    });
                    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
                        //获取活动列表(红包、体验金)
                        rev = [BIDDataCommunication getDataFromNet:strURL toDictionary:_activityInfoDic];
                    });
                    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
                        //
                        [self.spinnerView dismissTheView];
                        //获取可用余额
                        NSString *strLeftAmt = @"0.0";
                        if([[userAmtInfoDictionary objectForKey:@"json"] isEqualToString:@"success"])
                        {
                            NSDictionary *subDic = userAmtInfoDictionary[@"data"];
                            if([[subDic objectForKey:@"pnrStatus"] isEqualToString:@"N"])
                            {
                                //未注册
                                strLeftAmt = @"0.0";
                            }
                            else
                            {
                                //
                                CGFloat availableAmt = [[subDic objectForKey:@"avaiableAmt"] floatValue];
                                strLeftAmt = [[NSString alloc] initWithFormat:@"%.2f", availableAmt];
                                //为投标视图赋值账户余额
                                _tenderAmountView.leftAmount = [strLeftAmt floatValue];
                            }
                        }
                        //
                        if([[tenderInfoDic objectForKey:@"json"] isEqualToString:@"success"])
                        {
                            NSNumber *canInvestAmtValue = tenderInfoDic[@"data"];
                            _tenderAmountView.canInvestAmt = [canInvestAmtValue floatValue];
                        }
                        //
                        if(rev==1)
                        {
                            if([_activityInfoDic[@"json"] isEqualToString:@"success"])
                            {
                                NSArray *arr = _activityInfoDic[@"dataList0"];
                                if(arr.count>0)
                                {
                                    [_tenderAmountView showOrHideRedPacketOption:YES];
                                }
                                else
                                {
                                    [_tenderAmountView showOrHideRedPacketOption:NO];
                                }
                                arr = _activityInfoDic[@"dataList1"];
                                if(arr.count>0)
                                {
                                    [_tenderAmountView showOrHideTiYanJinOption:YES];
                                }
                                else
                                {
                                    [_tenderAmountView showOrHideTiYanJinOption:NO];
                                }
                            }
                            else
                            {
                                [_tenderAmountView showOrHideRedPacketOption:NO];
                                [_tenderAmountView showOrHideTiYanJinOption:NO];
                            }
                        }
                        else
                        {
                            [_tenderAmountView showOrHideRedPacketOption:NO];
                            [_tenderAmountView showOrHideTiYanJinOption:NO];
                        }
                        [self showTenderAmountView];
                    });
                }
                else
                {
                    if(state==0)
                    {
                        [BIDCommonMethods showAlertView:@"请求失败" buttonTitle:@"关闭" delegate:nil tag:0];
                    }
                    else if(state==1)
                    {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"注册汇付天下后才可以继续操作，是否注册" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
                        alertView.tag = 1;
                        [alertView show];
                    }
                    else if(state==3)
                    {
                        [BIDCommonMethods showAlertView:err_msg buttonTitle:@"关闭" delegate:self tag:2];
                    }
                }
            });
        });
    }
}
#pragma mark - BIDTenderAmountViewDelegate
- (void)toTenderWithAmount:(NSString *)strAmount password:(NSString *)strPwd activityId:(NSString *)strActivityIds
{
    [self hideTenderAmountView];
    //已登录
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strTenderURL];
    NSString *strPost = @"";
    {
        //strPost = [[NSString alloc] initWithFormat:@"jsonDataSet={\"bid\":\"%@\", \"transAmt\":\"%@\", \"retUtlType\":\"ios\"}", _tenderId, strAmount];
        strPost = [[NSString alloc] initWithFormat:@"jsonDataSet={\"bid\":\"%@\", \"investAmt\":\"%@\", \"investPwd\":\"%@\", \"activityIds\":%@}", _tenderId, strAmount, strPwd, strActivityIds];
    }
    [self.spinnerView showTheView];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        {
            int rev = [BIDDataCommunication uploadDataByPostToURL:strURL postValue:strPost toDictionary:dictionary];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.spinnerView dismissTheView];
                if(rev==1)
                {
                    if([[dictionary objectForKey:@"json"] isEqualToString:@"success"])
                    {
                        NSString *strDesURL = [dictionary objectForKey:@"data"][@"investUrl"];
                        BIDWebPageJumpViewController *vc = [[BIDWebPageJumpViewController alloc] initWithNibName:@"BIDWebPageJumpViewController" bundle:nil];
                        vc.desURL = strDesURL;
                        [self.navigationController pushViewController:vc animated:YES];
                    }
                    else
                    {
                        [BIDCommonMethods showAlertView:[dictionary objectForKey:@"message"] buttonTitle:@"关闭" delegate:nil tag:0];
                    }
                }
                else if(rev==2)
                {
                    [BIDCommonMethods showAlertView:err_msg buttonTitle:@"关闭" delegate:self tag:2];
                }
                else
                {
                    [BIDCommonMethods showAlertView:@"请求失败" buttonTitle:@"关闭" delegate:nil tag:0];
                }
            });
        }
    });
}
//取消投标
- (void)cancelTender
{
    [_maskView removeFromSuperview];
}

//显示活动列表
- (void)showActivityList:(CGRect)frame type:(int)type
{
    [_activityListView removeFromSuperview];
    CGRect frame1 = _tenderAmountView.frame;
    CGFloat posY = CGRectGetMinY(frame1) + CGRectGetMinY(frame) + CGRectGetHeight(frame);
    CGRect activityListViewFrame = _activityListView.frame;
    if(type==1)
    {
        //红包
        _activityListView.activityType = ACTIVITY_REDPACKET;
        [_activityListView setDataSourceArr:_activityInfoDic[@"dataList0"]];
    }
    else if(type==2)
    {
        //体验金
        _activityListView.activityType = ACTIVITY_TIYANJIN;
        [_activityListView setDataSourceArr:_activityInfoDic[@"dataList1"]];
    }
    activityListViewFrame.origin.y = posY;
    _activityListView.frame = activityListViewFrame;
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:_activityListView];
}

#pragma mark -UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)
    {
        if(alertView.tag==0)
        {
            BIDLoginViewController *loginVC = nil;
            //登录
            if(IPHONE4OR4S)
            {
                loginVC = [[BIDLoginViewController alloc] initWithNibName:@"BIDLoginViewController" bundle:nil];
            }
            else
            {
                loginVC = [[BIDLoginViewController alloc] initWithNibName:@"BIDLoginViewController2" bundle:nil];
            }
            [self.navigationController setViewControllers:@[loginVC] animated:YES];
        }
        else
        {
            //开通汇付天下
            BIDOpenHFTXViewController *vc = [[BIDOpenHFTXViewController alloc] initWithNibName:@"BIDOpenHFTXViewController" bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else
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
}

#pragma mark - BIDMyTableViewDelegate
- (void)updateDataSource:(NSMutableArray *)arr
{
    NSMutableArray *desArr = _dataSourceArr[_selectIndex];
    [desArr setArray:arr];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //NSArray *arr = _dataSourceArr[_selectIndex];
    //return arr.count;
    return ((BIDMyTableViewForHomePage*)tableView).itemsArr.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BIDMyTableViewForHomePage *tableView1 = (BIDMyTableViewForHomePage*)tableView;
    UITableViewCell *cell = nil;
    static NSString *identifier = @"identifier";
    NSUInteger row = indexPath.row;
    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    BIDTenderViewII *tenderView = (BIDTenderViewII*)[cell.contentView viewWithTag:100];
    if(!tenderView)
    {
        tenderView = (BIDTenderViewII*)[[[NSBundle mainBundle] loadNibNamed:@"BIDTenderViewII" owner:self options:nil] lastObject];
        CGRect tenderViewFrame = tenderView.frame;
        tenderViewFrame.origin.x = 10;
        tenderViewFrame.origin.y = 10;
        tenderView.frame = tenderViewFrame;
        tenderView.tag = 100;
        [cell.contentView addSubview:tenderView];
    }
    tenderView.delegate = self;
    tenderView.row = indexPath.row;
    //替换tableView内容的偏移
    NSNumber *offsetValue = [NSNumber numberWithFloat:tableView.contentOffset.y];
    [_offsetArr replaceObjectAtIndex:_selectIndex withObject:offsetValue];
    //
    NSDictionary *dictionary = tableView1.itemsArr[row];
    NSString *strBidType = dictionary[@"bidType"];
    if([strBidType isEqualToString:@"02"])
    {
        //新手标
        [tenderView.flagLabel setText:@"新手标"];
        [tenderView.flagLabel setBackgroundColor:[UIColor colorWithRed:255.0f/255.0f green:57.0f/255.0f blue:66.0f/255.0f alpha:1.0f]];
        tenderView.flagLabel.hidden = NO;
    }
    else
    {
        tenderView.flagLabel.hidden = YES;
    }
    NSString *strStatus = dictionary[@"borrowStatus"];
    if([strStatus isEqualToString:@"02"])
    {
        //显示投标进度
        NSString *strProgress = [[NSString alloc] initWithFormat:@"进度%@%%", dictionary[@"progress"]];
        NSNumber *progressValue = dictionary[@"progress"];
        if([progressValue floatValue]<100)
        {
            [tenderView.flagLabel setBackgroundColor:[UIColor colorWithRed:255.0f/255.0f green:57.0f/255.0f blue:66.0f/255.0f alpha:1.0f]];
        }
        else
        {
            [tenderView.flagLabel setBackgroundColor:[UIColor colorWithRed:38.0f/255.0f green:156.0f/255.0f blue:248.0f/255.0f alpha:1.0f]];
        }
        tenderView.flagLabel.hidden = NO;
        tenderView.flagLabel.text = strProgress;
        //
        [tenderView setLabelStatus:STATUS_TENDERRING text:@""];
    }
    else if([strStatus isEqualToString:@"03"])
    {
        [tenderView setLabelStatus:STATUS_FULL text:@""];
    }
    else if([strStatus isEqualToString:@"04"])
    {
        [tenderView setLabelStatus:STATUS_REPAY text:@""];
    }
    else if([strStatus isEqualToString:@"05"])
    {
        [tenderView setLabelStatus:STATUS_REPAID text:@""];
    }
    else if([strStatus isEqualToString:@"01"] || [strStatus isEqualToString:@"07"])
    {
        [tenderView setLabelStatus:STATUS_READY text:[[NSString alloc] initWithFormat:@"开标时间:%@", dictionary[@"openTime"]]];
    }
    else if([strStatus isEqualToString:@"06"])
    {
        [tenderView setLabelStatus:STATUS_LIUBIAO text:@""];
    }
    else if([strStatus isEqualToString:@"99"])
    {
        [tenderView setLabelStatus:STATUS_DISCARD text:@""];
    }
    //借款类型
    /**
     *01融抵押；02融担保；03融小贷；04融保理；05融车宝’06融房贷；07融特色
     */
    NSString *strBorrowType = dictionary[@"borrowType"];
    if([strBorrowType isEqualToString:@"01"]) strBorrowType = @"融抵押";
    else if([strBorrowType isEqualToString:@"02"]) strBorrowType = @"融担保";
    else if([strBorrowType isEqualToString:@"03"]) strBorrowType = @"融小贷";
    else if([strBorrowType isEqualToString:@"04"]) strBorrowType = @"融保理";
    else if([strBorrowType isEqualToString:@"05"]) strBorrowType = @"融车宝";
    else if([strBorrowType isEqualToString:@"06"]) strBorrowType = @"融房贷";
    else if([strBorrowType isEqualToString:@"07"]) strBorrowType = @"融特色";
    tenderView.borrowNameLabel.text = [[NSString alloc] initWithFormat:@"%@·%@", strBorrowType, dictionary[@"borrowName"]];
    NSNumber *value = dictionary[@"borrowAmtWanyuan"];
    tenderView.borrowAmtLabel.text = [[NSString alloc] initWithFormat:@"%@", value];
    value = dictionary[@"deadline"];
    tenderView.deadLineLabel.text = [[NSString alloc] initWithFormat:@"%d", [value intValue]];
    value = dictionary[@"yearRate"];
    tenderView.yearRateLabel.text = [[NSString alloc] initWithFormat:@"%@", value];
    cell.contentView.autoresizesSubviews = NO;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BIDMyTableViewForHomePage *tableView1 = (BIDMyTableViewForHomePage*)tableView;
    BIDTenderDetailViewControllerII *vc = [[BIDTenderDetailViewControllerII alloc] initWithNibName:@"BIDTenderDetailViewControllerII" bundle:nil];
    NSDictionary *dictionary = tableView1.itemsArr[indexPath.row];
    vc.tenderId = dictionary[@"bid"];
    NSString *strStatus = dictionary[@"borrowStatus"];
    if([strStatus isEqualToString:@"02"])
    {
        vc.bCanInvest = YES;
    }
    else
    {
        vc.bCanInvest = NO;
    }
    if([strStatus isEqualToString:@"01"] || [strStatus isEqualToString:@"07"])
    {
        vc.bShowOpenTime = YES;
        vc.openTime = [[NSString alloc] initWithFormat:@"开标时间:%@", dictionary[@"openTime"]];
    }
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 201;
}

@end

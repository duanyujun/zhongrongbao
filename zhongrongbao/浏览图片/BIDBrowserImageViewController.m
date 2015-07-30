//
//  BIDBrowserImageViewController.m
//  zhongrongbao
//
//  Created by mal on 15/7/3.
//  Copyright (c) 2015年 cnsoft. All rights reserved.
//

#import "BIDBrowserImageViewController.h"
#import "BIDPreviewImgView.h"
#import "BIDImgDownloader.h"
#import "BIDCollectionViewCell.h"
#import "BIDScrollViewWithImage.h"
#import "BIDNode.h"

@interface BIDBrowserImageViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>
{
    /**
     *导航栏的titleView
     */
    UIView *_titleViewForNav;
    //
    UICollectionView *_collectionView;
    //图片分类
    UILabel *_imgCategoryLabel;
    int _imgCategoryLabelHeight;
    NSMutableDictionary *_imgDownloadInProgress;
    BOOL _bRegister;
}
@end

@implementation BIDBrowserImageViewController
@synthesize nodeArr;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _imgCategoryLabelHeight = 44.0f;
    self.view.backgroundColor = [UIColor blackColor];
    [self createOtherView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self terminateAllDownloads];
}

- (void)createOtherView
{
    _titleViewForNav = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 22)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_titleViewForNav.frame), CGRectGetHeight(_titleViewForNav.frame))];
    label.tag = 1;
    [label setFont:[UIFont systemFontOfSize:22.0f]];
    [label setTextColor:[UIColor whiteColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setText:[[NSString alloc] initWithFormat:@"1 of %d", nodeArr.count]];
    [_titleViewForNav addSubview:label];
    self.navigationItem.titleView = _titleViewForNav;
    //create collectionView
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat ownWidth = screenSize.width;
    CGFloat ownHeight = screenSize.height;
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setMinimumInteritemSpacing:0.0f];
    [flowLayout setMinimumLineSpacing:0.f];
    [flowLayout setItemSize:CGSizeMake(ownWidth, ownHeight-64-_imgCategoryLabelHeight)];
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, ownWidth, ownHeight-64-_imgCategoryLabelHeight) collectionViewLayout:flowLayout];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.bounces = NO;
    [self.view addSubview:_collectionView];
    //用来描述图片所属分类
    _imgCategoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, ownHeight-64-_imgCategoryLabelHeight, ownWidth, _imgCategoryLabelHeight)];
    [_imgCategoryLabel setFont:[UIFont systemFontOfSize:17.0f]];
    [_imgCategoryLabel setTextColor:[UIColor whiteColor]];
    [_imgCategoryLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:_imgCategoryLabel];
}

- (void)startIconDownload:(BIDNode *)node forIndexPath:(NSIndexPath *)indexPath
{
    BIDImgDownloader *imgDownloader = (_imgDownloadInProgress)[indexPath];
    if (imgDownloader == nil)
    {
        imgDownloader = [[BIDImgDownloader alloc] init];
        imgDownloader.node = node;
        [imgDownloader setCompletionHandler:^{
            
            UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:indexPath];
            BIDPreviewImgView *previewImgView = (BIDPreviewImgView*)[cell.contentView viewWithTag:100];
            [previewImgView.spinnerView stopAnimating];
            BIDScrollViewWithImage *scrollViewWithImg = previewImgView.scrollViewWithImg;
            scrollViewWithImg.imgView.image = node.img;
            // Display the newly loaded image
            // Remove the IconDownloader from the in progress list.
            // This will result in it being deallocated.
            [_imgDownloadInProgress removeObjectForKey:indexPath];
            
        }];
        (_imgDownloadInProgress)[indexPath] = imgDownloader;
        [imgDownloader startDownload];
    }
}
// -------------------------------------------------------------------------------
//	terminateAllDownloads
// -------------------------------------------------------------------------------
- (void)terminateAllDownloads
{
    // terminate all pending download connections
    NSArray *allDownloads = [_imgDownloadInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    [_imgDownloadInProgress removeAllObjects];
}

#pragma mark -UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(![scrollView isKindOfClass:[UICollectionView class]]) return;
    CGFloat pageWidth = scrollView.frame.size.width;
    NSInteger page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    UILabel *label = (UILabel*)[_titleViewForNav viewWithTag:1];
    [label setText:[[NSString alloc] initWithFormat:@"%d of %d", page+1, nodeArr.count]];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return nodeArr.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    NSUInteger row = indexPath.row;
    static NSString *identifier = @"identifier";
    if(!_bRegister)
    {
        _bRegister = YES;
        [collectionView registerClass:[BIDCollectionViewCell class] forCellWithReuseIdentifier:identifier];
    }
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    BIDPreviewImgView *preview = (BIDPreviewImgView*)[cell.contentView viewWithTag:100];
    if(!preview)
    {
        preview = [[BIDPreviewImgView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(collectionView.frame), CGRectGetHeight(collectionView.frame))];
        preview.tag = 100;
        [cell.contentView addSubview:preview];
    }
    [preview.scrollViewWithImg setZoomScale:1.0f];
    BIDNode *node = nodeArr[row];
    if(!node.img)
    {
        preview.scrollViewWithImg.imgView.image = [UIImage imageNamed:@""];
        [self startIconDownload:node forIndexPath:indexPath];
    }
    else
    {
        preview.scrollViewWithImg.imgView.image = node.img;
    }
    _imgCategoryLabel.text = node.imgTypeName;
    return cell;
}

@end

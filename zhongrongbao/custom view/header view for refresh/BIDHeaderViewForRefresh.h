//
//  BIDHeaderViewForRefresh.h
//  shandongshangbao
//
//  Created by mal on 14/12/22.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BIDHeaderViewForRefresh : UIView
{
    IBOutlet UIActivityIndicatorView *_spinnerView;
    IBOutlet UILabel *_hintLabel;
}

//@property (strong, nonatomic) UIActivityIndicatorView *spinnerView;
//@property (strong, nonatomic) UILabel *hintLabel;
- (void)readyRefresh;
- (void)canRefresh;
- (void)isRefreshing;
- (void)completeRefresh;

@end

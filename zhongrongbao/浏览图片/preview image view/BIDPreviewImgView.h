//
//  BIDPreviewImgView.h
//  zhongrongbao
//
//  Created by mal on 15/7/3.
//  Copyright (c) 2015年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BIDScrollViewWithImage;

@interface BIDPreviewImgView : UIView

@property (strong, nonatomic) BIDScrollViewWithImage *scrollViewWithImg;

@property (strong, nonatomic) UIActivityIndicatorView *spinnerView;

@end

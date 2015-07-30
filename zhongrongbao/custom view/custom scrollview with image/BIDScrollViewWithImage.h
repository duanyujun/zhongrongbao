//
//  BIDScrollViewWithImage.h
//  shangwuting
//
//  Created by mal on 14-6-30.
//  Copyright (c) 2014年 mal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BIDScrollViewWithImage : UIScrollView<UIScrollViewDelegate>

@property (strong, nonatomic)UIImageView *imgView;

@property (strong, nonatomic)UIImage *image;
   
@end

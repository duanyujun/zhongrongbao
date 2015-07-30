//
//  BIDCustomSpinnerView.h
//  Nav
//
//  Created by mal on 13-11-1.
//  Copyright (c) 2013年 mal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BIDCustomSpinnerView : UIView

@property (strong, nonatomic)UIActivityIndicatorView *spinner;
@property (strong, nonatomic)UILabel *label;
@property (copy, nonatomic) NSString *content;

@property (strong, nonatomic) UIView *bgView;

- (void)initLayout;
- (void)showTheView;
- (void)dismissTheView;
@end

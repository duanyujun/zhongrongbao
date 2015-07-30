//
//  BIDYearAndMonthView.h
//  shangwuting
//
//  Created by mal on 14-2-11.
//  Copyright (c) 2014年 mal. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BIDYearAndMonthViewDelegate <NSObject>

- (void)getChoosedDate:(NSString*)choosedDate;

@end

@interface BIDYearAndMonthView : UIView<UIPickerViewDataSource, UIPickerViewDelegate>
@property (strong, nonatomic)UIImageView *bgView;
@property (strong, nonatomic)UIPickerView *myPicker;
@property (strong, nonatomic)UIToolbar *myToolbar;
@property (strong, nonatomic)NSMutableArray *yearArr;
@property (strong, nonatomic)NSArray *monthArr;
@property (assign, nonatomic)BOOL bShow;
@property (strong, nonatomic)NSObject<BIDYearAndMonthViewDelegate> *delegate;

- (void)initView;

- (void)confirmBtnHandler;
- (void)cancelBtnHandler;

- (void)showView;
- (void)dismissView;

@end

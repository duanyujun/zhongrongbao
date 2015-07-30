//
//  BIDAccountSectionView.h
//  zhongrongbao
//
//  Created by mal on 14-8-26.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BIDAccountSectionViewDelegate <NSObject>

- (void)refreshSectionView:(CGFloat)sectionViewHeight;

@end

@interface BIDAccountSectionView : UIView
{
    IBOutlet UILabel *_flagLabel1;
    IBOutlet UILabel *_flagLabel2;
    IBOutlet UILabel *_flagLabel3;
    IBOutlet UILabel *_flagLabel4;
    IBOutlet UILabel *_lineLabel;
    IBOutlet UILabel *_monthLabel;
    IBOutlet UIView *_flagView;
    IBOutlet UIButton *_leftBtn;
    IBOutlet UILabel *_leftBtnLabel;
    IBOutlet UILabel *_rightBtnLabel;
    IBOutlet UIButton *_rightBtn;
    IBOutlet UILabel *_dateLabel;
    
    int _curMonth;
    int _curYear;
    int _trueMonth;
    int _trueYear;
}

/**
 *用来保存组成日历的label
 */
@property (strong, nonatomic) NSMutableArray *labelArr;

- (void)initView;

/**
 *设置日期对应的背景颜色
 */
- (void)setLabelToCorrespondingBgColor;

- (IBAction)leftBtnHandler:(id)sender;
- (IBAction)rightBtnHandler:(id)sender;

@property (assign, nonatomic) id<BIDAccountSectionViewDelegate> delegate;

@end

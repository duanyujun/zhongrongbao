//
//  BIDCategoryCell.h
//  zhongrongbao
//
//  Created by mal on 15/6/25.
//  Copyright (c) 2015年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BIDCategoryCell : UITableViewCell

/**
 *大标题
 */
@property (strong, nonatomic) IBOutlet UILabel *headTitleLabel;
/**
 *小标题
 */
@property (strong, nonatomic) IBOutlet UILabel *subTitleLabel;
/**
 *图片
 */
@property (strong, nonatomic) IBOutlet UIImageView *categoryImgView;
//cell背景色
@property (assign, nonatomic) UIColor *bgColor;

@end

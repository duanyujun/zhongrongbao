//
//  BIDSubCategoryListViewController.h
//  zhongrongbao
//
//  Created by mal on 15/6/30.
//  Copyright (c) 2015年 cnsoft. All rights reserved.
//

#import "BIDBaseViewController.h"

@interface BIDSubCategoryListViewController : BIDBaseViewController

/**
 *子分类的颜色、图片
 */
@property (assign, nonatomic) UIColor *categoryColor;
@property (strong, nonatomic) UIImage *categoryImg;
/**
 *子分类信息
 */
@property (copy, nonatomic) NSDictionary *subCategoryDictionary;

@end

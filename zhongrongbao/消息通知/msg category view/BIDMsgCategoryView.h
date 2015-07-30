//
//  BIDMsgCategoryView.h
//  zhongrongbao
//
//  Created by mal on 14/12/26.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BIDMsgCategoryViewDelegate <NSObject>

- (void)chooseCategoryWithIndex:(NSInteger)index;

@end

@interface BIDMsgCategoryView : UIView

@property (assign, nonatomic) id<BIDMsgCategoryViewDelegate> delegate;

- (void)changeStateByIndex:(NSInteger)index;

@end

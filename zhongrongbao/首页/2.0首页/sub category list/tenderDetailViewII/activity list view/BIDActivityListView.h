//
//  BIDActivityListView.h
//  zhongrongbao
//
//  Created by mal on 15/7/13.
//  Copyright (c) 2015年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BIDActivityListViewDelegate <NSObject>
//红包
- (void)selectActivityForRedPacketWithName:(NSString*)actName activityId:(NSString*)activityId;
//体验金
- (void)selectActivityForTiYanJinWithName:(NSString*)actName activityId:(NSString*)activityId;

@end

@interface BIDActivityListView : UIView

@property (assign, nonatomic) id<BIDActivityListViewDelegate> delegate;

@property (assign, nonatomic) ACTIVITY_TYPE activityType;

- (void)setDataSourceArr:(NSArray*)arr;

@end

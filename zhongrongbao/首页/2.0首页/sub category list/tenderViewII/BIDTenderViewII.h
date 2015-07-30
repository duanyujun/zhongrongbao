//
//  BIDTenderViewII.h
//  zhongrongbao
//
//  Created by mal on 15/6/30.
//  Copyright (c) 2015年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BIDTenderViewIIDelegate <NSObject>

- (void)toTenderAtIndex:(NSUInteger)index;

@end

@interface BIDTenderViewII : UIView

@property (strong, nonatomic) IBOutlet UILabel *borrowNameLabel;
/**
 *新手标才显示
 */
@property (strong, nonatomic) IBOutlet UILabel *flagLabel;
@property (strong, nonatomic) IBOutlet UILabel *borrowAmtLabel;
@property (strong, nonatomic) IBOutlet UILabel *yearRateLabel;
@property (strong, nonatomic) IBOutlet UILabel *deadLineLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;

@property (assign, nonatomic) NSUInteger row;
@property (assign, nonatomic) id<BIDTenderViewIIDelegate> delegate;

- (void)setLabelStatus:(TENDER_STATUS)tenderStatus text:(NSString*)statusText;


@end

//
//  BIDBankCardInfoView.h
//  zhongrongbao
//
//  Created by mal on 15/6/28.
//  Copyright (c) 2015年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BIDBankCardInfoViewDelegate <NSObject>

- (void)removeBinding:(int)row;

@end

@interface BIDBankCardInfoView : UIView

@property (strong, nonatomic) IBOutlet UIImageView *bankImgView;

@property (strong, nonatomic) IBOutlet UIButton *removeBindingBtn;

@property (strong, nonatomic) IBOutlet UILabel *bankCardNumberLabel;

@property (assign, nonatomic) int row;

@property (assign, nonatomic) id<BIDBankCardInfoViewDelegate> delegate;

@end

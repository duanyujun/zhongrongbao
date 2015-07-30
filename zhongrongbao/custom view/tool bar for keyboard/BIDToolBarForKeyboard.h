//
//  BIDToolBarForKeyboard.h
//  zhongrongbao
//
//  Created by mal on 15/7/5.
//  Copyright (c) 2015年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BIDToolBarForKeyboardDelegate <NSObject>

- (void)closeKeyboard;

@end

@interface BIDToolBarForKeyboard : UIToolbar

@property (assign, nonatomic) id<BIDToolBarForKeyboardDelegate> myDelegate;

+ (id)getToolBarInstance;

@end

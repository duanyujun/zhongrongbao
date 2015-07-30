//
//  BIDSetPortraitViewController.h
//  mashangban
//
//  Created by mal on 14-8-25.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BIDSetPortraitViewControllerDelegate <NSObject>

- (void)finishCropImage:(UIImage*)img viewController:(UIViewController*)viewController;

@end

@interface BIDSetPortraitViewController : UIViewController
{
    UIImage *_originImg;
    UIImageView *_imgView;
}

@property (assign, nonatomic) id<BIDSetPortraitViewControllerDelegate> delegate;

- (id)initWithImage:(UIImage*)originImg;

@end

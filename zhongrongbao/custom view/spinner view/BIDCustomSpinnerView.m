//
//  BIDCustomSpinnerView.m
//  Nav
//
//  Created by mal on 13-11-1.
//  Copyright (c) 2013年 mal. All rights reserved.
//

#import "BIDCustomSpinnerView.h"
#import "BIDAppDelegate.h"

@implementation BIDCustomSpinnerView

@synthesize spinner;
@synthesize label;
@synthesize content;

@synthesize bgView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //[self initLayout];
    }
    return self;
}

- (id)init
{
    if(self = [super init])
    {}
    return self;
}

- (void)initLayout
{
    [self setBackgroundColor:[UIColor blackColor]];
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor blackColor].CGColor;
    self.layer.cornerRadius = 3.0f;
    self.alpha = 0.6f;
    
    self.spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.spinner.frame = CGRectMake(self.frame.size.width/2-20.0f/2, self.frame.size.height/2-20.0f/2, 20.0f, 20.0f);
    self.spinner.hidesWhenStopped = YES;
    [self addSubview:spinner];
    
    int labelHeight = 15.0f;
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, self.frame.size.height-labelHeight, self.frame.size.width, labelHeight)];
    self.label.text = content;
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.textColor = [UIColor whiteColor];
    [self.label setBackgroundColor:[UIColor clearColor]];
    self.label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:11.0f];
    [self addSubview:label];
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
    //[bgView setBackgroundColor:[UIColor colorWithWhite:0.3 alpha:0.7]];
    [bgView setBackgroundColor:[UIColor clearColor]];
}

- (void)showTheView
{
    self.label.text = content;
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGRect frame = self.frame;
    frame.origin.x = screenSize.width/2 - frame.size.width/2;
    frame.origin.y = screenSize.height/2 - frame.size.height/2;
    self.frame = frame;
    [keyWindow addSubview:bgView];
    [keyWindow addSubview:self];
    [spinner startAnimating];
}

- (void)dismissTheView
{
    [spinner stopAnimating];
    [bgView removeFromSuperview];
    [self removeFromSuperview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

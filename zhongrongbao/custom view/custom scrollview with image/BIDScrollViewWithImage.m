//
//  BIDScrollViewWithImage.m
//  shangwuting
//
//  Created by mal on 14-6-30.
//  Copyright (c) 2014年 mal. All rights reserved.
//

#import "BIDScrollViewWithImage.h"

@implementation BIDScrollViewWithImage
@synthesize imgView;
@synthesize image;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.minimumZoomScale = 1.0f;
        self.maximumZoomScale = 3.0f;
        [self setZoomScale:1.0f];
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.delegate = self;
        imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        //imgView.contentMode = UIViewContentModeCenter;
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:imgView];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setImage:(UIImage *)img
{
    imgView.image = img;
}

#pragma mark -
#pragma mark === UIScrollView Delegate ===
#pragma mark -
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return imgView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
	//NSLog(@"%s", _cmd);
	
	CGFloat zs = scrollView.zoomScale;
	zs = MAX(zs, 1.0);
	zs = MIN(zs, 3.0);
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	scrollView.zoomScale = zs;
	[UIView commitAnimations];
}

#pragma mark -
#pragma mark === UITouch Delegate ===
#pragma mark -
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	//NSLog(@"%s", _cmd);
	
	UITouch *touch = [touches anyObject];
	
	if ([touch tapCount] == 2)
	{
		//NSLog(@"double click");
		
		CGFloat zs = self.zoomScale;
		zs = (zs == 1.0) ? 3.0 : 1.0;
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.3];
		self.zoomScale = zs;
		[UIView commitAnimations];
	}
}

@end

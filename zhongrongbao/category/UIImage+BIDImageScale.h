//
//  UIImage+BIDImageScale.h
//  shangwuting
//
//  Created by mal on 13-12-26.
//  Copyright (c) 2013年 mal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (BIDImageScale)

-(UIImage*)getSubImage:(CGRect)rect;
-(UIImage*)scaleToSize:(CGSize)size;
+(UIImage *) imageCompressForSize:(UIImage *)sourceImage targetSize:(CGSize)size;
@end

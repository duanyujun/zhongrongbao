//
//  BIDImgDownloader.h
//  zhongrongbao
//
//  Created by mal on 15/6/28.
//  Copyright (c) 2015年 cnsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BIDNode;

@interface BIDImgDownloader : NSObject

/**
 *图片下载地址
 */
@property (copy, nonatomic) NSString *imgDownloadURL;

@property (copy, nonatomic) void (^completionHandler)(void);

@property (strong, nonatomic) BIDNode *node;

/**
 *开始下载
 */
- (void)startDownload;
/**
 *取消下载
 */
- (void)cancelDownload;

@end

//
//  BIDUploadFile.h
//  shangwuting
//
//  Created by mal on 13-12-24.
//  Copyright (c) 2013年 mal. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BIDCustomSpinnerView;

@protocol BIDUploadFileDelegate <NSObject>

- (void)uploadFileSuccess;

@end

@interface BIDUploadFile : NSObject<NSURLConnectionDelegate, NSURLConnectionDataDelegate, UIAlertViewDelegate>

@property (strong, nonatomic)NSURLConnection *urlConnection;
@property (strong, nonatomic)NSMutableURLRequest *urlRequest;
@property (strong, nonatomic)NSMutableData *fileData;
//上传时已上传的数据大小
@property (assign, nonatomic)NSInteger uploadedLength;

@property (assign, nonatomic)NSUInteger fileSize;

@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UIProgressView *progressView;
@property (strong, nonatomic) UIButton *cancelBtn;
@property (strong, nonatomic) UIView *uploadView;
@property (strong, nonatomic) UIView *bgView;

@property (strong, nonatomic)BIDCustomSpinnerView *spinnerView;

@property (assign, nonatomic) id<BIDUploadFileDelegate> delegate;

//上传成功或者失败的提示
@property (copy, nonatomic)NSString *hintMsg;

- (void)initURL:(NSString*)strURL;

- (void)initUploadView;

- (void)addData:(NSString*)strKey value:(NSString*)strValue;
- (void)addFileFromLocal:(NSString*)strFileName fieldName:(NSString*)strFieldName;
- (void)addFileFromMemory:(NSString*)strFileName fieldName:(NSString*)strFieldName data:(NSData*)data;
- (void)addEndBoundary;
- (void)finishAddFile;

- (void)startUpload;
//取消上传
- (void)cancelBtnHandler;

@end

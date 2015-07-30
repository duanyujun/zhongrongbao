//
//  BIDImgDownloader.m
//  zhongrongbao
//
//  Created by mal on 15/6/28.
//  Copyright (c) 2015年 cnsoft. All rights reserved.
//

#import "BIDImgDownloader.h"
#import "BIDNode.h"

@interface BIDImgDownloader()<NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
    NSURLConnection *_connection;
    NSMutableData *_imgData;
}

@end

@implementation BIDImgDownloader

@synthesize imgDownloadURL;
@synthesize completionHandler;
@synthesize node;

- (id)init
{
    if(self = [super init])
    {
    }
    return self;
}

- (void)startDownload
{
    _imgData = [[NSMutableData alloc] init];
    NSURL *url = [NSURL URLWithString:node.imgDownloadURL];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    _connection = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
}

- (void)cancelDownload
{
    if(_connection)
    {
        _imgData = nil;
        [_connection cancel];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_imgData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if(_imgData)
    {
        node.img = [UIImage imageWithData:_imgData];
        //NSData *data = UIImageJPEGRepresentation(node.img, 0.1);
        //node.img = [UIImage imageWithData:data];
    }
    if(self.completionHandler)
    {
        self.completionHandler();
    }
    _imgData = nil;
    _connection = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
}

@end

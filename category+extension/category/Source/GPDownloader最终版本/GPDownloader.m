//
//  GPDownloader.m
//  下载管理器2
//
//  Created by mac on 15-2-16.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import "GPDownloader.h"
#import "GPDownloadFileHelper.h"
#import "GPDownloadInfo.h"

@interface GPDownloader ()<NSURLConnectionDataDelegate>

@property (nonatomic,strong) GPDownloadFileHelper *fileHelper;
@property (nonatomic,strong) NSURLConnection *connection;
@property (nonatomic,assign) CFRunLoopRef runLoop;

@end

@implementation GPDownloader

#pragma mark - 初始化方法
- (instancetype)initWithURL:(NSURL *)url range:(NSRange)range{
    if ( self = [super init] ) {
        self.downloaderInfo.targetRange = range;
        self.downloaderInfo.url = url;
    }
    return self;
}

+ (instancetype)downloaderWithURL:(NSURL *)url range:(NSRange)range{
    return [[self alloc] initWithURL:url range:range];
}

#pragma mark - 懒加载方法
- (GPDownloadFileHelper *)fileHelper{
    if (_fileHelper == nil) {
        _fileHelper = [GPDownloadFileHelper downloadFileHelperWithDownloadInfo:self.downloaderInfo];
    }
    return _fileHelper;
}

- (GPDownloadInfo *)downloaderInfo{
    if (_downloaderInfo == nil) {
        _downloaderInfo = [[GPDownloadInfo alloc]init];
    }
    return _downloaderInfo;
}

- (NSURLConnection *)connection{
    if (_connection == nil) {
        NSAssert(self.downloaderInfo.headerString != nil, @"headerString can not be nil");
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.downloaderInfo.url cachePolicy:0 timeoutInterval:kGPDefaultTimeoutInterval];
        [request setValue:self.downloaderInfo.headerString forHTTPHeaderField:@"Range"];
        _connection = [NSURLConnection connectionWithRequest:request delegate:self];
    }
    return _connection;
}

#pragma mark - 下载管理方法
- (void)start{
    if ( self.downloaderInfo.status == GPDownloadDownloading || self.downloaderInfo.status == GPDownloadFinish )return;
    [self startDownloadTask];
}
- (void)stop{
    if ( self.downloaderInfo.status == GPDownloadStop || self.downloaderInfo.status == GPDownloadFinish ) return;
    [self stopDownloadTask];
}

- (void)stopRunLoop{
    if ( self.runLoop ) {
        CFRunLoopStop(self.runLoop);
        self.runLoop = NULL;
    }
}

#pragma mark - 私有方法
- (void)stopDownloadTask{
    if ( self.connection == nil ) return;
    [self.connection cancel];
    self.connection = nil;
    self.downloaderInfo.status = GPDownloadStop;
    [self.fileHelper finishFileWriting];
    [self stopRunLoop];
}

- (void)startDownloadTask{
    if ( ![self.fileHelper isNeedToDownLoad] ) {
        GPLog(@"文件已经存在无须下载");
        return;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.connection start];
        self.runLoop = CFRunLoopGetCurrent();
        CFRunLoopRun();
    });
}

#pragma mark - NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [self.fileHelper startFileWriting];
    self.downloaderInfo.status = GPDownloadDownloading;
    if ( [self.delegate respondsToSelector:@selector(downloadDidstarted:)] ) {
        [self.delegate downloadDidstarted:self.downloaderInfo];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.fileHelper writeData:data];
    if ( [self.delegate respondsToSelector:@selector(downloadDidUpdateProgress:)] ) {
        [self.delegate downloadDidUpdateProgress:self.downloaderInfo];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [self.fileHelper finishFileWriting];
    self.downloaderInfo.status = GPDownloadFinish;
    if ( [self.delegate respondsToSelector:@selector(downloadDidFinished:)] ) {
        [self.delegate downloadDidFinished:self.downloaderInfo];
    }
    [self stopRunLoop];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    GPLog(@"下载出错");
    self.downloaderInfo.status = GPDownloadError;
    if ( [self.delegate respondsToSelector:@selector(downloadDidReceiveError:)] ) {
        [self.delegate downloadDidReceiveError:error];
    }
    [self.fileHelper finishFileWriting];
    [self stop];
    [self stopRunLoop];
}

@end

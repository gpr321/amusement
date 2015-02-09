//
//  GPDownloader.m
//  test
//
//  Created by mac on 15-2-3.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#define fileManager [NSFileManager defaultManager]

#import "GPDownloader.h"
#import "NSString+SandBox.h"

// 默认重新连接次数
static NSInteger const kMaxRestartCount = 3;
// 默认的超时时间
static NSTimeInterval const kTimeOut = 5;

@interface GPDownloader ()<NSURLConnectionDataDelegate>

@property (nonatomic,assign) CFRunLoopRef currLoopRef;

@property (nonatomic,strong) NSOutputStream *fileOutPutStream;

@property (nonatomic,strong) NSURLConnection *currConnection;

@property (nonatomic,assign) BOOL hasBegan;

@property (nonatomic,strong) dispatch_queue_t queue;

@property (nonatomic,assign) NSInteger restartCount;

@end

@implementation GPDownloader

+ (instancetype)downloaderWithURLString:(NSString *)urlString downloadRange:(NSRange)downloadRange fileName:(NSString *)fileName{
    return [[self alloc] initWithURLString:urlString downloadRange:downloadRange fileName:fileName];
}

+ (instancetype)downloaderWithURLString:(NSString *)urlString downloadRange:(NSRange)downloadRange startBlock:(StartTaskBlock)startBlock progressBlock:(ProgressBlock)progressBlock completeBlock:(CompleteBlock)completeBlock errorBlock:(ErrorBlock)errorBlock fileName:(NSString *)fileName{
    return [[self alloc]initWithURLString:urlString downloadRange:downloadRange startBlock:startBlock progressBlock:progressBlock completeBlock:completeBlock errorBlock:errorBlock fileName:fileName];
}

- (instancetype)initWithURLString:(NSString *)urlString downloadRange:(NSRange)downloadRange startBlock:(StartTaskBlock)startBlock progressBlock:(ProgressBlock)progressBlock completeBlock:(CompleteBlock)completeBlock errorBlock:(ErrorBlock)errorBlock fileName:(NSString *)fileName{
    self.startBlock = startBlock;
    self.progressBlock = progressBlock;
    self.completeBlock = completeBlock;
    self.errorBlock = errorBlock;
    self.maxRestartCount = kMaxRestartCount;
    return [self initWithURLString:urlString downloadRange:downloadRange fileName:fileName];
    
}

- (instancetype)initWithURLString:(NSString *)urlString downloadRange:(NSRange)downloadRange fileName:(NSString *)fileName{
    if ( urlString.length <=0 || downloadRange.length == 0)return nil;
    if ( self = [super init] ) {
        self.downloadRange = downloadRange;
        self.urlString = urlString;
        self.fileName = fileName;
        self.maxRestartCount = kMaxRestartCount;
        self.timeOut = kTimeOut;
    }
    return self;
}

- (void)setFileName:(NSString *)fileName{
    _fileName = [fileName copy];
    NSString *temName = [NSString stringWithFormat:@"%@_%tu_%tu",_fileName,self.downloadRange.location,self.downloadRange.length];
    _tempFilePath = [temName gp_tempFile];
    // NSLog(@"%@",self.tempFilePath);
}

- (void)restart{
    if ( self.currConnection == nil )return;
    [self destoryDownloader];
    [self startDownloadTask];
}

/**
    1. 临时文件保存在temp 目录
    2. 首先检查临时文件是否存在,如果存在则取出已经下载的临时文件的长度 fileLength
        如果 fileLength > downloadRange 把原来的文件删除,(文件不存在也要重新下载)重新下载
    3. 如果文件已经存在,则取出当前长度继续下载
 */
- (void)startDownloadTask{
    NSRange targetRange = [self checkLocalFile];
    if ( targetRange.length == 0 ) {
        NSLog(@"文件已经下载完毕,无须下载...");
        return;
    }
    // 开始下载
    [self downLoadFileInRange:targetRange];
}

- (NSRange)checkLocalFile{
    BOOL fileExists = [fileManager fileExistsAtPath:self.tempFilePath];
    NSRange range = NSMakeRange(0, 0);
    if ( !fileExists ) {
        range = self.downloadRange;
        self.currFileSize = 0;
    } else {
        unsigned long long fileSize = [[fileManager attributesOfItemAtPath:self.tempFilePath error:NULL] fileSize];
        if ( fileSize == self.downloadRange.length )return NSMakeRange(0, 0);
        if ( fileSize > self.downloadRange.length ) {
            [fileManager removeItemAtPath:self.tempFilePath error:NULL];
            range = self.downloadRange;
            self.currFileSize = 0;
        } else {
            range = NSMakeRange(self.downloadRange.location + fileSize, self.downloadRange.length - fileSize);
            NSLog(@"range-----%@",NSStringFromRange(range));
            self.currFileSize = fileSize;
        }
    }
    return range;
}

- (void)pause{
    if ( self.currConnection != nil) {
        [self destoryDownloader];
    }
}

- (void)stop{
    if ( self.currConnection != nil ) {
        [self destoryDownloader];
    }
}

- (void)resume{
    if ( self.currConnection == nil ) {
        [self startDownloadTask];
    }
}

- (void)destoryDownloader{
    [self stopRunLoop];
    [self.currConnection cancel];
    self.currConnection = nil;
    [self destoryQueue];
    [self closeFileStream];
}

#pragma mark - CFRunLoopRef操作
- (void)stopRunLoop{
    if ( self.currLoopRef ) {
        CFRunLoopStop(self.currLoopRef);
        self.currLoopRef = 0;
    }
}

- (void)destoryQueue{
    if ( self.queue ) {
        self.queue = nil;
    }
}

#pragma mark - fileOutPutStream操作
- (void)closeFileStream{
    if ( self.fileOutPutStream  ) {
        [self.fileOutPutStream close];
    }
}

- (void)openFileStream{
    // NSLog(@"%@",self.tempFilePath);
    self.fileOutPutStream = [[NSOutputStream alloc] initToFileAtPath:self.tempFilePath append:YES];
    [self.fileOutPutStream open];
}

#pragma mark - 开始异步下载任务
- (void)downLoadFileInRange:(NSRange)newRange{
    NSURL *url = [NSURL URLWithString:self.urlString];
    NSMutableURLRequest *reuqest = [NSMutableURLRequest requestWithURL:url cachePolicy:0 timeoutInterval:self.timeOut];
    unsigned long long from = newRange.location;
    unsigned long long to = newRange.length + newRange.location;
    NSString *headerStr = [NSString stringWithFormat:@"bytes=%lld-%lld",from,to];
    [reuqest setValue:headerStr forHTTPHeaderField:@"Range"];
    _currConnection = [[NSURLConnection alloc] initWithRequest:reuqest delegate:self];
    if ( self.queue == nil ) {
        self.queue = dispatch_queue_create([self.tempFilePath cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_CONCURRENT);
    }
    dispatch_async(self.queue, ^{
        [_currConnection start];
        self.currLoopRef = CFRunLoopGetCurrent();
        NSLog(@"---runloop %p",self.currLoopRef);
        CFRunLoopRun();
    });
    
}

#pragma mark - <NSURLConnectionDataDelegate>
// 下载开始
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    // 开启文件流
    [self openFileStream];
    if ( self.hasBegan == YES ) return;
    if ( self.startBlock ) {
        self.startBlock(self);
    }
    if ( [self.delegate respondsToSelector:@selector(downloaderDidStart:)] ) {
        [self.delegate downloaderDidStart:self];
    }
    self.hasBegan = YES;
}

// 处理接收到下载数据
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.fileOutPutStream write:data.bytes maxLength:data.length];
    unsigned long long dataSize = data.length;
    self.currFileSize += dataSize;
    if ( self.progressBlock ) {
        self.progressBlock(dataSize);
    }
    if ( [self.delegate respondsToSelector:@selector(downloaderDidUpdateDataSize:)] ) {
        [self.delegate downloaderDidUpdateDataSize:dataSize];
    }
}

// 下载完毕
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    if ( self.completeBlock ) {
        self.completeBlock(self);
    }
    if ( [self.delegate respondsToSelector:@selector(downloaderDidComplete:)] ) {
        [self.delegate downloaderDidComplete:self];
    }
    [self destoryDownloader];
}

// 下载出错
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    if ( self.restartCount < self.maxRestartCount ) {
        [self restart];
        self.restartCount++;
        return;
    }
    if ( self.errorBlock ) {
        self.errorBlock(self,error);
    }
    if ( [self.delegate respondsToSelector:@selector(downloader:DidDownLoadFail:)] ) {
        [self.delegate downloader:self DidDownLoadFail:error];
    }
    [self destoryDownloader];
}

@end



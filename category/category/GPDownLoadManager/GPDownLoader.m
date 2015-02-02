//
//  GPDownLoadManager.m
//  17-实现下载管理器
//
//  Created by mac on 15-1-20.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

// 请求的超时时间
#define kTimeOut 15.0

#import "GPDownLoader.h"

@interface GPDownLoader ()<NSURLConnectionDataDelegate>

@property (nonatomic,strong) NSURL *url;

/** 文件的长度 */
@property (nonatomic,assign) long long expectedContentLength;

/** 服务器响应返回期望的名字 */
@property (nonatomic,copy) NSString *suggestedFilename;

@property (nonatomic,copy) NSString *fileTargetPath;

/** 已经下载的文件长度 */
@property (nonatomic,assign) long long  curFileLength;

@property (nonatomic,assign) CFRunLoopRef downLoadLoop;

/** 文件输出流 */
@property (nonatomic,strong) NSOutputStream *fileOutPutStream;

/** 进度 */
@property (nonatomic,copy) void(^progressBlock)(float);

/** 完成之后回调 */
@property (nonatomic,copy)  void(^completeBlock)();

/** 出错之后回调 */
@property (nonatomic,copy) void(^errorBlock)(NSError *error);

/** 下载连接 */
@property (nonatomic,strong) NSURLConnection *connection;

@end

@implementation GPDownLoader

- (void)downLoadWithURL:(NSURL *)url progress:(void(^)(float))progressBlock complete:(void(^)())completeBlock error:(void(^)(NSError *))errorBlock{
    if ( self.connection != nil || self.status == GPDownLoaderStatusDownLoading ) {
        return;
    }
    self.url = url;
    
    self.progressBlock = progressBlock;
    self.completeBlock = completeBlock;
    self.errorBlock = errorBlock;

    [self startDownLoadTask];
}

- (void)pause{
    if ( self.connection ) {
        [self.connection cancel];
        self.connection = nil;
        [self closeFileStream];
        [self closeRunLoop];
        self.status = GPDownLoaderStatusPause;
    }
}

- (void)resume{
    if ( self.connection ) {
        NSLog(@"下载任务正在进行中...");
        return;
    }
    [self startDownLoadTask];
    self.status = GPDownLoaderStatusDownLoading;
}

- (void)startDownLoadTask{
    [self getFileInfoFromServer];
    BOOL isNeedToDownLoad = [self isNeedToDownFile];
    if ( isNeedToDownLoad == NO ) {
         NSLog(@"文件已经存在无须下载");
        return;
    }
    // 开始下载文件
    [self startToDownLoadFile];
    
    self.status = GPDownLoaderStatusDownLoading;
}

/**
    思路分析 :
        0. 发送 Head 方法获取服务器中文件的信息
        1. 检查本地文件(根据URL获取文件名字,文件存放在Temp目录)
            1.1 如果本地 文件不存在 | 
                如果本地文件的大小大于目标文件的大小就删除 --> 就马上下载
            1.2 如果本地文件的大小小于目标文件的大小小于目标文件的大小就断点下载
        2. 根据本地文件情况进行断点下载
            2.2 下载的时候注意进度监听
 */
- (void)downLoadWithURL:(NSURL *)url{
    self.url = url;
    [self startDownLoadTask];

}

#pragma mark - NSURLConnectionDataDelegate
// 为了适配 iOS7.0 最好把三个方法都实现
// 接收到数据之后调用的方法
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    
     NSLog(@"--开始下载%ld",[((NSHTTPURLResponse *)response) statusCode]);
    self.suggestedFilename = response.suggestedFilename;
    self.fileOutPutStream = [[NSOutputStream alloc] initToFileAtPath:self.fileTargetPath append:YES];
    [self.fileOutPutStream open];
}
// 处理数据
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.fileOutPutStream write:data.bytes maxLength:data.length];
    self.curFileLength += data.length;
    float progress = (float)self.curFileLength / self.expectedContentLength;
    if ( self.progressBlock ) {
        self.progressBlock(progress);
    }
}


// 下载完毕
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
     NSLog(@"---下载完毕");
    if ( self.completeBlock ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.completeBlock();
        });
    }
    [self closeRunLoop];
    [self closeFileStream];
    self.connection = nil;
    self.status = GPDownLoaderStatusFinish;
    NSLog(@"%@",self.fileTargetPath);
}

- (void)dealloc{
    NSLog(@"死了----");
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
     NSLog(@"网络连接发生错误");
    if ( self.errorBlock ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.errorBlock(error);
        });
    }
    [self closeRunLoop];
    [self closeFileStream];
    self.connection = nil;
    self.status = GPDownLoaderStatusBreak;
}

- (void)closeRunLoop{
    if ( self.downLoadLoop  ) {
        // 关闭运行循环
        CFRunLoopStop(self.downLoadLoop);
        self.downLoadLoop = 0;
    }
}

- (void)closeFileStream{
    if ( self.fileOutPutStream  ) {
        [self.fileOutPutStream close];
        self.fileOutPutStream = nil;
    }
}


#pragma mark - 开始下载文件,异步
- (void)startToDownLoadFile{
   dispatch_async(dispatch_get_global_queue(0, 0), ^{
       NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url cachePolicy:1 timeoutInterval:kTimeOut];
       
       // 定位从哪里开始下载 Range bytes=??-
       NSString *headerStr = [NSString stringWithFormat:@"bytes=%lld-",self.curFileLength];
       [request setValue:headerStr forHTTPHeaderField:@"Range"];
       
       self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
       [self.connection start];
       
       // 开启运行循环
       self.downLoadLoop = CFRunLoopGetCurrent();
       CFRunLoopRun();
   });
}

#pragma mark - 检查本地文件
- (BOOL)isNeedToDownFile{

    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:self.suggestedFilename];
    
    self.fileTargetPath = filePath;
     NSLog(@"%@",filePath);
    NSFileManager *fileManger = [NSFileManager defaultManager];

    if ( ![fileManger fileExistsAtPath:filePath] ) return YES;
    
    NSDictionary *fileInfo = [fileManger attributesOfItemAtPath:filePath error:NULL];

    long long curFileLength = [fileInfo fileSize];
    
    if ( curFileLength == self.expectedContentLength  ) return NO;

    if ( curFileLength > self.expectedContentLength ) {
        [fileManger removeItemAtPath:filePath error:NULL];
        return YES;
    }
    
    self.curFileLength = curFileLength;
    
    return YES;
}


#pragma mark - 0. 发送 Head 方法获取服务器中文件的信息
- (void)getFileInfoFromServer{
    // 不使用缓存
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:kTimeOut];
    // Head方法
    request.HTTPMethod = @"HEAD";
    // 使用同步方法
    NSURLResponse *response = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
    
    self.expectedContentLength = response.expectedContentLength;
    
    self.suggestedFilename = response.suggestedFilename;
    
    NSLog(@"get----fileName %@",self.suggestedFilename);
    if ( self.suggestedFilename == nil ) {
        self.suggestedFilename = self.url.path;
    }
}

@end

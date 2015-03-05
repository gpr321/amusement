//
//  GPDownloadInfo.m
//  下载管理器2
//
//  Created by mac on 15-2-16.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#define GPTempFilePath(fileName) [NSTemporaryDirectory() stringByAppendingPathComponent:(fileName)]

#import "GPDownloadInfo.h"

@interface GPDownloadInfo ()

@end

@implementation GPDownloadInfo

//- (instancetype)init{
//    if ( self = [super init] ) {
//        self.downloadRange = NSMakeRange(0, 0);
//        self.targetRange = NSMakeRange(0, 0);
//    }
//    return self;
//}

- (void)setUrl:(NSURL *)url{
    _url = url;
}

- (void)setTargetRange:(NSRange)targetRange{
    _targetRange = targetRange;
    _totolBytes = _targetRange.length;
}

- (void)setBytesHasWriten:(unsigned long long)bytesHasWriten{
    _bytesHasWriten = bytesHasWriten;
    _progress = (float)_bytesHasWriten / _totolBytes;
}

- (NSString *)tempFilePath{
    NSString *tempFileName = [[self.url.absoluteString lastPathComponent] stringByAppendingString:NSStringFromRange(self.targetRange)];
    return GPTempFilePath(tempFileName);
}

- (void)setDownloadRange:(NSRange)downloadRange{
    _downloadRange = downloadRange;
    unsigned long long from = self.downloadRange.location;
    unsigned long long to = self.downloadRange.length + self.downloadRange.location;
    
    self.bytesHasWriten = _downloadRange.location - _targetRange.location;  
    NSString *headerStr = [NSString stringWithFormat:@"bytes=%lld-%lld",from,to];
    _headerString = headerStr;
}



@end

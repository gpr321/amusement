//
//  GPDownloadInfo.h
//  下载管理器2
//
//  Created by mac on 15-2-16.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, GPDownloadStatus){
    GPDownloadUnStarted,
    GPDownloadDownloading,
    GPDownloadFinish,
    GPDownloadStop,
    GPDownloadError
};

@interface GPDownloadInfo : NSObject

/** 下载进度有关的属性 */
@property (nonatomic,strong) NSURL *url;
/** 下载进度 */
@property (nonatomic,assign) float progress;
@property (nonatomic,assign) unsigned long long totolBytes;
@property (nonatomic,assign) unsigned long long bytesHasWriten;
@property (nonatomic,assign) unsigned long long bytesToWritten;

/** 临时文件序号,以后合并文件有用 */
@property (nonatomic,assign) NSInteger tempFileNum;

@property (nonatomic,assign) NSRange targetRange;
/** 下载的range要看此属性 */
@property (nonatomic,assign) NSRange downloadRange;

@property (nonatomic,copy,readonly) NSString *headerString;
@property (nonatomic,copy,readonly) NSString *tempFilePath;
/** 下载状态 */
@property (nonatomic,assign) GPDownloadStatus status;
@end

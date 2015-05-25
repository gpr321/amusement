//
//  AVEncoder.m
//  MultiMedia
//
//  Created by Jiheng Yang on 10/8/11.
//  Copyright 2011 SNDA. All rights reserved.
//

#import "AVEncoder.h"
#import "zQueue.h"
#import "VideoFrame.h"
#import "VideoFramePool.h"
#import "AudioFrame.h"
#import "AudioFramePool.h"
#import "MMTask.h"
#import "TaskMan.h"
#import "MultiMediaEDL.h"
#import "Common.h"
#import "SystemConfig.h"
#import "MultiMediaMacros.h"
#import "zGenericFunc.h"
#import "zClock.h"

// Video compression settings.
#define VIDEO_BITRATE 512.0*1024.0
// One keyframe every 10 seconds.
#define VIDEO_MAX_KEYFRAME_INVERVAL 300

// Audio compression settings
#define AUDIO_CHANNEL_LAYOUT 2
#define AUDIO_SAMPLE_RATE 44100.0
#define AUDIO_BITRATE 128000

#define TIME_SCALE 1000
#define TIME_INCR  1000/30

#define INVEST_WIDTH_PER_IMAGE 160
#define INVEST_HEIGHT_PER_IMAGE 120

#define POSTER_FRAME_TINY_WIDTH 120
#define POSTER_FRAME_TINY_HEIGHT 90

@interface AVEncoder()

// This is called before encoding.
- (BOOL)setupAVEncoderTask;
- (void)cleanupSystemResources;

- (NSUInteger)getEncodeWidth;
- (NSUInteger)getEncodeHeight;

- (BOOL)appendVideoSamples:(VideoFrame *)videoFrame presentTime:(CMTime)presentTime;
- (BOOL)appendAudioSamples:(AudioFrame *)audioFrame presentTime:(CMTime)presentTime;
- (BOOL)appendAudioSampleBuffer:(CMSampleBufferRef)audioSampleBuffer;
- (BOOL)waitForWriterReady:(AVAssetWriterInput *)writerInput;
- (BOOL)stopEncoding:(CMTime)stopEncodingTime;

- (BOOL)generatePosterFrame:(VideoFrame *)videoFrame currTime:(CMTime)currTime;
- (UIImage *)scaleImage:(UIImage *)srcImage scaledToSize:(CGSize)scaledToSize;
- (BOOL)generateCheckImages:(VideoFrame *)videoFrame;

- (CGFloat)encodingProgress;

@end

@implementation AVEncoder

@synthesize errorCode = errorCode_;

@synthesize inputTaskQueue = inputTaskQueue_;
@synthesize taskMan = taskMan_;
@synthesize videoFramePool = videoFramePool_;
@synthesize audioFramePool = audioFramePool_;
@synthesize edlData = edlData_;
@synthesize outputFolder = outputFolder_;

@synthesize posterFrameTime = posterFrameTime_;
@synthesize posterRect = posterRect_;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        errorCode_ = kEncNoError;
    }
    
    return self;
}

- (void)dealloc
{
    self.inputTaskQueue = nil;
    self.taskMan = nil;
    self.videoFramePool = nil;
    self.audioFramePool = nil;
    self.edlData = nil;
    self.outputFolder = nil;
    [super dealloc];
}

- (CGRect)convertToCameraCoordinate:(CGRect)videoFrame
{
    UIInterfaceOrientation orientation = [edlData_ getOrientation]; 
    CGFloat cameraOriginX = 0.0f;
    CGFloat cameraOriginY = 0.0f;    
    CGRect cameraFrame = videoFrame;
    
    videoFrame.origin.x = (int)videoFrame.origin.x;//Trim fraction
    videoFrame.origin.y = (int)videoFrame.origin.y;//Trim fraction
    switch(orientation) {
        case UIInterfaceOrientationPortrait:
            cameraOriginX = videoFrame.origin.y;
            cameraOriginY = [self getEncodeHeight] - CGRectGetMaxX(videoFrame);
            cameraFrame.size.width = videoFrame.size.height;
            cameraFrame.size.height = videoFrame.size.width;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            cameraOriginX = videoFrame.origin.x;
            cameraOriginY = videoFrame.origin.y;
            break;
        case UIInterfaceOrientationLandscapeRight:
            cameraOriginX = [self getEncodeWidth] - CGRectGetMaxX(videoFrame);
            cameraOriginY = [self getEncodeHeight] - CGRectGetMaxY(videoFrame);
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            cameraOriginX = [self getEncodeWidth] - CGRectGetMaxY(videoFrame);
            cameraOriginY = videoFrame.origin.x;                
            cameraFrame.size.width = videoFrame.size.height;
            cameraFrame.size.height = videoFrame.size.width;            
            break;
        default:
            cameraOriginX = videoFrame.origin.x;
            cameraOriginY = videoFrame.origin.y;
            break;
    }
    cameraFrame.origin = CGPointMake(cameraOriginX, cameraOriginY);
    return cameraFrame;
}

- (void)setupPosterRectData
{
    CGRect rect = [self convertToCameraCoordinate:posterRect_];
    posterFrameSizeBig_.width = rect.size.width;
    posterFrameSizeBig_.height = rect.size.height;
    posterFrameSizeSmall_.width = rect.size.width/2.0f;
    posterFrameSizeSmall_.height = rect.size.height/2.0f;
    posterFrameSizeTiny_.width = POSTER_FRAME_TINY_WIDTH;
    posterFrameSizeTiny_.height = POSTER_FRAME_TINY_HEIGHT;
    posterFrameOffset_.x = rect.origin.x;
    posterFrameOffset_.y = rect.origin.y;
    zAssert(CGRectGetHeight(rect), @"Invalid poster size");
    zAssert(CGRectGetWidth(rect), @"Invalid poster size");    
}

#pragma mark - Setup Encoding Task
 
- (BOOL)setupAVEncoderTask
{
    NSError *movieError = nil;
    NSString *movieFileName = [NSString stringWithFormat:@"%@.%@", @"myWeikuVideo", [(SystemConfig *)[SystemConfig sharedInstance] stringValue:OUT_VIDEO_EXT_NAME]];
    NSString *movieURL = [Common getNewFileByOverwrite:outputFolder_ filename:movieFileName];
    
    assetWriter_ = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:movieURL]
                                             fileType:AVFileTypeMPEG4
                                                error:&movieError];
   
    // Setup video writer input.
    NSDictionary *videoCompressionProps = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNumber numberWithDouble:VIDEO_BITRATE], AVVideoAverageBitRateKey,
                                           //[NSNumber numberWithInt:VIDEO_MAX_KEYFRAME_INVERVAL], AVVideoMaxKeyFrameIntervalKey,
                                           //AVVideoProfileLevelH264Baseline30, 
                                           AVVideoProfileLevelH264Main31, AVVideoProfileLevelKey,
                                           nil];
    NSDictionary *assetWriterInputVideoSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264, AVVideoCodecKey,
        [NSNumber numberWithInt:[self getEncodeWidth]], AVVideoWidthKey,
        [NSNumber numberWithInt:[self getEncodeHeight]], AVVideoHeightKey,
        videoCompressionProps, AVVideoCompressionPropertiesKey,
        nil];
    
    assetWriterInputVideo_ = [[AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                                                 outputSettings:assetWriterInputVideoSettings] retain];
    assetWriterInputVideo_.expectsMediaDataInRealTime = YES;
    
    if(!assetWriterInputVideo_) {
        zErr(@"Creating asset writer input for video error");
        errorCode_ = kEncVideoWriterInitErr;
        goto FAILED;
    }
    
    assetWriterInputVideo_.transform = [edlData_ getTransform];
    
    if([assetWriter_ canAddInput:assetWriterInputVideo_]) {
        [assetWriter_ addInput:assetWriterInputVideo_];
    }
    else {
        zErr(@"Writer cannot add video writer.");
        errorCode_ = kEncVideoWriterNotAddableErr;
        goto FAILED;
    }

    /*
    NSDictionary *adaptorAttribute = [NSDictionary dictionaryWithObjectsAndKeys:
                                                   [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange], kCVPixelBufferPixelFormatTypeKey,
                                                   nil];
*/
     NSDictionary *adaptorAttribute = [NSDictionary dictionaryWithObjectsAndKeys:
     [NSNumber numberWithInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey,
     nil];
     
    assetWriterPixelBufferAdaptor_ = [[AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:assetWriterInputVideo_
                                                                                                       sourcePixelBufferAttributes:adaptorAttribute] retain];
    
    if(!assetWriterPixelBufferAdaptor_) {
        zErr(@"Creating asset writer pixel buffer adaptor error");
        errorCode_ = kEncVideoAdaptorInitErr;
        goto FAILED;
    }
    
    // Setup audio writer input.
    AudioChannelLayout acl;
    memset(&acl, 0, sizeof(acl));
    if(edlData_.timelineInfo.audioDesc.mChannelsPerFrame==1) {
        acl.mChannelLayoutTag = kAudioChannelLayoutTag_Mono;
    }
    else if(edlData_.timelineInfo.audioDesc.mChannelsPerFrame==2) {
        acl.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
    }
    else {
        zErr(@"Audio channel layout format not supported, please recheck audio coding configurations.");
        goto FAILED;
    }

    
    NSDictionary *assetWriterInputAudioSettings =     
    [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kAudioFormatMPEG4AAC], AVFormatIDKey, 
     [NSNumber numberWithInt: edlData_.timelineInfo.audioDesc.mChannelsPerFrame], AVNumberOfChannelsKey,
     [NSNumber numberWithFloat: AUDIO_SAMPLE_RATE], AVSampleRateKey,
     [NSNumber numberWithInt: AUDIO_BITRATE], AVEncoderBitRateKey,
     // Below two are complexity tuning points of compression audio.
     //AVAudioQualityHigh, AVSampleRateConverterAudioQualityKey, 
     //AVAudioQualityHigh, AVEncoderAudioQualityKey,
     [NSData dataWithBytes:&acl length:sizeof(acl)], AVChannelLayoutKey,
     nil];
    
    assetWriterInputAudio_ = [[AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio
                                                                outputSettings:assetWriterInputAudioSettings] retain];
    assetWriterInputAudio_.expectsMediaDataInRealTime = YES;
    
    if(!assetWriterInputAudio_) {
        errorCode_ = kEncAudioWriterInitErr;
        zErr(@"Creating asset writer input for audio error");
        goto FAILED;
    }
    
    if([assetWriter_ canAddInput:assetWriterInputAudio_])
        [assetWriter_ addInput:assetWriterInputAudio_];
    else {
        errorCode_ = kEncAudioWriterNotAddableErr;
        zErr(@"Writer cannot add audio writer");
        goto FAILED;
    }
    
    // We are done setup, let's go encoding.
    [assetWriter_ startWriting];
    [assetWriter_ startSessionAtSourceTime:kCMTimeZero];
    
    currentFrameNum_ = 0;
    estimatedTotalFrames_ = edlData_.duration * edlData_.timelineInfo.preferredRate;
    
    // Settings which are supposed to be set by outside parameters
    [self setupPosterRectData];
    // End encoding settings.
    LogRect(@"poster frame", posterRect_);
    zMsg(@"poster timestampe=%f", CMTimeGetSeconds(posterFrameTime_));
    
    for(int i=0; i<NUM_INVEST_IMAGES; i++) {
        frameToBeChecked_[i] = (estimatedTotalFrames_ * 0.20f) * (i+1);
    }
    
    posterFrameGenerated_ = NO;
    errorCode_ = kEncNoError;

    return YES;
FAILED:
    return NO;
}

- (void)cleanupSystemResources
{
    [assetWriterPixelBufferAdaptor_ release];
    [assetWriterInputVideo_ release];
    [assetWriterInputAudio_ release];
    [assetWriter_ release];

    assetWriter_ = nil;
    assetWriterInputVideo_ = nil;
    assetWriterInputAudio_ = nil;
    assetWriterPixelBufferAdaptor_ = nil;
}

- (NSUInteger)getEncodeWidth
{
    return edlData_.timelineInfo.editWidth;
}
- (NSUInteger)getEncodeHeight
{
    return edlData_.timelineInfo.editHeight;
}

#pragma mark - Encoding Functions

- (BOOL)appendVideoSamples:(VideoFrame *)videoFrame presentTime:(CMTime)presentTime
{
    if(!videoFrame) {
        zErr(@"NULL video frame buffer passed to encoder, should go check");
        // No sample, we donot add, but encoder is fine.
        return YES;
    }
    
    // Do we need to generate poster frames?
    [self generatePosterFrame:videoFrame currTime:presentTime];
    // Do we need to generate image for checking?
    [self generateCheckImages:videoFrame];
    currentFrameNum_ ++;
    
    CVPixelBufferRef pixelBuffer = NULL;
    CVReturn cvErr = kCVReturnSuccess;
    BOOL result = YES;
    
    switch(videoFrame.pixelFmt) {
        case kCVPixelFormatType_32BGRA:
            // Uploading BGRA 32 bit texture data.
            cvErr = CVPixelBufferCreateWithBytes(kCFAllocatorDefault, 
                                                 [self getEncodeWidth], 
                                                 [self getEncodeHeight], 
                                                 kCVPixelFormatType_32BGRA, 
                                                 [videoFrame getBaseAddressOfPlane:0], 
                                                 [videoFrame getBytesPerRowOfPlane:0],
                                                 NULL, 
                                                 NULL, 
                                                 NULL, 
                                                 &pixelBuffer);
            break;
        case kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange:
        {            
            size_t planeWidth[2], planeHeight[2], planeStride[2];
            void* planeBaseAddress[2];
            
            planeBaseAddress[0] = [videoFrame getBaseAddressOfPlane:0];
            planeBaseAddress[1] = [videoFrame getBaseAddressOfPlane:1];
            
            planeWidth[0] = [videoFrame getWidthOfPlane:0];
            planeWidth[1] = [videoFrame getHeightOfPlane:1];
            
            planeHeight[0] = [videoFrame getHeightOfPlane:0];
            planeHeight[1] = [videoFrame getHeightOfPlane:1];
            
            planeStride[0] = [videoFrame getBytesPerRowOfPlane:0];
            planeStride[1] = [videoFrame getBytesPerRowOfPlane:1];
            
            CVPlanarPixelBufferInfo_YCbCrBiPlanar aPlanarInfo;
            aPlanarInfo.componentInfoY.offset = 0;
            aPlanarInfo.componentInfoY.rowBytes = [videoFrame getBytesPerRowOfPlane:0];
            aPlanarInfo.componentInfoCbCr.offset = 0;
            aPlanarInfo.componentInfoCbCr.rowBytes = [videoFrame getBytesPerRowOfPlane:1];
            
            cvErr = CVPixelBufferCreateWithPlanarBytes(kCFAllocatorDefault, 
                                                       [videoFrame getWidthOfPlane:0], 
                                                       [videoFrame getHeightOfPlane:0], 
                                                       kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange, 
                                                       &aPlanarInfo, 
                                                       [videoFrame getBytesOfAll], 
                                                       videoFrame.planeCount, 
                                                       planeBaseAddress, 
                                                       planeWidth,
                                                       planeHeight,
                                                       planeStride, 
                                                       NULL, 
                                                       NULL, 
                                                       NULL, 
                                                       &pixelBuffer);
        }
            break;
        default:
            zErr(@"Unsupported pixel format specified");
            result = NO;
            errorCode_ = kEncVideoPixelFmtNotSupportedErr;
            goto DONE;
            break;
    }

    
    if(kCVReturnSuccess != cvErr) {
        zErr(@"Creating pixel buffer with bytes failed");
        errorCode_ = kEncVideoPixelBufferCreationFailErr;
        return NO;
    }
    
    result = [assetWriterPixelBufferAdaptor_ appendPixelBuffer:pixelBuffer withPresentationTime:presentTime];
    CVPixelBufferRelease(pixelBuffer);
    
    if(result) {
        zMsg(@"Encoded video frame at time %lf succeeded", CMTimeGetSeconds(presentTime));
    }
    else {
        zErr(@"Append video sample at time %lf failed", CMTimeGetSeconds(presentTime));
        errorCode_ = kEncVideoAppendSampleErr;
    }
    

DONE:
    return result;
}

- (BOOL)appendAudioSamples:(AudioFrame *)audioFrame presentTime:(CMTime)presentTime
{
    BOOL result = YES;
    OSStatus status;
    
    if(!audioFrame) {
        zErr(@"NULL audio frame buffer passed to encoder, should go check");
        // No sample, we donot add, but encoder is fine.
        return YES;
    }

    unsigned int audioFrameBytes =[audioFrame bytesOfData];
    
    CMSampleBufferRef audioBuffer = NULL;
    
    CMFormatDescriptionRef formatDescription;
    
    AudioStreamBasicDescription asbd = edlData_.timelineInfo.audioDesc;
    
    AudioChannelLayout acl;
    memset(&acl, 0, sizeof(acl));
    if(asbd.mChannelsPerFrame==1)
        acl.mChannelLayoutTag = kAudioChannelLayoutTag_Mono;
    else if(asbd.mChannelsPerFrame==2)
        acl.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
    else {
        zErr(@"Invalid audio channel layout flag received");
        return NO;
    }
    
    status = CMAudioFormatDescriptionCreate(kCFAllocatorDefault, 
                                            &asbd, 
                                            sizeof(acl), 
                                            &acl, 
                                            0, 
                                            NULL, 
                                            NULL, 
                                            &formatDescription);
    
    if(noErr != status) {
        zErr(@"Creating format description for audio sample buffer failed");
        errorCode_ = kEncAudioFormatDescCreationErr;
        return NO;
    }
    
    CMBlockBufferRef blockBuffer = NULL;
    
    status = CMBlockBufferCreateWithMemoryBlock(kCFAllocatorDefault, 
                                                NULL, 
                                                audioFrameBytes,
                                                kCFAllocatorDefault,
                                                NULL, 
                                                0,
                                                audioFrameBytes,
                                                kCMBlockBufferAssureMemoryNowFlag, 
                                                &blockBuffer);
    
    if(kCMBlockBufferNoErr != status) {
        zErr(@"Creating block buffer for audio data error");
        errorCode_ = kEncAudioBlockBufferCreationErr;
        return NO;
    }

    status = CMBlockBufferAssureBlockMemory(blockBuffer);
    
    if(kCMBlockBufferNoErr != status) {
        zErr(@"Creating block buffer for audio data error");
        errorCode_ = kEncAudioBlockBufferCreationErr;
        return NO;
    }
    
    status = CMBlockBufferReplaceDataBytes(audioFrame.data, blockBuffer, 0, audioFrameBytes);    
    
    if(kCMBlockBufferNoErr != status) {
        zErr(@"Creating block buffer for audio data error");
        errorCode_ = kEncAudioBlockBufferCreationErr;
        return NO;
    }    
    
    status = CMAudioSampleBufferCreateWithPacketDescriptions(kCFAllocatorDefault, 
                                                             blockBuffer, 
                                                             true,
                                                             NULL, 
                                                             NULL, 
                                                             formatDescription, 
                                                             audioFrame.sampleCount, 
                                                             presentTime, 
                                                             NULL, 
                                                             &audioBuffer);
    
    if(noErr != status) {
        zErr(@"Creating audio sample buffer failed");
        errorCode_ = kEncAudioSampleBufferCreationErr;
        return NO;
    }
    
    result = [assetWriterInputAudio_ appendSampleBuffer:audioBuffer];
    
    if(result) {
        zMsg(@"Encoded audio frame at time %lf succeeded", CMTimeGetSeconds(presentTime));
    }
    else {
        zErr(@"Append audio sample at time %lf failed", CMTimeGetSeconds(presentTime));
        errorCode_ = kEncAudioAppendSampleErr;
    }
    
    CFRelease(formatDescription);
    CFRelease(blockBuffer);
    CFRelease(audioBuffer);
    
    return result;
}

- (BOOL)appendAudioSampleBuffer:(CMSampleBufferRef)audioSampleBuffer
{
    if (NULL == audioSampleBuffer) {
        return YES;
    }
#ifdef DEBUG
    CMTime presentTime = CMSampleBufferGetPresentationTimeStamp(audioSampleBuffer);
#endif //DEBUG
    BOOL result;
    result = [assetWriterInputAudio_ appendSampleBuffer:audioSampleBuffer];
    
    if(result) {
        zMsg(@"Encoded audio frame at time %lf succeeded", CMTimeGetSeconds(presentTime));
    }
    else {
        zErr(@"Append audio sample at time %lf failed", CMTimeGetSeconds(presentTime));
        errorCode_ = kEncAudioAppendSampleErr;
    }    
    CFRelease(audioSampleBuffer);
    return result;
}

- (BOOL)waitForWriterReady:(AVAssetWriterInput *)writerInput
{
    while(1) {
        if(writerInput.readyForMoreMediaData) {
            break;
        }
        else {
            zErr(@"Encoder sleep waiting for writer ready");
            usleep(15000);
        }
    }
    return YES;
}

- (BOOL)stopEncoding:(CMTime)stopEncodingTime
{
    [assetWriterInputVideo_ markAsFinished];
    [assetWriterInputAudio_ markAsFinished];
    [assetWriter_ endSessionAtSourceTime:stopEncodingTime];
    
    if(NO == [assetWriter_ finishWriting]) {
        zErr(@"Finish writing encoded video failed");
        errorCode_ = kEncFinishWritingErr;
        return NO;
    }
    zInfo(@"Encoding is terminating.");
    return YES;
}

- (CGFloat)encodingProgress
{
    return ((float)currentFrameNum_ / (float)(estimatedTotalFrames_));
}

#pragma mark - Main Thread Function

- (void)main
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    zAssert(inputTaskQueue_, @"Invalid input task queue");
    zAssert(audioFramePool_, @"Invalid audioFramePool");
    zAssert(videoFramePool_, @"Invalid videoFramePool");
    zAssert(taskMan_, @"Invalid taskMan");
    zAssert(edlData_, @"Invalid edl data");
    zAssert(outputFolder_, @"Invalid output folder");
    
    if (![self setupAVEncoderTask]) {
        [self exit];
    }
    
    Float64 duration = edlData_.duration; 
    CMTime aEndTime = kCMTimeZero;
#ifdef DEBUG
    zClock *aClock = [[[zClock alloc] init] autorelease];
#endif
    while (![self isCancelled]) {
        // Block to get a task out of the task queue.
        MMTask *aTask = [inputTaskQueue_ pop:true];
        if(!aTask) {
            continue;
        }
        // Step 1: Validate task status.
        if (aTask.attribute == kMMStopTask) {
            [self stopEncoding:aEndTime];
            [self exit];
            [taskMan_ deleteTask:aTask];
            continue;
        }
        if(aTask.attribute == kMMMakeRefTask || aTask.attribute == kMMRefTask) {
            // Not really supposed to be here.
            [taskMan_ deleteTask:aTask];
            continue;
        }
        // Step 2: Encoding video data and images.
        [self waitForWriterReady:assetWriterInputVideo_];
#ifdef DEBUG
        [aClock start];
#endif
        VideoFrame *videoFrame = [aTask popImage];
        if (NO == [self appendVideoSamples:videoFrame presentTime:aTask.timeStamp]) {
            zErr(@"Encoder quits because of video sample appending error");
            [self exit];
            [taskMan_ deleteTask:aTask];
            continue;
        }
#ifdef DEBUG
        [aClock stop];
        zMsg(@"Encode one video frame time: %fms", (aClock.timeValue * 1000.0));
#endif
        [videoFramePool_ deleteFrame:videoFrame];
        
        // Step 3: Encoding audio data
        [self waitForWriterReady:assetWriterInputAudio_];
        AudioFrame *audioFrame = [aTask popAudio];
        // Approach 1: using sample buffer to encode audio
        //CMSampleBufferRef audioSampleBuffer = [aTask popAudioSampleBuffer];
        /*if(NO == [self appendAudioSampleBuffer:audioSampleBuffer]) {
            zErr(@"Encoder quits because of audio sample appending error");
            break;
        }*/
        
        // Approach 2: using audio samples to encode audio.
        if(NO == [self appendAudioSamples:audioFrame presentTime:aTask.timeStamp]) {
            zErr(@"Encoder quits because of audio sample appending error");
            [self exit];
            [taskMan_ deleteTask:aTask];
            continue;
        }
        [audioFramePool_ deleteFrame:audioFrame];
        aEndTime = CMTimeAdd(aTask.timeRange.start, aTask.timeRange.duration);
        // Step 4: Post encoding checkings.
        if(aTask.frameType == kMMLastFrame) {
            // We are at the end of the stream now. Quit coding.
            [self stopEncoding:aEndTime];
            [self exit];
            [taskMan_ deleteTask:aTask];
            continue;
        }
        [taskMan_ deleteTask:aTask];
        
        //Send notification
        Float64 curTime = CMTimeGetSeconds(aEndTime);
        
        static NSTimeInterval lastTime = 0.0f;
        NSTimeInterval newTime = [[NSDate date] timeIntervalSinceReferenceDate];
        zMsg(@"encoding proceed timestamp=%f", newTime - lastTime);
        
        Float64 percent = curTime/duration;
        if (percent > 1.f) percent = 1.f;
        
        if (newTime - lastTime > 1.0f) {
            //Don't send for each single frame.
            NSNumber *number = [NSNumber numberWithFloat:percent];
            NSNotification *notification = [NSNotification notificationWithName:ENCODING_NOTIFICATION_NAME object:number];            
            dispatch_async(dispatch_get_main_queue(), ^(){
                [[NSNotificationCenter defaultCenter] postNotification:notification];
            });
            
            //[self performSelectorOnMainThread:@selector(sendNotification:) withObject:number waitUntilDone:NO];
            lastTime = newTime;
        }
    }
    // We should stop encoding if append sample failed.
    if(errorCode_==kEncVideoAppendSampleErr || errorCode_==kEncAudioAppendSampleErr) {
        [self stopEncoding:aEndTime];
    }
    [self cleanupSystemResources];
    [pool release];
    [self exitNotify];
}

- (void)sendNotification:(NSNumber *)number
{
    NSNotification *notification = [NSNotification notificationWithName:ENCODING_NOTIFICATION_NAME object:number];
    [[NSNotificationCenter defaultCenter] postNotification:notification];                
}
#pragma mark - Generate Poster Images

- (UIImage *)scaleImage:(UIImage *)srcImage scaledToSize:(CGSize)scaledToSize
{
    UIGraphicsBeginImageContext(scaledToSize);
    [srcImage drawInRect:CGRectMake(0, 0, scaledToSize.width, scaledToSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    return newImage;
}

- (BOOL)generatePosterFrame:(VideoFrame *)videoFrame currTime:(CMTime)currTime
{
    if(posterFrameGenerated_ || CMTimeCompare(currTime, posterFrameTime_)<0) {
        return NO;
    }

    int imgWidth = posterFrameSizeBig_.width;
    int imgHeight = posterFrameSizeBig_.height;
    
    int actualBigPosterSizeWidth = posterFrameSizeBig_.width;
    int actualBigPosterSizeHeight = (posterFrameSizeBig_.width * 3 / 4);
    
    int imgBitsPerComponent = 8;
    int imgBytesPerRow = imgWidth*4;
    unsigned char *posterFrameBuf = (unsigned char *)malloc(imgWidth*imgHeight*4);
    if(!posterFrameBuf) {
        // No memory, no poster.
        return NO;
    }
    unsigned char *srcDataPtr;
    unsigned char *dstDataPtr;
    
    int i, j;
    
    unsigned char *videoBufPtr = [videoFrame getBaseAddressOfPlane:0];
    int bytesPerPlane = [videoFrame getBytesPerRowOfPlane:0];
    
    // We need to extract the image data out of the VideoFrame, as well as reverse BGR as RGB.
    for(j=posterFrameOffset_.y; j<(int)(imgHeight+posterFrameOffset_.y); j++) {
        srcDataPtr = videoBufPtr + (int)(j*bytesPerPlane + posterFrameOffset_.x*4);
        dstDataPtr = posterFrameBuf + (int)((j-posterFrameOffset_.y)*imgWidth*4);
        for(i=0; i<imgWidth; i++) {
            *dstDataPtr++ = *(srcDataPtr+2);
            *dstDataPtr++ = *(srcDataPtr+1);
            *dstDataPtr++ = *(srcDataPtr);
            *dstDataPtr++ = *(srcDataPtr+3);
            srcDataPtr += 4;
        }
    }
    
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(posterFrameBuf, 
                                                 imgWidth, 
                                                 imgHeight, 
                                                 imgBitsPerComponent, 
                                                 imgBytesPerRow, 
                                                 colorSpace, 
                                                 bitmapInfo);
    
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    
    // Write the image to system.
    UIImage *rawImageBig = [UIImage imageWithCGImage:imageRef];
    
    UIInterfaceOrientation orientation = [edlData_ getOrientation];
    switch(orientation) {
        case UIInterfaceOrientationLandscapeRight:
            rawImageBig = [Common imageRotatedByDegrees:rawImageBig degrees:180 size:posterFrameSizeBig_];
            break;
        case UIInterfaceOrientationLandscapeLeft:
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            rawImageBig = [Common imageRotatedByDegrees:rawImageBig degrees:-90 size:posterFrameSizeBig_];
            break;
        case UIInterfaceOrientationPortrait:
            rawImageBig = [Common imageRotatedByDegrees:rawImageBig degrees:90 size:posterFrameSizeBig_];
            break;
        default:
            zAssert(NO, @"Invalid orientation type");
            break;
    }
    
    // Low resolution poster image
    UIImage *rawImageSmall = [self scaleImage:rawImageBig scaledToSize:posterFrameSizeSmall_];
    NSData *rawImageDataSmall = UIImagePNGRepresentation(rawImageSmall);
    NSString *posterFrameSmallFilename = [NSString stringWithFormat:@"%@.%@", @"myWeikuVideoPoster_1", @"png"];
    NSString *posterFrameSmallURL = [Common getNewFileByOverwrite:outputFolder_ filename:posterFrameSmallFilename];
    [rawImageDataSmall writeToFile:posterFrameSmallURL options:NSDataWritingAtomic error:nil];

    // Calc actual size poster frame
    int skip_lines = (imgHeight - actualBigPosterSizeHeight)/2;
    
    CGImageRef actualPosterImage = CGImageCreateWithImageInRect([rawImageBig CGImage], CGRectMake(0, skip_lines, actualBigPosterSizeWidth, actualBigPosterSizeHeight));
    
    UIImage *bigPosterImage= [UIImage imageWithCGImage:actualPosterImage];
    NSData *actualPosterImageData = UIImagePNGRepresentation(bigPosterImage);
    
    NSString *posterFrameBigFilename = [NSString stringWithFormat:@"%@.%@", @"myWeikuVideoPoster_0", @"png"];
    NSString *posterFrameBigURL = [Common getNewFileByOverwrite:outputFolder_ filename:posterFrameBigFilename];
    [actualPosterImageData writeToFile:posterFrameBigURL options:NSDataWritingAtomic error:nil];
    
    // Calc tiny poster frame
    UIImage *posterFrameTiny = [self scaleImage:bigPosterImage scaledToSize:posterFrameSizeTiny_];
    NSData *posterFrameTinyData = UIImagePNGRepresentation(posterFrameTiny);
    NSString *posterFrameTinyFilename = [NSString stringWithFormat:@"%@.%@", @"myWeikuVideoPoster_2", @"png"];
    NSString *posterFrameTinyURL = [Common getNewFileByOverwrite:outputFolder_ filename:posterFrameTinyFilename];
    [posterFrameTinyData writeToFile:posterFrameTinyURL options:NSDataWritingAtomic error:nil];
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CGImageRelease(imageRef);
    CGImageRelease(actualPosterImage);
    
    free(posterFrameBuf);
    posterFrameBuf = NULL;
    
    posterFrameGenerated_ = YES;
    
    return YES;
}

#pragma mark - Generate Images For Checking

- (BOOL)generateCheckImages:(VideoFrame *)videoFrame
{
    int i, j, k;
    unsigned char *srcPtr;
    unsigned char *dstPtr;
    unsigned char *videoBufPtr;
    unsigned char *investImageBuf;
    
    int bytesPerPlane;
    int heightOfPlane;
    int widthOfPlane;
    
    int xOffset;
    
    int imgBitsPerComponent = 8;
    int imgBytesPerRow = INVEST_WIDTH_PER_IMAGE*4;
    
    for(k=0; k<NUM_INVEST_IMAGES; k++) {
        if(currentFrameNum_ == frameToBeChecked_[k]) {
            break;
        }
    }
    
    if(k==NUM_INVEST_IMAGES) {
        // Not the frame we need
        return NO;
    }
    
    investImageBuf = (unsigned char*)malloc(INVEST_WIDTH_PER_IMAGE * INVEST_HEIGHT_PER_IMAGE * 4);
    if(!investImageBuf) {
        return NO;
    }
    
    videoBufPtr = [videoFrame getBaseAddressOfPlane:0];
    bytesPerPlane = [videoFrame getBytesPerRowOfPlane:0];
    heightOfPlane = [videoFrame getHeightOfPlane:0];
    widthOfPlane = [videoFrame getWidthOfPlane:0];
    
    for(j=0; j<INVEST_HEIGHT_PER_IMAGE; j++) {
        dstPtr = investImageBuf + j*INVEST_WIDTH_PER_IMAGE*4;
        srcPtr = videoBufPtr + (int)(((float)j/INVEST_HEIGHT_PER_IMAGE) * heightOfPlane) * bytesPerPlane;
        
        for(i=0; i<INVEST_WIDTH_PER_IMAGE; i++) {
            xOffset = (int)(((float)i/INVEST_WIDTH_PER_IMAGE) * widthOfPlane);
            
            *dstPtr++ = *(srcPtr + xOffset*4 + 2);
            *dstPtr++ = *(srcPtr + xOffset*4 + 1);
            *dstPtr++ = *(srcPtr + xOffset*4);
            *dstPtr++ = *(srcPtr + xOffset*4 + 3);
        }
    }
    
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGSize size = CGSizeMake(INVEST_WIDTH_PER_IMAGE, INVEST_HEIGHT_PER_IMAGE);
    
    CGContextRef context = CGBitmapContextCreate(investImageBuf, 
                                                 INVEST_WIDTH_PER_IMAGE, 
                                                 INVEST_HEIGHT_PER_IMAGE, 
                                                 imgBitsPerComponent, 
                                                 imgBytesPerRow, 
                                                 colorSpace, 
                                                 bitmapInfo);
    
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    
    // Write the image to system.
    UIImage *investImage = [UIImage imageWithCGImage:imageRef];
    
    UIInterfaceOrientation orientation = [edlData_ getOrientation];
    switch(orientation) {
        case UIInterfaceOrientationLandscapeRight:
            investImage = [Common imageRotatedByDegrees:investImage degrees:180 size:size];
            break;
        case UIInterfaceOrientationLandscapeLeft:
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            investImage = [Common imageRotatedByDegrees:investImage degrees:-90 size:size];
            break;
        case UIInterfaceOrientationPortrait:
            investImage = [Common imageRotatedByDegrees:investImage degrees:90 size:size];
            break;
        default:
            zAssert(NO, @"Invalid orientation type");
            break;
    }
    
    NSData *investImageData = UIImagePNGRepresentation(investImage);
    NSString *investImageFilename = [NSString stringWithFormat:@"%@%d.%@", @"myWeikuCheck_", k, @"png"];
    NSString *investImageURL = [Common getNewFileByOverwrite:outputFolder_ filename:investImageFilename];
    [investImageData writeToFile:investImageURL options:NSDataWritingAtomic error:nil];
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CGImageRelease(imageRef);
    
    free(investImageBuf);
    investImageBuf = NULL;
    
    return YES;
}

@end

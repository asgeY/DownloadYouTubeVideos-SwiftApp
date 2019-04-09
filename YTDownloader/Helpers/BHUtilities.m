//
//  UIViewController+BHConverting.m
//  YTDownloader
//
//  Created by BandarHelal on 15/02/2019.
//  Copyright © 2019 BandarHelal. All rights reserved.
//

#import "BHUtilities.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "SDAVAssetExportSession.h"
#import <Photos/Photos.h>


@implementation BHUtilities

- (void)ConvertVideoToAudio:(NSURL *)VideoURLPath DocumentsPath:(NSURL *)destination CompletionHandler:(void (^)(void))handler {
    AVMutableComposition *newAudioAsset = [AVMutableComposition composition];
    
    AVMutableCompositionTrack *dstCompositionTrack;
    dstCompositionTrack = [newAudioAsset addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    
    AVAsset *srcAsset = [AVURLAsset URLAssetWithURL:VideoURLPath options:nil];
    AVAssetTrack *srcTrack = [[srcAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    
    
    CMTimeRange timeRange = srcTrack.timeRange;
    
    NSError *error;
    
    if (NO == [dstCompositionTrack insertTimeRange:timeRange ofTrack:srcTrack atTime:kCMTimeZero error:&error]) {
        NSLog(@"track insert failed: %@\n", error);
        return;
    }
    
    
    AVAssetExportSession *exportSesh = [[AVAssetExportSession alloc] initWithAsset:newAudioAsset presetName:AVAssetExportPresetPassthrough];
    
    exportSesh.outputFileType = AVFileTypeAppleM4A;
    exportSesh.outputURL = destination;
    
    
    [exportSesh exportAsynchronouslyWithCompletionHandler:^{
        AVAssetExportSessionStatus  status = exportSesh.status;
        NSLog(@"export: %ld", (long)status);
        
        if (AVAssetExportSessionStatusFailed == status) {
            NSLog(@"FAILURE: %@\n", exportSesh.error);
        } else if (AVAssetExportSessionStatusCompleted == status) {
            NSLog(@"SUCCESS!\n");
            handler();
        }
    }];
}

- (CGImageRef)GetFrameGrap:(AVAsset *)AssetVideo {
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:AssetVideo];
    
    //Get the 1st frame 3 seconds in
    int frameTimeStart = 3;
    int frameLocation = 1;
    
    //Snatch a frame
    CGImageRef frameRef = [generator copyCGImageAtTime:CMTimeMake(frameTimeStart,frameLocation) actualTime:nil error:nil];
    return frameRef;
}

- (void)exportAsynchronouslyWithAVAsset:(AVAsset *)asset DocumentsPath:(NSURL *)destination {
    
    // AVAssetExportSession - 转码
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:asset presetName:AVAssetExportPreset1280x720];
    
    // 输出地址
    //NSString *outputPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"av1.mp4"];
    exportSession.outputURL = destination;
    
    // 文件类型, 目前只支持 AVFileTypeMPEG4 AVFileTypeQuickTimeMovie
    NSLog(@"supportedFileTypes：%@", exportSession.supportedFileTypes);
    exportSession.outputFileType = AVFileTypeMPEG4;
    
    // 文件大小限制
    //    exportSession.fileLengthLimit = 1024 * 1024 * 1024;
    // 时间限制
    exportSession.timeRange = CMTimeRangeMake(CMTimeMake(0, 0), CMTimeMake(1, 1));
    
    // AVMetadataItem 元数据
    exportSession.metadata = nil;
    // AVMetadataItemFilter 过滤器
    exportSession.metadataItemFilter = nil;
    
    // AVAudioMix 音频处理
    exportSession.audioMix = nil;
    // 时间距算法
    exportSession.audioTimePitchAlgorithm = AVAudioTimePitchAlgorithmSpectral;
    // 网络优化？,默认为no
    exportSession.shouldOptimizeForNetworkUse = YES;
    // 视频处理 AVVideoComposition AVMutableVideoComposition
    exportSession.videoComposition = nil;
    // AVVideoCompositing 协议和相关类，让你可以自定义视频的合成排版
    NSLog(@"%@", exportSession.customVideoCompositor);
    
    // 默认为no ， 设置为yes 的时候，质量更高,
    exportSession.canPerformMultiplePassesOverSourceMediaData = NO;
    // 缓存地址， canPerformMultiplePassesOverSourceMediaData为yes需要用到
    exportSession.directoryForTemporaryFiles = nil;
    
    
    // 启动,
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        
        // 完成回调
        NSLog(@"%ld", exportSession.status);
        
        if (exportSession.status == AVAssetExportSessionStatusCompleted) {
            
            NSLog(@"%@", exportSession.outputURL);
        }
        
    }];
    
    // 取消
    //    [exportSession cancelExport];
    
    // 最大时间
    CMTimeShow(exportSession.maxDuration);
    // AVAssetExportSessionStatusFailed or AVAssetExportSessionStatusCancelled.    exportSession.error;
    
    // 进度
    NSLog(@"%lf", exportSession.progress);
    // 状态 AVAssetExportSessionStatus
    NSLog(@"%ld", exportSession.status);
    
    // exportSession.asset 资源
    
    // 所有的 presetName
    NSLog(@"presetName：%@", [AVAssetExportSession allExportPresets]);
    // 可以使用的 presetName
    NSLog(@"presetName：%@", [AVAssetExportSession exportPresetsCompatibleWithAsset:asset]);
    // 判断兼容性,用户判断AVAssetExportSession是否能够成功输出转换的视音频文件
    [AVAssetExportSession determineCompatibilityOfExportPreset:AVAssetExportPresetMediumQuality withAsset:asset outputFileType:AVFileTypeMPEG4 completionHandler:^(BOOL compatible) {
        
        NSLog(@"compatible：%d", compatible);
    }];
    // 确定可以使用的文件类型
    [exportSession determineCompatibleFileTypesWithCompletionHandler:^(NSArray<NSString *> * _Nonnull compatibleFileTypes) {
        
        NSLog(@"compatible：%@", compatibleFileTypes);
    }];
}

- (void)DownloadVideo:(AVAsset *)VideoAsset {
    NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    
    SDAVAssetExportSession *encoder = [SDAVAssetExportSession.alloc initWithAsset:VideoAsset];
    encoder.outputFileType = AVFileTypeMPEG4;
    encoder.outputURL = documentsDirectoryURL;
    encoder.videoSettings = @
    {
    AVVideoCodecKey: AVVideoCodecTypeH264,
    AVVideoWidthKey: @1920,
    AVVideoHeightKey: @1080,
    AVVideoCompressionPropertiesKey: @
        {
        AVVideoAverageBitRateKey: @6000000,
        AVVideoProfileLevelKey: AVVideoProfileLevelH264High40,
        },
    };
    encoder.audioSettings = @
    {
    AVFormatIDKey: @(kAudioFormatMPEG4AAC),
    AVNumberOfChannelsKey: @2,
    AVSampleRateKey: @44100,
    AVEncoderBitRateKey: @128000,
    };
    
    [encoder exportAsynchronouslyWithCompletionHandler:^
    {
        if (encoder.status == AVAssetExportSessionStatusCompleted)
        {
            NSLog(@"Video export succeeded");
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:documentsDirectoryURL.absoluteURL];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                
                if (success) {
                    NSLog(@"Success Save Video To Camera Roll");
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"hi"
                                                                    message:@"Success save video"
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                    [[NSFileManager defaultManager] removeItemAtURL:documentsDirectoryURL.absoluteURL error:nil];
                } else {
                    NSLog(@"ERROR Save Video To Camera Roll");
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"hi"
                                                                    message:@"ERROR Save Video To Camera Roll"
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                }
            }];
        }
        else if (encoder.status == AVAssetExportSessionStatusCancelled)
        {
            NSLog(@"Video export cancelled");
        }
        else
        {
            NSLog(@"Video export failed with error: %@ (%ld)", encoder.error.localizedDescription, (long)encoder.error.code);
        }
    }];
    
}


- (NSString *)bundleSeedID {
    NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
                           (__bridge NSString *)kSecClassGenericPassword, (__bridge NSString *)kSecClass,
                           @"bundleSeedID", kSecAttrAccount,
                           @"", kSecAttrService,
                           (id)kCFBooleanTrue, kSecReturnAttributes,
                           nil];
    CFDictionaryRef result = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
    if (status == errSecItemNotFound)
        status = SecItemAdd((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
    if (status != errSecSuccess)
        return nil;
    NSString *accessGroup = [(__bridge NSDictionary *)result objectForKey:(__bridge NSString *)kSecAttrAccessGroup];
    NSArray *components = [accessGroup componentsSeparatedByString:@"."];
    NSString *bundleSeedID = [[components objectEnumerator] nextObject];
    CFRelease(result);
    return bundleSeedID;
}

@end

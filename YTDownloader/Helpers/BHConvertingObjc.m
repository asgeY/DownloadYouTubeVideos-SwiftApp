//
//  UIViewController+BHConverting.m
//  YTDownloader
//
//  Created by BandarHelal on 15/02/2019.
//  Copyright © 2019 BandarHelal. All rights reserved.
//

#import "BHConvertingObjc.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "SDAVAssetExportSession.h"
#import <Photos/Photos.h>


@implementation BHConvertingObjc

- (void)ConvertVideoToAudio:(NSURL *)VideoURLPath DocumentsPath:(NSURL *)destination {
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
        }
    }];
}

- (void)exportVideoWithAsset:(AVAsset *)VideoAsset DocumentsPath:(NSURL *)destination {
    SDAVAssetExportSession *encoder = [SDAVAssetExportSession.alloc initWithAsset:VideoAsset];
    encoder.outputFileType = AVFileTypeMPEG4;
    encoder.outputURL = destination;
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
        }
        else if (encoder.status == AVAssetExportSessionStatusCancelled)
        {
            NSLog(@"Video export cancelled");
        }
        else
        {
            NSLog(@"Video export failed with error: %@ (%d)", encoder.error.localizedDescription, encoder.error.code);
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

@end

//
//  UIViewController+BHConverting.h
//  YTDownloader
//
//  Created by BandarHelal on 15/02/2019.
//  Copyright © 2019 BandarHelal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface BHUtilities : NSObject
- (void)ConvertVideoToAudio:(NSURL *)VideoURLPath DocumentsPath:(NSURL *)destination CompletionHandler:(void (^)(void))handler;
- (CGImageRef)GetFrameGrap:(AVAsset *)AssetVideo;
- (void)exportAsynchronouslyWithAVAsset:(AVAsset *)asset DocumentsPath:(NSURL *)destination;
@end

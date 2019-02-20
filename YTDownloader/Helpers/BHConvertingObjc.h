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

@interface BHConvertingObjc : NSObject
- (void)ConvertVideoToAudio:(NSURL *)VideoURLPath DocumentsPath:(NSURL *)destination;
- (void)exportVideoWithAsset:(AVAsset *)VideoAsset DocumentsPath:(NSURL *)destination;
- (CGImageRef)GetFrameGrap:(AVAsset *)AssetVideo;
@end

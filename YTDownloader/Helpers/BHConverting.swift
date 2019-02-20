//
//  BHConverting.swift
//  YTDownloader
//
//  Created by BandarHelal on 15/02/2019.
//  Copyright © 2019 BandarHelal. All rights reserved.
//

import Foundation
import AVKit
import AVFoundation
import UIKit


open class BHConverting {
    
    open func ConvertAudioToVideo(audioURL: URL, destination: URL) {
        let soundFileUrl = audioURL
        let recordAsset: AVURLAsset = AVURLAsset(url: soundFileUrl, options: nil)
        
        let mixComposition: AVMutableComposition = AVMutableComposition()
        let recordTrack: AVMutableCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID())!
        
        let tracks1 =  recordAsset.tracks(withMediaType: AVMediaType.audio)
        let assetTrack1:AVAssetTrack = tracks1[0]
        
        let audioDuration:CMTime = assetTrack1.timeRange.duration
        do
        {
            try recordTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: audioDuration), of: assetTrack1, at: CMTime.zero)
            
        } catch {
            print(error)
        }
        
        let assetExport = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetPassthrough)!
        assetExport.outputFileType = AVFileType.mp4
        assetExport.outputURL = destination
        assetExport.shouldOptimizeForNetworkUse = true
        
        assetExport.exportAsynchronously( completionHandler: {
            
            switch assetExport.status {
            case  AVAssetExportSessionStatus.failed:
                print("failed \(assetExport.error!)")
            case AVAssetExportSessionStatus.cancelled:
                print("cancelled \(assetExport.error!)")
            default:
                print("complete\(destination)")
            }
        })
    }
}

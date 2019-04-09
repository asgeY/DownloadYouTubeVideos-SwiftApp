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
import KRProgressHUD


open class BHConverting {
    
    var dstCompositionTrack: AVMutableCompositionTrack?
    var srcAsset: AVAsset?
    var srcTrack: AVAssetTrack?
    var TimeRange: CMTimeRange?
    var status: AVAssetExportSession.Status?
    let bhalert = BHAlert()
    
    open func ConvertAudioToVideo(audioURL: URL, destination: URL, completionHandler handler: @escaping () -> Void) {
        
        KRProgressHUD.show(withMessage: "Converting...")
        
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
                KRProgressHUD.dismiss()
            case AVAssetExportSessionStatus.cancelled:
                print("cancelled \(assetExport.error!)")
                KRProgressHUD.dismiss()
            default:
                print("complete\(destination)")
                KRProgressHUD.dismiss()
                handler()
            }
        })
    }
    
    
    open func ConvertVideoToAudio(VideoURLpath: URL, destination: URL, Target: UIViewController, completionHandler handler: @escaping () -> Void) {
        
        KRProgressHUD.show(withMessage: "Converting...")
        
        let newAudioAsset = AVMutableComposition()
        let exportSesh = AVAssetExportSession(asset: newAudioAsset, presetName: AVAssetExportPresetPassthrough)
        
        dstCompositionTrack = newAudioAsset.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        srcAsset = AVURLAsset(url: VideoURLpath, options: nil)
        srcTrack = srcAsset!.tracks(withMediaType: .audio)[0]
        
        TimeRange = srcTrack!.timeRange
        
        exportSesh!.outputFileType = .m4a
        exportSesh!.outputURL = destination
        
        exportSesh!.exportAsynchronously {
            
            self.status = exportSesh!.status
            
            if .failed == self.status {
                print("failed converting: \(String(describing: exportSesh!.error))")
                self.bhalert.ShowBHAlertController(Title: "hi", message: "failed converting: \(String(describing: exportSesh!.error))", TitleButton: "OK :(", Target: Target)
            } else if .completed == self.status {
                print("Success converting :))")
                KRProgressHUD.dismiss()
                handler()
            }
            
        }
        
        
    }
    
    
    
}

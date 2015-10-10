//
//  VideoManager.swift
//  GIFMaker
//
//  Created by indream on 15/9/23.
//  Copyright © 2015年 indream. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class VideoManager: NSObject,AVCaptureFileOutputRecordingDelegate,AVCaptureVideoDataOutputSampleBufferDelegate {
    static var _instance:VideoManager!
    static func sharedManager()->VideoManager{
        if(_instance==nil){
            _instance = VideoManager()
        }
        return _instance
    }
    var videoWidth:Int32 = 1280
    var videoHeight:Int32 = 720
    var videoView:UIView?
    var captureSession:AVCaptureSession?// = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer?
    var videoOutput:AVCaptureMovieFileOutput?
    var imageOutput:AVCaptureStillImageOutput?
    var videoSampleOutput:AVCaptureVideoDataOutput?
    var timer:NSTimer?
    var outputSampleFileURL:NSURL?
    var isRecording:Bool = false
    // If we find a device we'll store it here for later use
    var captureDevice : AVCaptureDevice?
    var currentISO:Float = 0
    var currentSpeed:Float = 0
    var currentFocus:Float = 0
    
    var startISO:Float = 0
    var endISO:Float = 0
    var startFocus:Float = 0
    var endFocus:Float = 0
    var startSpeed:Float = 0
    var endSpeed:Float = 0
    
    var startTime:Double = 0.0
    var totalTime:Int32 = 0
    var currentTime:Float = 0
    var interval:Float = 0.0
    var prevTime:Float = 0.0
    var isVideo:Bool = true
    var videoWriter:AVAssetWriter?
    var writerInput:AVAssetWriterInput?
    var writeAdapter:AVAssetWriterInputPixelBufferAdaptor?
    
    func initSession(){
        
        let devices = AVCaptureDevice.devices()
        
        // Loop through all the capture devices on this phone
        for device in devices {
            // Make sure this particular device supports video
            if (device.hasMediaType(AVMediaTypeVideo)) {
                // Finally check the position and confirm we've got the back camera
                if(device.position == AVCaptureDevicePosition.Back) {
                    captureDevice = device as? AVCaptureDevice
                    if captureDevice != nil {
                        beginSession()
                    }
                }
            }
        }
        
        AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo) { (granted:Bool) -> Void in
            
        }
        
        createAlbum()
        
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: "timerHandle", userInfo: nil, repeats: true)
    }
    var recordBarButton:UIBarButtonItem?
    func timerHandle(){
        if(isRecording){
            currentTime = Float(NSDate().timeIntervalSince1970 - startTime)
            recordBarButton?.title = "\(Int32(Float(totalTime)-currentTime))"

            let per:Float = currentTime/Float(totalTime)
            currentFocus = startFocus + (endFocus-startFocus)*per
            currentISO = startISO + (endISO - startISO)*per
            currentSpeed = startSpeed + (endSpeed - startSpeed)*per
            configureDevice(sid,cid:cid)
            if(currentTime>=Float(totalTime)){
                nextCamera()
            }
        }else{
            
        }
    }
    var cameraID:Int16 = 0
    var sid:Int16 = 0
    var cid:Int16 = 0
    func nextCamera(){
        
        let camera:CameraModel? = DataManager.sharedManager().camera(0, cid: cameraID)!
        startTime = NSDate().timeIntervalSince1970
        totalTime = (camera?.time)!
        startFocus = (camera?.focus)!
        startISO = Float((camera?.iso)!)
        startSpeed = Float((camera?.speed)!)
        interval = (camera?.interval)!
        sid = 0
        cid = cameraID
        if(cameraID+1<DataManager.sharedManager().countOfCamera(0)){
            let nextCamera:CameraModel? = DataManager.sharedManager().camera(0, cid: cameraID+1)!
            if((nextCamera)==nil){
                stopRecord()
            }else{
                endFocus = (nextCamera?.focus)!
                endISO = Float((nextCamera?.iso)!)
                endSpeed = Float((nextCamera?.speed)!)
            }
        }else{
            isRecording = false
            let time: NSTimeInterval = 2.0
            let delay = dispatch_time(DISPATCH_TIME_NOW,Int64(time * Double(NSEC_PER_SEC)))
            dispatch_after(delay, dispatch_get_main_queue()) {
                self.stopRecord()
            }
        }
        cameraID++
    }
    
    func configureDevice(sid:Int16,cid:Int16) {
        if let device = captureDevice {
            do {
                try device.lockForConfiguration()
            }catch let error as NSError {
                print(error)
            }
            let cam:CameraModel = DataManager.sharedManager().camera(sid,cid:cid)!
            let setting:SettingModel = DataManager.sharedManager().setting(sid)!
            if(setting.resolution==0){
                captureSession!.sessionPreset = AVCaptureSessionPreset1280x720
                videoWidth = 1280
                videoHeight = 720
            }else if(setting.resolution==1){
                captureSession!.sessionPreset = AVCaptureSessionPreset1920x1080
                videoWidth = 1920
                videoHeight = 1080
            }else{
                if #available(iOS 9.0, *) {
                    captureSession!.sessionPreset = AVCaptureSessionPreset3840x2160
                    
                    videoWidth = 3840
                    videoHeight = 2160
                } else {
                    // Fallback on earlier versions
                }
            }
            isVideo = setting.mode==0
            
            device.focusMode = AVCaptureFocusMode.AutoFocus
            if(currentFocus<0){
                currentFocus = 0
            }else if(currentFocus>8000){
                currentFocus = 8000
            }
            if(currentISO<100){
                currentISO = 100
            }else if(currentISO>1600){
                currentISO = 1600
            }
            if(currentSpeed<2){
                currentSpeed = 2
            }else if(currentSpeed>8000){
                currentSpeed = 8000
            }
            if(!isRecording){
                if(cam.iso<100){
                    cam.iso = 100
                }
                currentSpeed = Float(cam.speed)
                currentFocus = cam.focus
                currentISO = Float(cam.iso)
            }
//            print(currentISO,currentSpeed,currentFocus)
            device.setFocusModeLockedWithLensPosition(currentFocus/8000.0, completionHandler: { (timestamp:CMTime) -> Void in
                
            })
            //            let conf = device.activeFormat
            //            print(conf.minExposureDuration,conf.maxExposureDuration)
            let duration:CMTime = CMTimeMake(1, Int32(max(2,currentSpeed)))
            let minISO = device.activeFormat.minISO
            let maxISO = device.activeFormat.maxISO
            device.setExposureModeCustomWithDuration(duration, ISO: (Float(currentISO-100)/1600)*(maxISO-minISO)+minISO, completionHandler: { (timestamp:CMTime) -> Void in
                
            })
            
            device.unlockForConfiguration()
        }
        
    }
    
    func beginSession() {
        captureSession = AVCaptureSession()
        configureDevice(0,cid:0)
        do {
            let device = try AVCaptureDeviceInput(device: self.captureDevice) as AVCaptureDeviceInput
            captureSession!.addInput(device)
        }catch let error as NSError {
            print(error)
        }
        
        let audioDevice:AVCaptureDevice? = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
        do{
            let audioInput:AVCaptureDeviceInput? = try AVCaptureDeviceInput(device: audioDevice!);
            captureSession!.addInput(audioInput)
        }catch let err as NSError{
            print(err)
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        //CGRect(x: 0, y: 0, width: 640, height: 1136)
        //self.view.layer.frame
        captureSession!.startRunning()
        
        
    }
    
    func configVideoView(videoView:UIView){
        if((previewLayer)==nil){
            
        }else{
            videoView.layer.addSublayer(previewLayer!)
            previewLayer?.frame =  videoView.frame
            previewLayer!.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
        }
    }
    func startRecord(){
        if((videoOutput)==nil){
        }else{
            captureSession!.removeOutput(videoOutput)
        }
        if((videoSampleOutput)==nil){
        }else{
            captureSession!.removeOutput(videoSampleOutput)
        }
        
        if(isVideo){
            
            if((videoOutput) == nil){
                self.videoOutput = AVCaptureMovieFileOutput()
            }
            if (captureSession!.canAddOutput(videoOutput)) {
                print("can add output")
                captureSession!.addOutput(videoOutput)
            }
            let paths:NSArray = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true)
            let documentsDirectoryPath:NSString! = paths.objectAtIndex(0) as! NSString
            let outputpathofmovie:String! = documentsDirectoryPath.stringByAppendingString("/\(NSDate().timeIntervalSince1970)").stringByAppendingString(".MOV");
            let outputURL:NSURL! = NSURL(fileURLWithPath: outputpathofmovie);
            print(outputURL.path)
            var videoConnection:AVCaptureConnection?;

            for connection in videoOutput!.connections
            {

                for port in (connection.inputPorts as NSArray)
                {

                    if ( port.mediaType==AVMediaTypeVideo)
                    {
                        videoConnection = connection as? AVCaptureConnection;
                    }
                }
            }
            
            videoConnection?.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
            videoOutput?.startRecordingToOutputFileURL(outputURL, recordingDelegate: self)
        }else{
            captureSession!.stopRunning()
            let paths:NSArray = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true)
            let documentsDirectoryPath:NSString! = paths.objectAtIndex(0) as! NSString
            let outputpathofmovie:String! = documentsDirectoryPath.stringByAppendingString("/\(NSDate().timeIntervalSince1970)").stringByAppendingString(".MOV");
            self.outputSampleFileURL = NSURL(fileURLWithPath: outputpathofmovie);
            do{

                try videoWriter = AVAssetWriter(URL: outputSampleFileURL!, fileType: AVFileTypeMPEG4)
                
                writerInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings:[ AVVideoCodecKey : AVVideoCodecH264,AVVideoWidthKey : String(videoWidth), AVVideoHeightKey: String(videoHeight)])
                videoWriter!.addInput(writerInput!)
                self.writeAdapter = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput!, sourcePixelBufferAttributes:[String(kCVPixelBufferPixelFormatTypeKey): String(kCVPixelFormatType_32ARGB), String(kCVPixelBufferWidthKey): String(videoWidth),String(kCVPixelBufferHeightKey): String(videoHeight)])
                writerInput!.expectsMediaDataInRealTime = true;

                videoWriter!.startWriting()
                videoWriter!.startSessionAtSourceTime(CMTimeMake(0, 24))
                print("add writer")
            }catch let err as NSError{
                print(err)
            }
            self.videoSampleOutput = AVCaptureVideoDataOutput()
            
            let recordingQueue = dispatch_queue_create("q\(NSDate().timeIntervalSince1970)", DISPATCH_QUEUE_SERIAL)
            videoSampleOutput?.setSampleBufferDelegate(self, queue: recordingQueue)
            videoSampleOutput?.alwaysDiscardsLateVideoFrames = true
            videoSampleOutput?.videoSettings = videoSampleOutput?.recommendedVideoSettingsForAssetWriterWithOutputFileType("public.mpeg-4")
            
            print(captureSession!.outputs,videoSampleOutput)
            captureSession!.addOutput(videoSampleOutput)
            captureSession!.commitConfiguration()
            captureSession!.startRunning()
            
        }
        let time: NSTimeInterval = 1.0
        let delay = dispatch_time(DISPATCH_TIME_NOW,Int64(time * Double(NSEC_PER_SEC)))
        prevTime = 0
        currentTime = 0
        frameCount = 0
        dispatch_after(delay, dispatch_get_main_queue()) {
            self.cameraID = 0
            self.isRecording = true
            self.nextCamera()
        }
    }
    func stopRecord(){
        isRecording = false
        if(isVideo){
            videoOutput?.stopRecording()
        }else{
            
            self.videoSampleOutput?.setSampleBufferDelegate(nil, queue: nil)
            self.captureSession!.removeOutput(self.videoSampleOutput)
            self.videoSampleOutput = nil
            writerInput!.markAsFinished();
            videoWriter!.endSessionAtSourceTime(CMTimeMake(Int64(Float(frameCount - 1) * Float(fps) * Float(durationForEachImage)), Int32(fps)));
            
            videoWriter!.finishWritingWithCompletionHandler({ () -> Void in
                print("finish recording")
                self.videoWriter!.cancelWriting()
                self.videoSampleOutput?.setSampleBufferDelegate(nil, queue: nil)

                self.writeAdapter = nil
                self.writerInput = nil
                self.videoSampleOutput = nil
                self.videoWriter = nil
                self.isRecording = false
                
                PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                    let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(self.outputSampleFileURL!)
                    let assetPlaceholder = assetRequest!.placeholderForCreatedAsset
                    let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: self.assetCollection)
                    let enumeration: NSArray = [assetPlaceholder!]
                    albumChangeRequest!.addAssets(enumeration)
                    }, completionHandler: { success, error in
                        self.recordBarButton?.title = "Record"
                        print("added frames to album")
                        print(error)
                        let fileManager:NSFileManager? = NSFileManager.defaultManager()
                        do{
                            try fileManager?.removeItemAtURL(self.outputSampleFileURL!)
                        }catch let err as NSError {
                            print(err)
                        }
                })
            });
        }
        NSNotificationCenter.defaultCenter().postNotificationName("STOP_RECORDING", object: nil, userInfo: nil)
    }
    
    var assetCollection: PHAssetCollection!
    var albumFound : Bool = false
    var photosAsset: PHFetchResult!
    var assetThumbnailSize:CGSize!
    var collection: PHAssetCollection!
    var assetCollectionPlaceholder: PHObjectPlaceholder!
    
    func createAlbum() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", "Motion Maker")
        let collection : PHFetchResult = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: fetchOptions)
        
        if let first_obj: AnyObject = collection.firstObject {
            self.albumFound = true
            assetCollection = collection.firstObject as! PHAssetCollection
        } else {
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                let createAlbumRequest : PHAssetCollectionChangeRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle("Motion Maker")
                self.assetCollectionPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
                }, completionHandler: { success, error in
                    self.albumFound = (success ? true: false)
                    
                    if (success) {
                        let collectionFetchResult = PHAssetCollection.fetchAssetCollectionsWithLocalIdentifiers([self.assetCollectionPlaceholder.localIdentifier], options: nil)
                        print(collectionFetchResult)
                        self.assetCollection = collectionFetchResult.firstObject as! PHAssetCollection
                    }
            })
        }
    }
    var frameCount:Int16 = 0
    let fps:Int16 = 24
    let durationForEachImage:Float = 0.05
    //0416
    func captureImage(){
//        let videoConnection = imageOutput?.connectionWithMediaType(AVMediaTypeVideo)
//        imageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { (buff, error) -> Void in
//            let imageData:NSData? = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buff)
//            let frameTime:CMTime = CMTimeMake(Int64(self.frameCount * self.fps * self.durationForEachImage), Int32(self.fps));
//            
//            //self.appendPixelBufferForImageData(imageData!, pixelBufferAdaptor: self.writeAdapter!, presentationTime: frameTime)
//            
//            self.frameCount++;
//
//        })
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {

        if(currentTime-prevTime>interval){
            prevTime = currentTime
            print("append frame")
            let frameTime:CMTime = CMTimeMake(Int64(Float(self.frameCount) * Float(self.fps) * self.durationForEachImage), Int32(self.fps))
            if(self.writerInput!.readyForMoreMediaData){
                self.writeAdapter?.appendPixelBuffer(CMSampleBufferGetImageBuffer(sampleBuffer)!, withPresentationTime: frameTime)
                self.frameCount++
            }
        }
    }
    func captureOutput(captureOutput: AVCaptureOutput!, didDropSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        print("drop")
    }
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        print("capture output : finish recording to \(outputFileURL) \(error)")
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(outputFileURL)
            let assetPlaceholder = assetRequest!.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: self.assetCollection)
            let enumeration: NSArray = [assetPlaceholder!]
            albumChangeRequest!.addAssets(enumeration)
            }, completionHandler: { success, error in
                print("added video to album")
                print(error)
                let fileManager:NSFileManager? = NSFileManager.defaultManager()
                do{
                    try fileManager?.removeItemAtURL(outputFileURL)
                }catch let err as NSError {
                    print(err)
                }
        })
        
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        print("capture output: started recording to \(fileURL)")
    }
}

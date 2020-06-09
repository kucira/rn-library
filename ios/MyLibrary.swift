//
//  Dot.swift
//  DotReactNative
//
//  Created by Pavol Porubský on 18/12/2019.
//  Copyright © 2019 Facebook. All rights reserved.
//

import UIKit
import DOT
import AVKit
import ekyc_ios_v2


@objc(MyLibrary)
class MyLibrary: NSObject {
  let strongDelegate = GeneralDelegate()
  var templateInt = [Int8]()

  @objc func initializeBiometricLicense (_ licenseBase64: String,resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {
    print("license from reactnative")
    print(licenseBase64)

    let decodedData = Data(base64Encoded: licenseBase64)!
    let decodedString = String(data: decodedData, encoding: .utf8)!

    print(decodedString)

    let fileName = "iengine.lic"

    self.save(text: decodedString,
              toDirectory: self.documentDirectory(),
              withFileName: fileName)
    if let path = self.append(toPath: self.documentDirectory(),
    withPathComponent: fileName){
      do {
        print("path")
        print(path)
        let license = try License(path: path)
        DOTHandler.initialize(with: license)
        resolve(DOTHandler.licenseId)
      } catch {
        reject("Error", "license error", error)
      }
    }
  }
  
  @objc func startBiometricCaptureActivity (_ minX: Float,maximum maxX:Float ,resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {
    print("minX & MaxX from reactnative")
    print(minX)
    print(maxX)
//  let parseData = ["minimal":minX,
//                   "maximal":maxX]
//  callforstartBiometric(parseData:  parseData as NSDictionary)
//  onStartBiometricSelfieClick(parseData:  parseData as NSDictionary)
    DispatchQueue.main.async {
      print("call framework")
      let rootVC = UIApplication.shared.delegate!.window!!.rootViewController
      
      let controller = BioRegistrationViewController()
      controller.modalPresentationStyle = .fullScreen
      controller.minFaceRatio = 0.1
      controller.maxFaceRatio = 0.34
      
      
      self.strongDelegate.selfieImageHandler = { imagePath, template in
        DispatchQueue.main.async {
          controller.dismiss(animated: false) {
            resolve(["path": imagePath, "template": template])
            //                  self.labelSelfieImage.text = ": " + imagePath
            //                  self.applicationDelegate.pathimage = imagePath
            //                  self.faceTemplate = template
          }
        }
      }
      controller.delegate = self.strongDelegate
      // ini yang jadi issue
      rootVC?.present(controller, animated: false, completion: nil)
      print("show framework")
      
      //      navigationController?.pushViewController(controller, animated: true)
    }
  }
  
  /*
   
   RCT_EXTERN_METHOD(startBiometricCaptureActivity:(float)minX maximum:(float)maxX resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)

   RCT_EXTERN_METHOD(startBiometricCaptureSimpleActivity:(float)minX maximum:(float)maxX count:(float)counter resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)

   RCT_EXTERN_METHOD(startBiometricLivenessCheckActivity:(float)minX maximum:(float)maximum template:(Int8)biometricTemplate  resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)

   RCT_EXTERN_METHOD(startBiometricVerificationActivity:(float)minX maximum:(float)maxX template:(Int8)biometricTemplate resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)

   
   */
  
  
  @objc func startBiometricCaptureSimpleActivity (_ minX: Float,maximum maxX:Float, count counter:(Float) ,resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {
      print("minX & MaxX & counter from reactnative")
      print(minX)
      print(maxX)
      print(counter)
    
//    onStartBiometricSelfieClick(parseData:  parseData as NSDictionary)
    
    DispatchQueue.main.async {
      print("call framework")
      let rootVC = UIApplication.shared.delegate!.window!!.rootViewController
      
      let controller = BioRegistrationViewController()
      controller.modalPresentationStyle = .fullScreen
      controller.minFaceRatio = 0.1
      controller.maxFaceRatio = 0.34
      
      controller.accessPubClass()
      
      self.strongDelegate.selfieImageHandler = { imagePath, template in
        DispatchQueue.main.async {
          controller.dismiss(animated: false) {
            print("call back to react native")
            resolve(["path": imagePath, "template": template])
            //                  self.labelSelfieImage.text = ": " + imagePath
            //                  self.applicationDelegate.pathimage = imagePath
            //                  self.faceTemplate = template
          }
        }
      }
      controller.delegate = self.strongDelegate
      // ini yang jadi issue
      rootVC?.present(controller, animated: false, completion: nil)
      print("show framework")
      
      //      navigationController?.pushViewController(controller, animated: true)
    }

  }
  
  @objc func startBiometricLivenessCheckActivity (_ minX: Float,maximum maxX:Float, template biometricTemplate:(String) ,resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {
    print("minX & MaxX & template from reactnative")
    print(minX)
    print("maxX")
    print(maxX)
    

          
    
    DispatchQueue.main.async {
      let rootVC = UIApplication.shared.delegate!.window!!.rootViewController
      
      
      let configuration: Liveness2Configuration
      let style: LivenessCheckStyle
      
      configuration = Liveness2Configuration(transitionType: .move) {
        $0.segments = [
          DOTSegment(targetPosition: .bottomRight, duration: 1000),
          DOTSegment(targetPosition: .bottomLeft, duration: 1000),
          DOTSegment(targetPosition: .topRight, duration: 1000),
          DOTSegment(targetPosition: .bottomRight, duration: 1000),
          DOTSegment(targetPosition: .topLeft, duration: 1000),
          DOTSegment(targetPosition: .bottomLeft, duration: 1000)]
        $0.minValidSegmentsCount = 5
        $0.minFaceSizeRatio = Double(minX) //0.1
        $0.maxFaceSizeRatio = Double(maxX) //0.28
        //                let image = UIImage(named: "liveness_image.png", in: Bundle(for: type(of: self)), compatibleWith: nil)
        let imageName = "liveness_image.png"
        let image = UIImage(named: imageName)
        $0.dotImage = image
      }
      
      style = .init()
      style.background = .white
      
      let lvc = LivenessCheck2Controller.create(configuration: configuration, style: .init())
      //      self.strongDelegate.livenessScoreHandler = { score in
      //        lvc.dismiss(animated: true) {
      //          print("finish??")
      //          print("Score")
      //          print(score)
      //
      ////          if let imageBase64String = faceImage.pngData()?.base64EncodedString().prefix(20) {
      ////            resolve(["score": score, "photoUri": imageBase64String])
      //          }
      //        }
      lvc.modalPresentationStyle = .fullScreen

      self.strongDelegate.livenessCheckHandler = { score, faceImage in
        lvc.dismiss(animated: true) {
          if let imageBase64String = faceImage.pngData()?.base64EncodedString().prefix(20) {
            resolve(["score": score, "photoUri": imageBase64String])
          }
        }
      }
      lvc.delegate = self.strongDelegate
      rootVC?.present(lvc, animated: false, completion: nil)
    }
  }

  @objc func startBiometricVerificationActivity (_ minX: Float,maximum maxX:Float, template biometricTemplate:(String) ,resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {
    print("minX & MaxX & template from reactnative")
    print(minX)
    print(maxX)
//    print(biometricTemplate)
//  let parseData = ["minimal":minX,
//                   "maximal":maxX,
//                   "template":biometricTemplate] as [String : Any]
//  callforstartBiometric(parseData:  parseData as NSDictionary)
    DispatchQueue.main.async {
      let controller = BioVerificationViewController()
      controller.modalPresentationStyle = .fullScreen
      let rootVC = UIApplication.shared.delegate!.window!!.rootViewController
      
      self.templateInt = [73, 67, 70, 0, 49, 72, -46, 98, 44, -63, 80, -9, 114, -65, 44, -110, 37, -57, -83, 9, 121, 70, 36, 111, -46, 58, -86, 4, -113, 74, 41, 106, -44, -61, -89, -11, -120, -65, 38, -108, 46, 62, 85, 3, 119, 79, -43, -108, -46, 61, 86, -3, -113, -70, -43, 107, 44, 63, -83, 1, -122, 73, -39, -107, 40, -59, -82, -5, 121, -71, 46, -107, 43, -57, 82, 2, 116, 64, -43, 110, -40, -61, -83, -2, 114, 69, -48, 111, -37, -60, 87, -1, -120, 64, -45, -112, 44, -63, -88, 1, -119, 66, 47, -105, 47, 56, -87, -1, 112, 71, -44, 110, -42, -60, -82, -6, 112, 71, -45, 111, -46, -57, -92, -9, -124, 64, 46, 111, -46, -59, 87, -7, -113, 64, 42, 106, 46, 63, 83, -12, 113, 69, 41, -104, -61, -58, 87, 7, 113, 66, 43, 103, -41, 56, -81, -12, -114, 69, 47, -109, 42, 56, -84, -4, -120, -66, -34, -110, 45, -58, 82, 2, -120, 69, 42, 106, 42, -64, -83, -1, 114, 69, 40, 111, -48, -51, 83, -12, 112, -69, 46, 111, 45, 56, 86, 6, 112, -69, -45, -107, -45, -64, -89, 2, 123, -69, 39, -106, -41, -59, 86, 1, -115, 64, 44, -101, -40, -58, 84, 10, 123, 68, 43, -105, -47, -57, -82, -5, 114, 68, 43, 108, -47, -64, 87, 3, -120, -66, 39, 105, 47, 63, -81, 2, 121, 87, 35, 111, -42, 57, -83, 3, 118, 66, 46, -107, -41, 58, -88, -1, -119, 67, -46, 110, 44, -51, -85, 1, 117, -72, 46, 104, -46, 51, 81, -3, 112, -72, 45, -108, 45, -52, 82, -6, -119, -72, 46, -110, -46, -59, -82, -4, 119, -70, -42, -105, -42, 62, 82, -3, 120, 64, 36, -105, -41, -50, -82, -6, 127, -79, -47, 110, 42, 59, 86, -2, -114, 64, 47, 111, -48, 58, -87, -9, 112, 69, 47, -108, -43, 57, 86, 7, -117, 67, 43, -112, -33, 56, 80, -4, 117, -69, 38, -107, -41, -62, 80, 2, -116, 78, 47, -107, -45, -63, -87, -9, -114, 68, 47, 107, -46, 56, 80, 5, 113, -70, -42, -111, -45, -55, 82, -7, 122, 66, -41, -108, 43, 61, -82, 3, -114, 70, -36, -112, -43, 57, 83, -3, -118, -71, -44, 110, -47, 48, 82, -4, -118, 64, 45, 110, -43, 59, -82, 11, 116, -66, 45, 111, -45, 63, -82, -7, -115, 65, -45, 109, 44, 62, 85, -2, -114, -68, 42, -108, 40, 63, -88, -2, 118, 79, -46, -112, 46, -57, 81, 0, -114, -78, 39, -112, -48, -61, 88, 11, 113, 68, -48, 106, 42, -52, 84, -1, -119, -71, 44, -101, 42, -64, 91, -5, 118, -68, 47, 99, 45, -51, 86, 3, 122, -66, 45, 110, 38, -58, -92, 8, 118, -79, 46, 106, -47, 62, -85, 10, 120, -69, -39, -110, 41, -60, -81, -14, -124, -67, 40, 110, 46, -63, 87, -2, -116, 70, -43, -110, 44, 63, -81, -4, 119, 66, 45, -109, -45, -59, 87, 10, 113, -68, -66, 16, -98, -1]
      
//      print(templateInt)
      controller.intTemplate = self.templateInt
      controller.minFaceRatio = 0.1
      controller.maxFaceRatio = 0.34
      self.strongDelegate.biometricVerificationHandler = { score in
        DispatchQueue.main.async {
          controller.dismiss(animated: false) {
            print("score nya verification")
            print(score)
            resolve(["score": score, "photoUri": "imageBase64String"])
            //                      self.lavelVerificationScore.text = ": " + String(score)
          }
        }
      }
      controller.delegate = self.strongDelegate
      //          navigationController?.pushViewController(controller, animated: true)
      
      rootVC?.present(controller, animated: false, completion: nil)
    }
  }
  
  private func documentDirectory() -> String {
      let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                  .userDomainMask,
                                                                  true)
      return documentDirectory[0]
  }
  
  private func append(toPath path: String,
                      withPathComponent pathComponent: String) -> String? {
      if var pathURL = URL(string: path) {
          pathURL.appendPathComponent(pathComponent)
          
          return pathURL.absoluteString
      }
      
      return nil
  }
  
  private func read(fromDocumentsWithFileName fileName: String) {
      guard let filePath = self.append(toPath: self.documentDirectory(),
                                       withPathComponent: fileName) else {
                                          return
      }
      
      do {
          let savedString = try String(contentsOfFile: filePath)
          
          print(savedString)
      } catch {
          print("Error reading saved file")
      }
  }
  
  private func save(text: String,
                    toDirectory directory: String,
                    withFileName fileName: String) {
      guard let filePath = self.append(toPath: directory,
                                       withPathComponent: fileName) else {
          return
      }
      
      do {
          try text.write(toFile: filePath,
                         atomically: true,
                         encoding: .utf8)
      } catch {
          print("Error", error)
          return
      }
      
      print("Save successful")
  }
  
  
  
  
  
  
    
//  private let strongDelegate = GeneralDelegate()
//  @objc
//  func startDocumentCaptureActivity(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {
//    DispatchQueue.main.async {
//      let rootVC = UIApplication.shared.delegate!.window!!.rootViewController
//      let dvc = DocumentCaptureViewController()
//      self.strongDelegate.documentcaptureHandler = { photo in
//        dvc.dismiss(animated: true) {
//          resolve(photo.pngData()?.base64EncodedString())
//        }
//      }
//      dvc.delegate = self.strongDelegate
//      rootVC?.present(dvc, animated: false, completion: nil)
//    }
//  }
//
//  @objc
//  func startLivenessCheckActivity(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
//    DispatchQueue.main.async {
//      let rootVC = UIApplication.shared.delegate!.window!!.rootViewController
//      let lvc = LivenessCheck2Controller.create(with: Liveness2Configuration(transitionType: .move), style: .init())
//      self.strongDelegate.livenessCheckHandler = { score, faceImage in
//        lvc.dismiss(animated: true) {
//          if let imageBase64String = faceImage.pngData()?.base64EncodedString().prefix(20) {
//            resolve(["score": score, "photoUri": imageBase64String])
//          }
//        }
//      }
//      lvc.delegate = self.strongDelegate
//      rootVC?.present(lvc, animated: false, completion: nil)
//    }
//
//  }
//
//  @objc
//  static func requiresMainQueueSetup() -> Bool {
//    return true
//  }
  
  func onStartBiometricSelfieClick(parseData: NSDictionary) {
    DispatchQueue.main.async {
print("call framework")
      let rootVC = UIApplication.shared.delegate!.window!!.rootViewController

      let controller = BioRegistrationViewController()
      controller.modalPresentationStyle = .fullScreen
      controller.minFaceRatio = 0.1
      controller.maxFaceRatio = 0.34


      self.strongDelegate.selfieImageHandler = { imagePath, template in
        DispatchQueue.main.async {
          controller.dismiss(animated: false) {
//            resolve(template)
            //                  self.labelSelfieImage.text = ": " + imagePath
            //                  self.applicationDelegate.pathimage = imagePath
            //                  self.faceTemplate = template
          }
        }
      }
      controller.delegate = self.strongDelegate
      // ini yang jadi issue
      rootVC?.present(controller, animated: false, completion: nil)
      print("show framework")

//      navigationController?.pushViewController(controller, animated: true)
    }
  }
  
  func onStartBiometricLivenessClick() {
          let controller = PhotoConfirmationViewController()
          controller.modalPresentationStyle = .fullScreen
          templateInt = [73, 67, 70, 0, 49, 67, -48, 111, -41, -60, 86, -4, 115, 65, 47, -111, 46, 63, 81, -4, -126, 78, -44, 107, 39, -61, 89, -15, 114, -70, -43, -99, 40, -55, 82, 6, -115, 68, -45, -107, -39, 58, -92, -7, 112, 71, 44, -109, -47, 57, 82, 3, -115, 71, -46, 110, -45, -63, 80, 9, -116, 68, 37, -107, 44, 51, -84, -8, 123, 76, 47, -109, 32, 58, 82, -11, -114, 66, -48, 110, -47, -63, -89, -2, -121, 65, 47, -109, -37, -63, -83, 5, 114, -71, -43, -110, 44, 59, -87, 0, -124, -71, -43, 109, -45, -51, 83, 6, 116, -71, 47, 110, 44, 62, 80, 7, 119, 67, 41, 110, 40, -58, -84, 11, 115, -72, -48, -104, 36, -60, 83, -7, -116, -69, 47, 100, -33, -59, 84, -12, -113, -65, 32, 110, 41, 58, 80, -8, -128, -70, -43, 111, 46, -49, 86, -2, 115, 71, 44, 104, -45, 59, 87, 1, -113, 77, 44, 109, 42, -61, -82, 5, -120, -70, -48, 110, 47, -57, 81, 4, -124, 65, 36, -104, -43, -57, 85, -2, -120, 77, 46, -105, -47, -61, 87, 10, 114, 71, 38, -107, 42, -58, 90, -8, 116, 69, -44, -107, -41, 60, 86, -3, -120, -67, 44, -104, -47, 60, 87, -1, 113, 70, 43, -103, 39, -51, -88, -2, -120, 68, 47, -106, -41, -64, -84, -3, -113, 67, -43, -112, 47, 51, 88, -1, -119, 71, 37, 109, -45, -64, -91, -6, -118, -70, 40, -110, -41, -52, 83, 7, 113, 65, -45, -112, 44, -61, 91, 5, -124, -70, -45, -103, -44, 60, -84, -2, 121, 64, -47, 109, 43, 56, -83, -7, -120, 64, 46, 110, -33, 58, 83, 3, -119, -66, 40, -104, 41, -52, -87, 3, -121, 64, 40, 107, -45, -59, 80, 6, -119, 69, 43, 110, 42, -50, 82, 1, 115, 70, -48, -109, 41, -49, 90, -8, 118, -70, -39, 110, -42, 60, 86, 3, 113, 69, -43, 111, 41, -55, -81, -1, -116, -65, -42, -107, -46, 57, -81, -6, 119, 64, -39, -110, -47, 57, 90, -4, 115, 78, 43, 103, -37, 56, 91, -1, 117, 71, 38, -105, 37, 59, 84, 2, -118, -65, 41, 110, 33, -63, -81, -1, 122, 71, -47, 96, 46, 60, -88, -3, 115, 65, -45, -112, -42, -64, 83, 7, -120, 67, 45, -103, -47, -63, 91, 0, 115, 65, -45, -112, -43, 62, 82, -3, -114, 69, 40, 106, -61, -60, -82, -2, -115, 66, 46, 102, 41, 63, -86, 3, 113, 69, -48, 111, -44, 57, -88, 6, 122, -66, 47, -111, 44, -57, 82, -3, 112, 69, -63, 111, 41, 58, -85, 1, 127, -72, 43, 111, -48, 63, 83, -4, -113, 66, -45, -110, -46, 56, -86, 2, 116, 78, 47, -107, 45, -59, -89, -3, 112, 78, -48, 106, -45, 50, -83, -2, -116, -67, -48, -110, -42, 57, -85, -2, 115, 76, 40, 99, 47, -51, -84, -3, 122, 67, -43, -112, -48, -52, -88, -6, 117, 67, -44, 108, 40, 62, -82, 3, -119, 67, 70, 8, 121, -1]
          
      let rootVC = UIApplication.shared.delegate!.window!!.rootViewController

          print(templateInt)
          controller.intTemplate = self.templateInt
          controller.minFaceRatio = 0.1
          controller.maxFaceRatio = 0.28
          self.strongDelegate.livenessScoreHandler = { score in
              controller.dismiss(animated: false) {
//                  self.labelLivenessScore.text = ": " + String(score)
              }
          }
          controller.delegate = self.strongDelegate
  //        controller.faceCaptureImage = retrieveImage(forKey: "faceImage", inStorageType: .fileSystem)
          controller.flagSuccess = 1
//          navigationController?.pushViewController(controller, animated: true)
          rootVC?.present(controller, animated: false, completion: nil)
      }

  func onStartBiometricVerificationClick() {
    let controller = BioVerificationViewController()
    controller.modalPresentationStyle = .fullScreen
    let rootVC = UIApplication.shared.delegate!.window!!.rootViewController
    
    templateInt = [73, 67, 70, 0, 49, 67, -48, 111, -41, -60, 86, -4, 115, 65, 47, -111, 46, 63, 81, -4, -126, 78, -44, 107, 39, -61, 89, -15, 114, -70, -43, -99, 40, -55, 82, 6, -115, 68, -45, -107, -39, 58, -92, -7, 112, 71, 44, -109, -47, 57, 82, 3, -115, 71, -46, 110, -45, -63, 80, 9, -116, 68, 37, -107, 44, 51, -84, -8, 123, 76, 47, -109, 32, 58, 82, -11, -114, 66, -48, 110, -47, -63, -89, -2, -121, 65, 47, -109, -37, -63, -83, 5, 114, -71, -43, -110, 44, 59, -87, 0, -124, -71, -43, 109, -45, -51, 83, 6, 116, -71, 47, 110, 44, 62, 80, 7, 119, 67, 41, 110, 40, -58, -84, 11, 115, -72, -48, -104, 36, -60, 83, -7, -116, -69, 47, 100, -33, -59, 84, -12, -113, -65, 32, 110, 41, 58, 80, -8, -128, -70, -43, 111, 46, -49, 86, -2, 115, 71, 44, 104, -45, 59, 87, 1, -113, 77, 44, 109, 42, -61, -82, 5, -120, -70, -48, 110, 47, -57, 81, 4, -124, 65, 36, -104, -43, -57, 85, -2, -120, 77, 46, -105, -47, -61, 87, 10, 114, 71, 38, -107, 42, -58, 90, -8, 116, 69, -44, -107, -41, 60, 86, -3, -120, -67, 44, -104, -47, 60, 87, -1, 113, 70, 43, -103, 39, -51, -88, -2, -120, 68, 47, -106, -41, -64, -84, -3, -113, 67, -43, -112, 47, 51, 88, -1, -119, 71, 37, 109, -45, -64, -91, -6, -118, -70, 40, -110, -41, -52, 83, 7, 113, 65, -45, -112, 44, -61, 91, 5, -124, -70, -45, -103, -44, 60, -84, -2, 121, 64, -47, 109, 43, 56, -83, -7, -120, 64, 46, 110, -33, 58, 83, 3, -119, -66, 40, -104, 41, -52, -87, 3, -121, 64, 40, 107, -45, -59, 80, 6, -119, 69, 43, 110, 42, -50, 82, 1, 115, 70, -48, -109, 41, -49, 90, -8, 118, -70, -39, 110, -42, 60, 86, 3, 113, 69, -43, 111, 41, -55, -81, -1, -116, -65, -42, -107, -46, 57, -81, -6, 119, 64, -39, -110, -47, 57, 90, -4, 115, 78, 43, 103, -37, 56, 91, -1, 117, 71, 38, -105, 37, 59, 84, 2, -118, -65, 41, 110, 33, -63, -81, -1, 122, 71, -47, 96, 46, 60, -88, -3, 115, 65, -45, -112, -42, -64, 83, 7, -120, 67, 45, -103, -47, -63, 91, 0, 115, 65, -45, -112, -43, 62, 82, -3, -114, 69, 40, 106, -61, -60, -82, -2, -115, 66, 46, 102, 41, 63, -86, 3, 113, 69, -48, 111, -44, 57, -88, 6, 122, -66, 47, -111, 44, -57, 82, -3, 112, 69, -63, 111, 41, 58, -85, 1, 127, -72, 43, 111, -48, 63, 83, -4, -113, 66, -45, -110, -46, 56, -86, 2, 116, 78, 47, -107, 45, -59, -89, -3, 112, 78, -48, 106, -45, 50, -83, -2, -116, -67, -48, -110, -42, 57, -85, -2, 115, 76, 40, 99, 47, -51, -84, -3, 122, 67, -43, -112, -48, -52, -88, -6, 117, 67, -44, 108, 40, 62, -82, 3, -119, 67, 70, 8, 121, -1]
    
    print(templateInt)
    controller.intTemplate = self.templateInt
    controller.minFaceRatio = 0.1
    controller.maxFaceRatio = 0.34
    self.strongDelegate.biometricVerificationHandler = { score in
      DispatchQueue.main.async {
        controller.dismiss(animated: false) {
          //                      self.lavelVerificationScore.text = ": " + String(score)
        }
      }
    }
    controller.delegate = self.strongDelegate
    //          navigationController?.pushViewController(controller, animated: true)
    
    rootVC?.present(controller, animated: false, completion: nil)
  }
}

class GeneralDelegate {
  
  var score: Float?
  var faceImage: UIImage?
  
  var documentcaptureHandler: ((UIImage) -> Void)?
  var livenessCheckHandler: ((Float, UIImage) -> Void)?

  var livenessScoreHandler: ((Float) -> Void)?
  
  var selfieImageHandler: ((String, String) -> Void)?
  
  var biometricVerificationHandler: ((Float) -> Void)?

}

func callForLicenseInit(licenseData: NSString){
  print("license from reactnative parse to func")
  print(licenseData)
}

func callforstartBiometric(parseData: NSDictionary){
  print("Minx and maxX from reactnative parse to func")
  print(parseData.description)
}




extension GeneralDelegate: PhotoConfirmationControllerDelegate {
    func succesVerification(score: Float) {
    }
    
    func didLivenessSuccess(score: Float, image: Array<String>, position: Array<String>) {
        livenessScoreHandler?(score)
    }
}

extension GeneralDelegate: BioRegistrationViewControllerDelegate {
    func didSelfieSuccess(imagePath: String, template: String) {
        selfieImageHandler?(imagePath, template)
    }
    
}

extension GeneralDelegate: BioVerificationViewControllerDelegate {
    
    func didVerificationSuccess(score: Float){
        print("score nya di myview")
        print(score)
        biometricVerificationHandler?(score)
    }

}

extension GeneralDelegate: LivenessCheck2ControllerDelegate {
  func livenessCheck2InitialStart(_ controller: LivenessCheck2Controller) -> Bool {
    return true
  }
  
  func livenessCheck2CameraInitFailed(_ controller: LivenessCheck2Controller) {
    
  }
  
  func livenessCheck2(_ controller: LivenessCheck2Controller, livenessStateChanged state: LivenessContextState) {
    
  }
  
  func livenessCheck2(_ controller: LivenessCheck2Controller, checkDoneWith score: Float, capturedSegmentImages segmentImagesList: [SegmentImage]) {
    self.score = score
    if let faceImage = faceImage {
      livenessCheckHandler?(score, faceImage)
    }
  }
  
  func livenessCheck2FaceCaptureFailed(_ controller: LivenessCheck2Controller) {
    
  }
  
  func livenessCheck2NoMoreSegments(_ controller: LivenessCheck2Controller) {
    
  }
  
  func livenessCheck2NoEyesDetected(_ controller: LivenessCheck2Controller) {
    
  }
  
  func livenessCheck2(_ controller: LivenessCheck2Controller, captureStateChanged captureState: FaceCaptureState, withImage image: DOTImage?) {
    
  }
  
  func livenessCheck2(_ controller: LivenessCheck2Controller, didSuccess detectedFace: DetectedFace) {
    faceImage = detectedFace.cropedFace
    if let score = score, let faceImage = faceImage {
      livenessCheckHandler?(score, faceImage)
    }
  }
  
  func livenessCheck2DidAppear(_ controller: LivenessCheck2Controller) {
    controller.startLivenessCheck()
  }
}

//extension GeneralDelegate: DocumentCaptureViewControllerDelegate {
//  func didTakePhoto(_ photo: UIImage) {
//    documentcaptureHandler?(photo)
//  }
//
//  func didPressRightBarButton(for viewController: DocumentCaptureViewController) {
//
//  }
//}
//
//extension GeneralDelegate: LivenessCheck2ControllerDelegate {
//  func livenessCheck2InitialStart(_ controller: LivenessCheck2Controller) -> Bool {
//    return true
//  }
//
//  func livenessCheck2CameraInitFailed(_ controller: LivenessCheck2Controller) {
//
//  }
//
//  func livenessCheck2(_ controller: LivenessCheck2Controller, livenessStateChanged state: LivenessContextState) {
//
//  }
//
//  func livenessCheck2(_ controller: LivenessCheck2Controller, checkDoneWith score: Float, capturedSegmentImages segmentImagesList: [SegmentImage]) {
//    self.score = score
//    if let faceImage = faceImage {
//      livenessCheckHandler?(score, faceImage)
//    }
//  }
//
//  func livenessCheck2FaceCaptureFailed(_ controller: LivenessCheck2Controller) {
//
//  }
//
//  func livenessCheck2NoMoreSegments(_ controller: LivenessCheck2Controller) {
//
//  }
//
//  func livenessCheck2NoEyesDetected(_ controller: LivenessCheck2Controller) {
//
//  }
//
//  func livenessCheck2(_ controller: LivenessCheck2Controller, captureStateChanged captureState: FaceCaptureState, with image: DOTImage?) {
//
//  }
//
//  func livenessCheck2(_ controller: LivenessCheck2Controller, didSuccess detectedFace: DetectedFace) {
//    faceImage = detectedFace.cropedFace
//    if let score = score, let faceImage = faceImage {
//      livenessCheckHandler?(score, faceImage)
//    }
//  }
//
//  func livenessCheck2DidAppear(_ controller: LivenessCheck2Controller) {
//    controller.startLivenessCheck()
//  }
//}


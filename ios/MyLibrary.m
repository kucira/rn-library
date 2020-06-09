//
//  Dot.m
//  DotReactNative
//
//  Created by Pavol Porubský on 18/12/2019.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "React/RCTBridgeModule.h"

@interface RCT_EXTERN_MODULE(MyLibrary, NSObject)

RCT_EXTERN_METHOD(initializeBiometricLicense:(NSString*)LicenseBase64 resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(startBiometricCaptureActivity:(float)minX maximum:(float)maxX resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(startBiometricCaptureSimpleActivity:(float)minX maximum:(float)maxX count:(float)counter resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(startBiometricLivenessCheckActivity:(float)minX maximum:(float)maximum template:(NSString*)biometricTemplate  resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(startBiometricVerificationActivity:(float)minX maximum:(float)maxX template:(NSString*)biometricTemplate resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)

@end

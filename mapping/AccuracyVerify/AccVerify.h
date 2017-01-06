//
// Created by Richard on 2016/12/7.
// Copyright (c) 2016 sailstech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <locating/SailsMapCommon.h>
#import <locating/Sails.h>
#import <UIKit/UIKit.h>
@class PFObject;
@class POI;
@class CheckPoint;

@interface AccVerify : NSObject

+ (NSString *)GetSamples;

+ (NSString *)GetAccuracy;

+ (NSString *)GetDeviation;

+ (void)StartAccVerifyWithView:(UIView *)view ProjectObject:(PFObject *)project GeneralIconDict:(NSMutableDictionary *)general HighlightIconDict:(NSMutableDictionary *)highlight CheckIconDict:(NSMutableDictionary *)check SailsMapView:(SailsLocationMapView *)sailsMapView Floor:(NSString *)floor;


+ (void)ShowFloorPOIsWithSAILSMapView:(SailsLocationMapView *)sailsLocationMapView Floor:(NSString *)floor;

+ (void)InitParameters;


+ (void)ClearMeasurementResult:(SailsLocationMapView *)sailsMapView;

+ (void)StopAccVerifyWithSailsMapView:(SailsLocationMapView *)view;


+ (CheckPoint *)GetCurrentCheckPoint;

+ (NSString *)CheckCheckPointIsTouchedWithPoint:(CGPoint)point sails:(Sails *)sails sailsMap:(SailsLocationMapView *)map;

+ (void)ClearCurrentCheckPoint;

+ (void)Sample:(SailsLocationMapView *)view;

+ (void)CalculateAccuracy;

+ (NSString *)SaveToCSVFile:(NSString *)title;
@end
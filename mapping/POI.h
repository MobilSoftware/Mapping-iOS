//
// Created by Richard on 2016/12/7.
// Copyright (c) 2016 sailstech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/PFObject.h>
#import "PFSubclassing.h"
#import <UIKit/UIKit.h>

@class GeoPoint;
@class Marker;
enum Type {
    GENERAL,
    HIGHLIGHT,
    CHECK
};
@interface POI : PFObject<PFSubclassing>
+ (NSString *)parseClassName;

- (Marker *)marker;

- (void)setMarkerGeneral:(UIImage *)generalIcon Highlight:(UIImage *)highlightIcon Check:(UIImage *)checkIcon;

- (void)setHighlightEnabled:(BOOL *)hl;

- (void)setIconType:(enum Type)type;

- (GeoPoint *)getGeoPoint;

- (bool)isThisFloor:(NSString *)floor;

- (void)setLocationWithGeoPoint:(GeoPoint *)geoPoint floor:(NSString *)floor;
@property NSNumber *lon;
@property NSNumber *lat;
@property NSString *floor;
@end

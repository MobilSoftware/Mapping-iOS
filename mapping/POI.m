//
// Created by Richard on 2016/12/7.
// Copyright (c) 2016 sailstech. All rights reserved.
//

#import "POI.h"
#import <Parse/PFObject+Subclass.h>
#import <locating/SailsMapCommon.h>


@implementation POI {

    UIImage *general;
    UIImage *highlight;
    UIImage *check;
    BOOL *isHighlight;
    Marker* marker;

}

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"POI";
}
-(Marker*) marker {
    return marker;
}
-(void) setMarkerGeneral:(UIImage *) generalIcon
               Highlight:(UIImage *) highlightIcon
                   Check:(UIImage *) checkIcon
{
    general =generalIcon;
    highlight=highlightIcon;
    check=checkIcon;
    [self setHighlightEnabled:isHighlight];

}
-(void) setHighlightEnabled:(BOOL*) hl
{
    if(!self[@"lat"]||!self[@"lon"])
        return;
    UIImage *icon;
    if(hl) {
        icon=highlight;
    } else {
        icon=general;
    }
    if(!marker) {
        marker = [[Marker alloc] initWithGeoPoint:[[GeoPoint alloc] initWithLogitude:[self[@"lon"] doubleValue]
                                                                           latitude:[self[@"lat"] doubleValue]]
                                        andImage:icon andMarkerFrame:36 andIsBoundCenter:true];
    } else {
        [marker setImage:icon];
    }
    isHighlight=hl;
}
-(void) setIconType:(enum Type) type
{
    UIImage *icon=general;
    switch(type) {

        case GENERAL:
            icon=general;
            isHighlight=false;
            break;
        case HIGHLIGHT:
            icon=highlight;
            isHighlight=true;
            break;
        case CHECK:
            icon=check;
            isHighlight=false;
            break;
    }
    if(!marker)
        marker= [[Marker alloc] initWithGeoPoint:[[GeoPoint alloc] initWithLogitude:[self[@"lon"] doubleValue]
                                                                           latitude:[self[@"lat"] doubleValue]]
                                        andImage:icon andMarkerFrame:36 andIsBoundCenter:true];
    else
        [marker setImage:icon];
}
-(GeoPoint*) getGeoPoint
{
 if(!self[@"lat"]||!self[@"lon"])
     return nil;
    return [[GeoPoint alloc] initWithLogitude:[self[@"lon"] doubleValue]
                                     latitude:[self[@"lat"] doubleValue]];
}
-(bool) isThisFloor:(NSString*) floor
{
    if(self[@"floor"]) {
        if([floor isEqualToString:self[@"floor"]])
            return true;
    }
    return false;
}
-(void) setLocationWithGeoPoint:(GeoPoint*) geoPoint
                          floor:(NSString*) floor
{
    self[@"lon"]= @(geoPoint.longitude);
    self[@"lat"]= @(geoPoint.latitude);
    self[@"floor"]=floor;
    if(marker) {
        [marker setMarkerGeoPoint:geoPoint];
    }
}
@end
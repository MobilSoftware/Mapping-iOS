//
// Created by Richard on 2016/12/7.
// Copyright (c) 2016 sailstech. All rights reserved.
//


#import "AccVerify.h"
#import "PFObject.h"
#import "CommonDefine.h"
#import "PFQuery.h"
#import "POI.h"
#import "CheckPoint.h"

ListOverlay *currentErrorOverlay;
ListOverlay *checkPointsOverlay;
NSMutableArray *checkPointList;
NSMutableArray *poiList;
CheckPoint *currentCheckPoint;

NSString* Accuracy;
NSString* Deviation;
NSString* Samples;

@implementation AccVerify {

}
+(NSString*) GetSamples{
    return Samples;
}
+(NSString*) GetAccuracy{
    return Accuracy;
}
+(NSString*) GetDeviation{
    return Deviation;
}
+(void) StartAccVerifyWithView:(UIView *) view
                 ProjectObject:(PFObject *) project
               GeneralIconDict:(NSMutableDictionary *) general
             HighlightIconDict:(NSMutableDictionary *) highlight
                 CheckIconDict:(NSMutableDictionary *) check
                  SailsMapView:(SailsLocationMapView *) sailsMapView
                         Floor:(NSString*) floor {
    [AccVerify InitParameters];
    if(![[sailsMapView getDynamicOverlays] containsObject:currentErrorOverlay])
    [[sailsMapView getDynamicOverlays] insertObject:currentErrorOverlay atIndex:0];
    if(![[sailsMapView getDynamicOverlays] containsObject:checkPointsOverlay])
    [[sailsMapView getDynamicOverlays] insertObject:checkPointsOverlay atIndex:0];
    [CommonDefine showPleaseWaitHudToView:view withMSG:ZpLocalizedString(@"load_check_points")];
    [AccVerify LoadCheckPointsInCloudWithProjectObj:project
                                            success:^{
                                                [CommonDefine hidePleaseWaitHudForView:view];
                                                [AccVerify IconMappingWithGeneral:general
                                                                        Highlight:highlight
                                                                            Check:check];
                                                [AccVerify ShowFloorPOIsWithSAILSMapView:sailsMapView
                                                                                   Floor:floor];



    }
                                               fail:^(NSInteger i) {
                                                   [CommonDefine hidePleaseWaitHudForView:view];
                                                   [CommonDefine showErrorDialog];
                                               }];

}
+ (void)StopAccVerifyWithSailsMapView:(SailsLocationMapView *)sailsMapView {
    @synchronized([sailsMapView getDynamicOverlays]){

        if([[sailsMapView getDynamicOverlays] containsObject:checkPointsOverlay])
        [[sailsMapView getDynamicOverlays] removeObject:checkPointsOverlay];
        if([[sailsMapView getDynamicOverlays] containsObject:currentErrorOverlay])
        [[sailsMapView getDynamicOverlays] removeObject:currentErrorOverlay];
    }
}
+(void) IconMappingWithGeneral:(NSMutableDictionary *) general
                     Highlight:(NSMutableDictionary *) highlight
                         Check:(NSMutableDictionary *) check
{
    UIImage *generalDefaultIcon = general[@"default"];
    UIImage *highlightDefaultIcon = highlight[@"default"];
    UIImage *checkDefaultIcon = check[@"default"];
    for(POI* poi in poiList) {
        UIImage *generalIcon,*highlightIcon,*checkIcon;
        generalIcon=generalDefaultIcon;
        highlightIcon=highlightDefaultIcon;
        checkIcon=checkDefaultIcon;
        if(poi[@"type"]) {
            if(general[poi[@"type"]]) {
                generalIcon=general[poi[@"type"]];
            }
            if(highlight[poi[@"type"]]) {
                highlightIcon=highlight[poi[@"type"]];
            }
            if(check[poi[@"type"]]) {
                checkIcon=check[poi[@"type"]];
            }
        }
        [poi setMarkerGeneral:generalIcon
                    Highlight:highlightIcon
                        Check:checkIcon];
    }

}

+(void) LoadCheckPointsInCloudWithProjectObj:(PFObject *) project
                                     success:(void (^)(void))success
                                        fail:(void (^)(NSInteger))fail
{
    [poiList removeAllObjects];
    PFQuery *query = [[PFQuery alloc] initWithClassName:@"POI"];
    PFQuery *queryProject = [[PFQuery alloc] initWithClassName:@"Project"];
    [queryProject whereKey:@"objectId" equalTo:[project objectId]];
    [query whereKey:@"project" matchesQuery:queryProject];
    [query whereKey:@"type" equalTo:@"check_point"];
    [query setLimit:5000];
    [query findObjectsInBackgroundWithBlock:^(NSArray<id> *objects, NSError *error) {
        if(!error) {
            if(objects) {
                [poiList removeAllObjects];
                [poiList addObjectsFromArray:objects];
            }
            success();
          return;
        }
        fail(error.code);
    }];

}
+(void) ShowFloorPOIsWithSAILSMapView:(SailsLocationMapView *) sailsLocationMapView
                                Floor:(NSString*)floor
{
    
    @synchronized ([checkPointsOverlay getOverlayItems]) {
        [[checkPointsOverlay getOverlayItems] removeAllObjects];
        for(POI* poi in poiList) {
            if([poi isThisFloor:floor]&&poi.marker) {
                [[checkPointsOverlay getOverlayItems]addObject:poi.marker];
            }
        }
        Paint *stroke = [[Paint alloc] init];
        stroke.strokeColor = [UIColor colorWithRed:255/255.0 green:0/255.0 blue:0/255.0 alpha:100.0/255.0];
        stroke.fillColor = [UIColor colorWithRed:255/255.0 green:0/255.0 blue:0/255.0 alpha:100.0/255.0];
        stroke.strokeWidth=5;
        for(CheckPoint* cp in checkPointList) {
            POI* poi=cp.verifyCheckPoint;
            if([poi isThisFloor:floor]&&poi.marker) {
                NSMutableArray *gpArray= [[NSMutableArray alloc] init];
                [gpArray addObject:[[GeoPoint alloc] initWithLogitude:cp.target.longitude
                                                             latitude:cp.target.latitude]];
                [gpArray addObject:[[GeoPoint alloc] initWithLogitude:cp.measure.longitude
                                                             latitude:cp.measure.latitude]];
                Polyline* polyline = [[Polyline alloc] initWithPolygonalChain:[[PolygonalChain alloc] initWithVertexList:gpArray]
                                                             andPolylinePaint:stroke];
                [[checkPointsOverlay getOverlayItems] addObject:polyline];
            }
            
        }

        [sailsLocationMapView reDrawManager];
    }

}
+ (void)InitParameters {

    if(!poiList)
        poiList= [[NSMutableArray alloc] init];
    if(!checkPointsOverlay)
        checkPointsOverlay= [[ListOverlay alloc] init];

    if(currentErrorOverlay)
        [[currentErrorOverlay getOverlayItems] removeAllObjects];
    else
        currentErrorOverlay= [[ListOverlay alloc] init];
    if(checkPointList)
        [checkPointList removeAllObjects];
    else
        checkPointList= [[NSMutableArray alloc] init];


}
+(CheckPoint*) GetCurrentCheckPoint {
    return currentCheckPoint;
}

+ (NSString*) CheckCheckPointIsTouchedWithPoint:(CGPoint)point
                                    sails:(Sails *)sails
                                 sailsMap:(SailsLocationMapView *)sailsMapView {
    NSString *floor= [sailsMapView getCurrentBrowseFloorName];
    currentCheckPoint=nil;
//    double pointX = point.x+85;
//    double pointY = point.y+135;
    double pointX = point.x;
    double pointY = point.y;

    for(POI* poi in poiList) {
        if([floor isEqualToString:poi[@"floor"]]&&poi.marker) {
            if([poi.marker isInMarker:pointX andY:pointY]) {
                currentCheckPoint= [[CheckPoint alloc] init];
                currentCheckPoint.verifyCheckPoint=poi;
                break;
            }
        }
    }
    if(!currentCheckPoint) {
        [AccVerify ClearCurrentCheckPoint:sailsMapView];
        return @"";

    }
    if(![sails isLocationFix]&&![sails isUseGPS])
        return @"";
    if(![[sails getFloor]isEqualToString:currentCheckPoint.verifyCheckPoint[@"floor"]])
        return @"";
    GeoPoint *measure= [[GeoPoint alloc] initWithLogitude:[sails getLongitude]
                                                 latitude:[sails getLatitude]];

    currentCheckPoint.measure=measure;
    currentCheckPoint.target=currentCheckPoint.verifyCheckPoint.getGeoPoint;
    currentCheckPoint.timestamp = [[NSDate date] timeIntervalSince1970];
    double len=[sails getMapDistanceByLngLat:currentCheckPoint.target.longitude
                                   latitude1:currentCheckPoint.target.latitude
                                  longitude2:currentCheckPoint.measure.longitude
                                   latitude2:currentCheckPoint.measure.latitude];

    Paint *stroke = [[Paint alloc] init];
    stroke.strokeColor = [UIColor colorWithRed:0/255.0 green:255/255.0 blue:128/255.0 alpha:100.0/255.0];
    stroke.fillColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:255/255.0 alpha:100.0/255.0];
    stroke.strokeWidth=10;
    NSMutableArray *gpArray= [[NSMutableArray alloc] init];
    [gpArray addObject:currentCheckPoint.target];
    [gpArray addObject:currentCheckPoint.measure];
    Polyline* polyline = [[Polyline alloc] initWithPolygonalChain:[[PolygonalChain alloc] initWithVertexList:gpArray]
                                                 andPolylinePaint:stroke];
    @synchronized (currentErrorOverlay) {
        [[currentErrorOverlay getOverlayItems] removeAllObjects];
        [[currentErrorOverlay getOverlayItems] addObject:polyline];
    }
    [sailsMapView reDrawManager];
    currentCheckPoint.error=len;

    return [self getFormatedMeter:len];

}

+ (void)ClearCurrentCheckPoint:(SailsLocationMapView *)sailsMapView {
    currentCheckPoint=nil;
    [[currentErrorOverlay getOverlayItems] removeAllObjects];
    [sailsMapView reDrawManager];


}

+ (NSString *)getFormatedMeter:(double)len {
    return [NSString stringWithFormat:@"%.01f", len];
}

+ (void)Sample:(SailsLocationMapView *)sailsMapView {
    if(!currentCheckPoint)
        return;
        [currentCheckPoint.verifyCheckPoint setIconType:CHECK];
        CheckPoint *cpSaved;
        for(CheckPoint *cp in checkPointList) {
            if(cp.verifyCheckPoint==currentCheckPoint.verifyCheckPoint) {
                cpSaved=cp;
                break;
            }
        }
        if(cpSaved) {
            cpSaved.timestamp=[[NSDate date] timeIntervalSince1970];
            cpSaved.error=currentCheckPoint.error;
            cpSaved.target=currentCheckPoint.target;
            cpSaved.measure=currentCheckPoint.measure;
        }else {
            [checkPointList addObject:currentCheckPoint];
        }
    [[currentErrorOverlay getOverlayItems] removeAllObjects];

        [AccVerify CalculateAccuracy];
        [AccVerify ShowFloorPOIsWithSAILSMapView:sailsMapView Floor:[sailsMapView getCurrentBrowseFloorName]];
}

+ (void)CalculateAccuracy {
    Samples= [@(checkPointList.count) stringValue];
    double error=0;
    for(CheckPoint *cp in checkPointList) {
        error+=cp.error;
    }
    error/=checkPointList.count;
    Accuracy=[AccVerify getFormatedMeter:error];
    double deviation=0;
    for(CheckPoint *cp in checkPointList) {
        deviation+=(cp.error-error)*(cp.error-error);
    }
    deviation/=checkPointList.count;
    deviation=pow(deviation,0.5);
    Deviation=[AccVerify getFormatedMeter:deviation];
}
+(NSString*) SaveToCSVFile {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"output.csv"];

    NSString *output = @"";
    output=[NSString stringWithFormat:@"%@Samples,%@\n",output,Samples];
    output=[NSString stringWithFormat:@"%@Std. Deviation,%@\n",output,Deviation];
    output=[NSString stringWithFormat:@"%@Avg. Accuracy,%@\n",output,Accuracy];
    output=[NSString stringWithFormat:@"%@Check Point ID,Mapping ID,Floor,Check Point Latitude,Check Point Longitude,Measurement Latitude,Measurement Longitude,Error(m)\n",output];
    for(CheckPoint *cp in checkPointList) {
        output= [NSString stringWithFormat:@"%@%@,%@,%@,%@,%@,%@,%@,%@\n", output,
                 cp.verifyCheckPoint[@"id"],
                 cp.verifyCheckPoint[@"comment"],
                 cp.verifyCheckPoint[@"floor"],
                 @(cp.target.latitude),
                 @(cp.target.longitude),
                 @(cp.measure.latitude),
                 @(cp.measure.longitude),@(cp.error)];
    }

    [output writeToFile:filePath atomically:TRUE encoding:NSUTF8StringEncoding error:NULL];
    return filePath;
}
@end

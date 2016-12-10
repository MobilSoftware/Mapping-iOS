//
// Created by Richard on 2016/12/7.
// Copyright (c) 2016 sailstech. All rights reserved.
//

#import <Foundation/Foundation.h>

@class POI;


@interface CheckPoint : NSObject
@property POI* verifyCheckPoint;
@property GeoPoint *target,*measure;
@property NSTimeInterval timestamp;
@property double error;
@end
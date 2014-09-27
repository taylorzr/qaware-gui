//
//  LocationItem.h
//  Qaware-Gui
//
//  Created by Zach Taylor on 9/27/14.
//  Copyright (c) 2014 Zach Taylor. All rights reserved.
//

#import <Foundation/Foundation.h>

@import CoreLocation;

@interface LocationItem : NSObject

@property (strong, nonatomic, readonly) NSString *name;
@property (strong, nonatomic, readonly) NSUUID *uuid;
@property (assign, nonatomic, readonly) CLBeaconMajorValue major;
@property (assign, nonatomic, readonly) CLBeaconMinorValue minor;

@property (strong, nonatomic) CLBeacon *lastSeenBeacon;

-(instancetype)initWithName: (NSString *)name
                       uuid: (NSUUID *)uuid
                      major: (CLBeaconMajorValue *)major
                      minor: (CLBeaconMinorValue *)minor;

@end

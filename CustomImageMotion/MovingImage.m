//
//  MovingImage.m
//  CustomImageMotion
//
//  Created by Matt B on 11/24/13.
//  Copyright (c) 2013 Matt B. All rights reserved.
//

#import "MovingImage.h"

@implementation MovingImage

@synthesize view;
@synthesize pointLocation;

- (id)init
{
    self = [super init];
    if (self) {
        view = nil;
        // This will change later, but keep for now
       // pointLocation = CGPointMake(1, 1);
    }
    return self;
}

+ (MovingImage *)placeOfInterestWithView:(UIView *)view at:(CGPoint)location
{
	MovingImage *poi = [[MovingImage alloc] init];
	poi.view = view;
	poi.pointLocation = location;
	return poi;
}


@end

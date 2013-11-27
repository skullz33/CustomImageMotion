//
//  MovingImage.h
//  CustomImageMotion
//
//  Created by Matt B on 11/24/13.
//  Copyright (c) 2013 Matt B. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MovingImage : NSObject
@property (nonatomic, retain) UIView *view;
@property (nonatomic) CGPoint pointLocation;

//@property (nonatomic, retain) CLLocation *location;

+ (MovingImage *)placeOfInterestWithView:(UIView *)view at:(CGPoint)location;
@end

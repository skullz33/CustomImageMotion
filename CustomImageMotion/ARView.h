//
//  ARView.h
//  CustomImageMotion
//
//  Created by Matt B on 11/24/13.
//  Copyright (c) 2013 Matt B. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>
#import "ViewController.h"

typedef float mat4f_t[16];	// 4x4 matrix in column major order
typedef float vec4f_t[4];	// 4D vector


#define DEGREES_TO_RADIANS (M_PI/180.0)

// Creates a projection matrix using the given y-axis field-of-view, aspect ratio, and near and far clipping planes
void createProjectionMatrix(mat4f_t mout, float fovy, float aspect, float zNear, float zFar);

// Matrix-vector and matrix-matricx multiplication routines
void multiplyMatrixAndVector(vec4f_t vout, const mat4f_t m, const vec4f_t v);
void multiplyMatrixAndMatrix(mat4f_t c, const mat4f_t a, const mat4f_t b);

// Initialize mout to be an affine transform corresponding to the same rotation specified by m
void transformFromCMRotationMatrix(vec4f_t mout, const CMRotationMatrix *m);

@interface ARView : UIView {
    UIView *captureView;
	AVCaptureSession *captureSession;
	AVCaptureVideoPreviewLayer *captureLayer;
	
	CADisplayLink *displayLink;
	CMMotionManager *motionManager;
	//CLLocationManager *locationManager;
	//CLLocation *location;
	NSArray *placesOfInterest;
	mat4f_t projectionTransform;
	mat4f_t cameraTransform;
    mat4f_t rightBoundLimitMx;
    mat4f_t leftBoundLimitMx;
    mat4f_t goingTo;
	vec4f_t *placesOfInterestCoordinates;
    
    ViewController *ARviewController;
    
    int test;
}

- (void)start;
- (void)stop;

-(void)setPlacesOfInterest:(NSArray *)pois;

- (void)initialize;

//- (void)startCameraPreview;
//- (void)stopCameraPreview;

//- (void)startLocation;
//- (void)stopLocation;

- (void)startDeviceMotion;
- (void)stopDeviceMotion;

- (void)startDisplayLink;
- (void)stopDisplayLink;

//- (void)updatePlacesOfInterestCoordinates;

- (void)onDisplayLink:(id)sender;
//- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;

@end

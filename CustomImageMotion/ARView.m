//
//  ARView.m
//  CustomImageMotion
//
//  Created by Matt B on 11/24/13.
//  Copyright (c) 2013 Matt B. All rights reserved.
//

#import "ARView.h"
#import "MovingImage.h"

@implementation ARView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)start // Start motion
{
    ARviewController = [ViewController new];
    
	[self startDeviceMotion];
	[self startDisplayLink];
}

- (void)stop // End motion
{
	[self stopDeviceMotion];
	[self stopDisplayLink];
}

- (void)setPlacesOfInterest:(NSArray *)pois
{
	for (MovingImage *poi in [placesOfInterest objectEnumerator]) {
		[poi.view removeFromSuperview];
	}
	
	placesOfInterest = pois;
    
    [self updatePlacesOfInterestCoordinates];
}

- (NSArray *)placesOfInterest
{
	return placesOfInterest;
}

- (void)initialize
{
	captureView = [[UIView alloc] initWithFrame:self.bounds];
	captureView.bounds = self.bounds;
	[self addSubview:captureView];
	[self sendSubviewToBack:captureView];
	
	// Initialize projection matrix
	createProjectionMatrix(projectionTransform, 60.0f*DEGREES_TO_RADIANS, self.bounds.size.width*1.0f / self.bounds.size.height, 0.25f, 1000.0f);
    
    leftBoundLimitMx[0]  = -0.675;    leftBoundLimitMx[1]  = -0.076;    leftBoundLimitMx[2]  = -0.733;   leftBoundLimitMx[3]  = 0.000;
    leftBoundLimitMx[4]  = -0.731;    leftBoundLimitMx[5]  = -0.050;    leftBoundLimitMx[6]  =  0.679;   leftBoundLimitMx[7]  = 0.000;
    leftBoundLimitMx[8]  = -0.089;    leftBoundLimitMx[9]  =  0.995;    leftBoundLimitMx[10] = -0.021;   leftBoundLimitMx[11] = 0.000;
    leftBoundLimitMx[12] = 0.000;     leftBoundLimitMx[13] =  0.000;    leftBoundLimitMx[14] =  0.000;   leftBoundLimitMx[15] = 1.000;
}
/*
// Image Left Bound

{-0.675,-0.076,-0.733,0.000}

{-0.731,-0.050, 0.679,0.000}

{-0.089, 0.995,-0.021,0.000}

{ 0.000, 0.000, 0.000,1.000}


// Image Right Bound

{ 0.854,0.078,-0.512,0.000}

{-0.518,0.126,-0.845,0.000}

{-0.001,0.988, 0.148,0.000}

{ 0.000,0.000, 0.000,1.000}

*/
- (void)stopCameraPreview
{
	[captureSession stopRunning];
	[captureLayer removeFromSuperlayer];
	captureSession = nil;
	captureLayer = nil;
}

- (void)startDeviceMotion
{
	motionManager = [[CMMotionManager alloc] init];
	
	// Tell CoreMotion to show the compass calibration HUD when required to provide true north-referenced attitude
	motionManager.showsDeviceMovementDisplay = YES;
    
	motionManager.deviceMotionUpdateInterval = 1.0 / 60.0;
    
	// New in iOS 5.0: Attitude that is referenced to true north
	//[motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXTrueNorthZVertical];
    [motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryCorrectedZVertical];
    
    CMDeviceMotion *d = motionManager.deviceMotion;
    CMRotationMatrix r = d.attitude.rotationMatrix;
    NSLog(@"    Beginning Rotation...-------------------");
    mat4f_t randomTransform;
    transformFromCMRotationMatrix(randomTransform, &r);
    NSLog(@"End Beginning Rotation...-------------------");
}

- (void)stopDeviceMotion
{
	[motionManager stopDeviceMotionUpdates];
	motionManager = nil;
}

- (void)startDisplayLink
{
	displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(onDisplayLink:)];
	[displayLink setFrameInterval:1];
	[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)stopDisplayLink
{
	[displayLink invalidate];
	displayLink = nil;
}

- (void)updatePlacesOfInterestCoordinates
{
	NSLog(@"updating places of interest coordinates");
	if (placesOfInterestCoordinates != NULL) {
		free(placesOfInterestCoordinates);
	}
	placesOfInterestCoordinates = (vec4f_t *)malloc(sizeof(vec4f_t)*placesOfInterest.count);
    
	int i = 0;
	
	typedef struct {
		float distance;
		int index;
	} DistanceAndIndex;
    
	NSMutableArray *orderedDistances = [NSMutableArray arrayWithCapacity:placesOfInterest.count];
    
    DistanceAndIndex distanceAndIndex;
    distanceAndIndex.distance = 6262628.5; // Fixed Distance see dash for more info
    distanceAndIndex.index = i;
    
    [orderedDistances insertObject:[NSData dataWithBytes:&distanceAndIndex length:sizeof(distanceAndIndex)] atIndex:0];
    
    
    MovingImage *poi = (MovingImage *)[placesOfInterest objectAtIndex:0];
    
    [self addSubview:poi.view];
    
}

- (void)onDisplayLink:(id)sender
{
	CMDeviceMotion *d = motionManager.deviceMotion;
	if (d != nil) {
		CMRotationMatrix r = d.attitude.rotationMatrix;
        
        transformFromCMRotationMatrix(cameraTransform, &r);
		[self setNeedsDisplay];
	}
}

- (void)drawRect:(CGRect)rect
{
	if (placesOfInterestCoordinates == nil) {
		return;
	}
    
    //	NSLog(@"Draw Rect");
    
    mat4f_t projectionCameraTransform;
    multiplyMatrixAndMatrix(projectionCameraTransform, projectionTransform, cameraTransform);
    
    int i = 0;
    
    // Always only one image... but this is easier
    for (MovingImage *poi in [placesOfInterest objectEnumerator]) {
        vec4f_t v;
        
        multiplyMatrixAndVector(v, projectionCameraTransform, placesOfInterestCoordinates[i]);
        
        float x = (v[0] / v[3] + 1.0f) * 0.5f;
        float y = (v[1] / v[3] + 1.0f) * 0.5f;
        //  NSLog(@"v[2] < 0.0f");
        //  NSLog(@"%0.01f < 0.0f",v[2]);
        //   NSLog(@"---------------------");
        if (v[2] < 0.0f) {
            CGPoint movingTo = CGPointMake(x*self.bounds.size.width, self.bounds.size.height-y*self.bounds.size.height);
         //   NSLog(@"x = %f",x);
            
            CGRect winRect = self.frame;
           
            
            BOOL withinHeight = NO,withinWidth = NO;
            
            if (movingTo.x > -118 && movingTo.x < 542) {
               // NSLog(@"View IS within width");
                withinWidth = YES;
            }
            
            if (movingTo.y > 215 && movingTo.y < 390) {
               // NSLog(@"View IS within height");
                withinHeight = YES;
            }
            
            if (withinHeight == YES && withinWidth == YES) {
           //      NSLog(@"poi.view.center        X:%1.0f          Y:%1.0f     Within --Height--  **Width**",poi.view.center.x,poi.view.center.y);
            } else if (withinWidth == YES) {
           //     NSLog(@"poi.view.center        X:%1.0f          Y:%1.0f     Within             **Width**",poi.view.center.x,poi.view.center.y);
            } else if (withinHeight == YES) {
           //     NSLog(@"poi.view.center        X:%1.0f          Y:%1.0f     Within --Height--",poi.view.center.x,poi.view.center.y);
            }
            NSLog(@"poi.view.frame        X:%0.3f          Y:%0.3f",poi.view.frame.origin.x,poi.view.frame.origin.y);
            NSLog(@"self.frame.origin   X:%0.3f     Y:%0.3f",self.frame.origin.x,self.frame.origin.y);
            
            if (movingTo.x < -118) {
                movingTo.x = -118;
            }
            if (movingTo.x > 542) {
                movingTo.x = 542;
            }
            if (movingTo.y < 215) {
                movingTo.y = 215;
            }
            if (movingTo.y > 390) {
                movingTo.y = 390;
            }
            
            poi.view.center = movingTo;
            
            poi.view.hidden = NO;
            
        } else {
            poi.view.hidden = YES;
        }
        i++;
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self initialize];
	}
	return self;
}



// Creates a projection matrix using the given y-axis field-of-view, aspect ratio, and near and far clipping planes
void createProjectionMatrix(mat4f_t mout, float fovy, float aspect, float zNear, float zFar)
{
	float f = 1.0f / tanf(fovy/2.0f);
	
	mout[0] = f / aspect;
	mout[1] = 0.0f;
	mout[2] = 0.0f;
	mout[3] = 0.0f;
	
	mout[4] = 0.0f;
	mout[5] = f;
	mout[6] = 0.0f;
	mout[7] = 0.0f;
	
	mout[8] = 0.0f;
	mout[9] = 0.0f;
	mout[10] = (zFar+zNear) / (zNear-zFar);
	mout[11] = -1.0f;
	
	mout[12] = 0.0f;
	mout[13] = 0.0f;
	mout[14] = 2 * zFar * zNear /  (zNear-zFar);
	mout[15] = 0.0f;
}


// Matrix-vector and matrix-matricx multiplication routines
void multiplyMatrixAndVector(vec4f_t vout, const mat4f_t m, const vec4f_t v)
{
	vout[0] = m[0]*v[0] + m[4]*v[1] + m[8]*v[2] + m[12]*v[3];
	vout[1] = m[1]*v[0] + m[5]*v[1] + m[9]*v[2] + m[13]*v[3];
	vout[2] = m[2]*v[0] + m[6]*v[1] + m[10]*v[2] + m[14]*v[3];
	vout[3] = m[3]*v[0] + m[7]*v[1] + m[11]*v[2] + m[15]*v[3];
}

void multiplyMatrixAndMatrix(mat4f_t c, const mat4f_t a, const mat4f_t b)
{
	uint8_t col, row, i;
	memset(c, 0, 16*sizeof(float));
	
	for (col = 0; col < 4; col++) {
		for (row = 0; row < 4; row++) {
			for (i = 0; i < 4; i++) {
				c[col*4+row] += a[i*4+row]*b[col*4+i];
			}
		}
	}
}

// Initialize mout to be an affine transform corresponding to the same rotation specified by m
void transformFromCMRotationMatrix(vec4f_t mout, const CMRotationMatrix *m)
{
	mout[0] = (float)m->m11;
	mout[1] = (float)m->m21;
	mout[2] = (float)m->m31;
	mout[3] = 0.0f;
	
	mout[4] = (float)m->m12;
	mout[5] = (float)m->m22;
	mout[6] = (float)m->m32;
	mout[7] = 0.0f;
	
	mout[8] = (float)m->m13;
	mout[9] = (float)m->m23;
	mout[10] = (float)m->m33;
	mout[11] = 0.0f;
	
	mout[12] = 0.0f;
	mout[13] = 0.0f;
	mout[14] = 0.0f;
	mout[15] = 1.0f;
    
 //   NSLog(@"{%f,%f,%f,%f}",mout[0],mout[1],mout[2],mout[3]);
 //   NSLog(@"{%f,%f,%f,%f}",mout[4],mout[5],mout[6],mout[7]);
 //   NSLog(@"{%f,%f,%f,%f}",mout[8],mout[9],mout[10],mout[11]);
 //   NSLog(@"{%f,%f,%f,%f}",mout[12],mout[13],mout[14],mout[15]);
  //  NSLog(@"mout[9] = %3f",mout[9]);
  //  NSLog(@"-------------");
}
/*
 // Image Left Bound
 
 {-0.675,-0.076,-0.733,0.000}
 {-0.731,-0.050, 0.679,0.000}
 {-0.089, 0.995,-0.021,0.000}
 
 
 { 0.000, 0.000, 0.000,1.000}
 
 
 // Image Right Bound
 
 { 0.854,0.078,-0.512,0.000}
 {-0.518,0.126,-0.845,0.000}
 {-0.001,0.988, 0.148,0.000}
 
 
 { 0.000,0.000, 0.000,1.000}
 
 
 
 */

@end

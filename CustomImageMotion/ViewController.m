//
//  ViewController.m
//  CustomImageMotion
//
//  Created by Matt B on 11/24/13.
//  Copyright (c) 2013 Matt B. All rights reserved.
//

#import "ViewController.h"
#import "ARView.h"
#import "MovingImage.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    ARView *arView = (ARView *)self.view;
    
    
	NSMutableArray *placesOfInterest = [NSMutableArray arrayWithCapacity:1];
    int i = 0;
	//for (int f = 0; f < numPois; f++) {
    NSLog(@"Adding Views");
	//	UILabel *self.imageMarker = [[[UILabel alloc] init] autorelease];
    
    
	//	[placesOfInterest insertObject:poi atIndex:i];
    
    
	//}
    
    
    self.imageMarker.adjustsFontSizeToFitWidth = NO;
    self.imageMarker.opaque = NO;
    self.imageMarker.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.5f];
    self.imageMarker.center = CGPointMake(200.0f, 200.0f);
    self.imageMarker.textAlignment = UITextAlignmentCenter;
    self.imageMarker.textColor = [UIColor whiteColor];
	//	self.imageMarker.text = [NSString stringWithCString:poiNames[i] encoding:NSASCIIStringEncoding];
    CGSize size = [self.imageMarker.text sizeWithFont:self.imageMarker.font];
    self.imageMarker.bounds = CGRectMake(0.0f, 0.0f, size.width, size.height);
    
    MovingImage *poi = [MovingImage placeOfInterestWithView:self.imageMarker at:CGPointMake(0, 0)];
    
    [placesOfInterest insertObject:poi atIndex:i];
    
    self.imageView.frame = CGRectMake(self.imageMarker.frame.origin.x, self.imageMarker.frame.origin.y, self.imageView.frame.size.width, self.imageView.frame.size.height);
    
	[arView setPlacesOfInterest:placesOfInterest];
    
    NSTimer *timer2 = [NSTimer timerWithTimeInterval:1/60.0 target:self selector:@selector(updateImagePosition) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer2 forMode:NSDefaultRunLoopMode];
}

-(void)updateImagePosition {
    
    [UIView animateWithDuration:0.0 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{
        self.imageView.center = CGPointMake(self.imageMarker.frame.origin.x, self.imageMarker.frame.origin.y);
    } completion:nil];
    
    //  NSLog(@"updating... imageLabel Pos X:%1f Y:%1f",self.imageMarker.frame.origin.x,self.imageMarker.frame.origin.y);
    
    //  self.imageView.transform = self.imageMarker.transform;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	ARView *arView = (ARView *)self.view;
	[arView start];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	ARView *arView = (ARView *)self.view;
	[arView stop];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

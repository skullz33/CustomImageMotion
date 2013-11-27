//
//  ViewController.h
//  CustomImageMotion
//
//  Created by Matt B on 11/24/13.
//  Copyright (c) 2013 Matt B. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController {
  //  CMMotionManager *motionManager;
    float rotation;
}

@property (retain, nonatomic) IBOutlet UIImageView *imageView;
//@property (retain, nonatomic) IBOutlet UIImageView *imageView2;
@property (retain, nonatomic) IBOutlet UILabel *imageMarker;
//@property (retain, nonatomic) IBOutlet UILabel *imageMarker2;
//@property (nonatomic) CGAffineTransform markerTransform;

@end

//
//  ActionDataViewController.h
//  PredictUserActions
//
//  Created by Justin Wilkinson on 11/9/15.
//  Copyright © 2015 Justin Wilkinson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

@interface ActionDataViewController : UIViewController

// Capture motion data from phone
@property (strong, nonatomic) CMAttitude* referenceAttitude;
@property (strong, nonatomic) CMMotionManager *motionManager;

// Display data on the screen in the assigned labels
@property (strong, nonatomic) IBOutlet UILabel *actionName;
@property (strong, nonatomic) IBOutlet UILabel *accX;
@property (strong, nonatomic) IBOutlet UILabel *accY;
@property (strong, nonatomic) IBOutlet UILabel *accZ;
@property (strong, nonatomic) IBOutlet UILabel *angYaw;
@property (strong, nonatomic) IBOutlet UILabel *angPitch;
@property (strong, nonatomic) IBOutlet UILabel *angRoll;

- (IBAction)pushToHomeScreen:(id)sender;
@end

//
//  PredictActionViewController.h
//  PredictUserActions
//
//  Created by Justin Wilkinson on 11/10/15.
//  Copyright © 2015 Justin Wilkinson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

@interface PredictActionViewController : UIViewController
@property (strong, nonatomic) CMAttitude* referenceAttitude;
@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) NSString *accX;
@property (strong, nonatomic) NSString *accY;
@property (strong, nonatomic) NSString *accZ;
@property (strong, nonatomic) NSString *angYaw;
@property (strong, nonatomic) NSString *angPitch;
@property (strong, nonatomic) NSString *angRoll;

@property (strong, nonatomic) IBOutlet UILabel *numTrainingSets;
@property (strong, nonatomic) IBOutlet UILabel *predictedAction;
- (IBAction)backToHome:(id)sender;

@end

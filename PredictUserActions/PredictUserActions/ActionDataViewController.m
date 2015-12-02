//
//  ActionDataViewController.m
//  PredictUserActions
//
//  Created by Justin Wilkinson on 11/9/15.
//  Copyright © 2015 Justin Wilkinson. All rights reserved.
//

#import "ActionDataViewController.h"
#import "AppDelegate.h"

double currentAccX;
double currentAccY;
double currentAccZ;
double currentYaw;
double currentPitch;
double currentRoll;

@interface ActionDataViewController ()

@end

@implementation ActionDataViewController

@synthesize angYaw;
@synthesize angPitch;
@synthesize angRoll;
@synthesize accX;
@synthesize accY;
@synthesize accZ;
@synthesize referenceAttitude;
@synthesize motionManager;

- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    
    // Pause one second to allow user to get into position before recording motion
    [NSThread sleepForTimeInterval:1];
    
    // Set duration to record motion; after duration is reached go back to main home screen
    [self performSelector:@selector(goToNextView) withObject:nil afterDelay:delegate.activityDuration];

    self.actionName.text = delegate.activity_desc;
    
    self.motionManager = [[CMMotionManager alloc] init];
    
    // Set retrieval rate for accelerometer data
    self.motionManager.accelerometerUpdateInterval = delegate.retrievalRate;
    
    // Start collecting accelerometer data
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                             withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
                                                 [self outputAccelerationData:accelerometerData.acceleration];
                                                 if(error){
                                                     NSLog(@"%@", error);
                                                 }
                                             }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

-(void)outputAccelerationData:(CMAcceleration)acceleration
{
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    currentAccX = acceleration.x;
    currentAccY = acceleration.y;
    currentAccZ = acceleration.z;
    
    // Display current accelerometer data to two decimal points
    accX.text = [NSString stringWithFormat:@" %.2fg",currentAccX];
    accY.text = [NSString stringWithFormat:@" %.2fg",currentAccY];
    accZ.text = [NSString stringWithFormat:@" %.2fg",currentAccZ];
    
    // Set rate to retrieve motion data
    motionManager.deviceMotionUpdateInterval = delegate.retrievalRate;
    
    // Start collecting motion data (yaw, pitch, and roll)
    [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue]
                                            withHandler:^(CMDeviceMotion * attitudeData, NSError *error) {
                                                [self outputAttitudeData:attitudeData.attitude];
                                                if(error){
                                                    NSLog(@"%@", error);
                                                }
                                            }];
}

-(void)outputAttitudeData:(CMAttitude*)attitude
{
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    
    currentYaw = motionManager.deviceMotion.attitude.yaw*180/M_PI;
    currentPitch = motionManager.deviceMotion.attitude.pitch*180/M_PI;
    currentRoll = motionManager.deviceMotion.attitude.roll*180/M_PI;
    
    // Display motion data to two decimal points
    angRoll.text = [NSString stringWithFormat:@"%.2f",currentYaw];
    angPitch.text = [NSString stringWithFormat:@"%.2f",currentPitch];
    angYaw.text= [NSString stringWithFormat:@"%.2f",currentRoll];
    
    // Get timestamp to the nearest hundredth of a second
    NSDate *today = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *formatString = @"MM-dd-yyyy HH:mm:ss.SS";
    [formatter setDateFormat:formatString];
    NSString *todayFormat = [formatter stringFromDate:today];
    
    // Save data to Core Data
    NSManagedObjectContext *context = self.managedObjectContext;
    NSManagedObject *newActivityData;
    newActivityData = [NSEntityDescription
                       insertNewObjectForEntityForName:@"ActionData"
                       inManagedObjectContext:context];
    [newActivityData setValue: accX.text forKey:@"accx"];
    [newActivityData setValue: accY.text forKey:@"accy"];
    [newActivityData setValue: accZ.text forKey:@"accz"];
    [newActivityData setValue: angYaw.text forKey:@"yaw"];
    [newActivityData setValue: angPitch.text forKey:@"pitch"];
    [newActivityData setValue: angRoll.text forKey:@"roll"];
    [newActivityData setValue: todayFormat forKey:@"movement_time"];
    [newActivityData setValue: delegate.activity_desc forKey:@"activity_desc"];
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }

}

-(void) stopGatheringData {
    [self.motionManager stopAccelerometerUpdates];
    [self.motionManager stopDeviceMotionUpdates];
}

- (void)goToNextView {
    [self stopGatheringData];
    [self performSegueWithIdentifier:@"pushFromGetActionToHome" sender:self];
}

- (IBAction)pushToHomeScreen:(id)sender {
    [self goToNextView];
}
@end

//
//  PredictActionViewController.m
//  PredictUserActions
//
//  Created by Justin Wilkinson on 11/10/15.
//  Copyright © 2015 Justin Wilkinson. All rights reserved.
//

#import "PredictActionViewController.h"
#import "AppDelegate.h"

double curAccX;
double curAccY;
double curAccZ;
double curYaw;
double curPitch;
double curRoll;

@interface PredictActionViewController ()
@property (strong, nonatomic) NSMutableArray *actionData;
@end

@implementation PredictActionViewController

@synthesize referenceAttitude;
@synthesize motionManager;
@synthesize actionData;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"ActionData"];
    
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!results) {
        NSLog(@"Fetch error: %@", error);
        abort();
    }
    if ([results count] == 0) {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"No Data to Compare"
                                      message:@"Go back and add action training data"
                                      preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [self performSegueWithIdentifier:@"pushFromPredictActionToHome" sender:self];
                                 
                             }];
        
        [alert addAction:ok];
        
        [self presentViewController:alert animated:YES completion:nil];
    } else {
    
        self.motionManager = [[CMMotionManager alloc] init];
        self.motionManager.accelerometerUpdateInterval = 0.1;
        
        [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                                 withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
                                                     [self outputAccelerationData:accelerometerData.acceleration];
                                                     if(error){
                                                         NSLog(@"%@", error);
                                                     }
                                                 }];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Fetch the activity data from persistent data store
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"ActionData"];
    actionData = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    self.numTrainingSets.text = [NSString stringWithFormat:@"%lu",(unsigned long)actionData.count];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    curAccX = acceleration.x;
    curAccY = acceleration.y;
    curAccZ = acceleration.z;
    
    self.accX = [NSString stringWithFormat:@" %.2fg",curAccX];
    self.accY = [NSString stringWithFormat:@" %.2fg",curAccY];
    self.accZ = [NSString stringWithFormat:@" %.2fg",curAccZ];
    
    motionManager.deviceMotionUpdateInterval = 0.1;
    
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
    NSArray *neighbors = [NSArray alloc];
    NSString *result = [NSString alloc];
    
    curYaw = motionManager.deviceMotion.attitude.yaw*180/M_PI;
    curPitch = motionManager.deviceMotion.attitude.pitch*180/M_PI;
    curRoll = motionManager.deviceMotion.attitude.roll*180/M_PI;
    
    self.angRoll = [NSString stringWithFormat:@"%.2f",curYaw];
    self.angPitch = [NSString stringWithFormat:@"%.2f",curPitch];
    self.angYaw = [NSString stringWithFormat:@"%.2f",curRoll];
    
    NSMutableArray *curAction = [[NSMutableArray alloc] initWithObjects: self.angYaw, self.angPitch, self.angRoll, self.accX, self.accY, self.accZ, nil];
    
    neighbors = [self getNearestNeighbors:curAction];
    result = [self getResponse:neighbors];
    self.predictedAction.text = [NSString stringWithFormat:@"%@",result];
    [self.predictedAction setNeedsDisplay];
}

-(NSArray *)getNearestNeighbors:(NSMutableArray*)curAction {
    NSMutableArray *distancesArray = [[NSMutableArray alloc] initWithCapacity:0];
    NSArray *neighborArray = [[NSArray alloc]init];
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"ActionData"];
    
    actionData = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    if ([actionData count] > 0) {
        
        for(NSManagedObject *managedObject in actionData){
            NSMutableArray *curDataRow = [[NSMutableArray alloc] initWithObjects:[managedObject valueForKey:@"yaw"], [managedObject valueForKey:@"pitch"], [managedObject valueForKey:@"roll"], [managedObject valueForKey:@"accx"], [managedObject valueForKey:@"accy"], [managedObject valueForKey:@"accz"], [managedObject valueForKey:@"activity_desc"], nil];
            
            double distance = [self getEuclideanDistance:curAction :curDataRow];

            NSMutableArray *distances = [[NSMutableArray alloc] initWithCapacity:0];
            [distances addObject:curDataRow];
            [distances addObject:[NSNumber numberWithDouble:distance]];
            
            [distancesArray addObject:distances];
            
            //NSLog(@"%@, %@, %@, %@, %@, %@, %@, %f",[managedObject valueForKey:@"yaw"],[managedObject valueForKey:@"pitch"],[managedObject valueForKey:@"roll"],[managedObject valueForKey:@"accx"],[managedObject valueForKey:@"accy"],[managedObject valueForKey:@"accz"],[managedObject valueForKey:@"activity_desc"],distance);
            
        }
        
        /*
         for(NSArray *subArray in distancesSorted) {
            NSLog(@"%@",subArray);
        }
         */
        
        NSArray *distancesSorted = [distancesArray sortedArrayUsingComparator:^(id a, id b) {
            NSNumber *numA = [a objectAtIndex:1];
            NSNumber *numB = [b objectAtIndex:1];
            return [numA compare:numB];
        }];

        NSMutableArray *finalDistanceArray = [[NSMutableArray alloc] initWithCapacity:0];
        for(NSArray *subArray in distancesSorted) {
            [finalDistanceArray addObjectsFromArray:subArray];
            [finalDistanceArray removeLastObject];
        }
        
        neighborArray = [finalDistanceArray subarrayWithRange:NSMakeRange(0,3)];
    }
    
    return neighborArray;
}

-(double)getEuclideanDistance:(NSMutableArray*)curAction : (NSMutableArray*)curDataRow{
    double distance = 0;
    for(int i = 0; i < curDataRow.count-1; i++) {
        distance += pow(([curAction[i] doubleValue] - [curDataRow[i] doubleValue]),2);
    }
    return sqrt(distance);
}

-(NSString*)getResponse:(NSArray *)neighbors {
    NSMutableArray *votes = [[NSMutableArray alloc] init];
    NSDictionary *dict = [[NSDictionary alloc] init];
    BOOL found = NO;
    for(NSArray *subArray in neighbors) {
        
        for (dict in votes)
        {
            if ([[dict objectForKey: @"action"] isEqual: [subArray lastObject]])
            {
                [dict  setValue: [NSNumber numberWithInt:
                                  [[dict objectForKey: @"voteCount"] intValue] + 1]
                         forKey: @"voteCount"];
                found = YES;
                break;
            }
        }
        
        if (!found)
        {
            [votes addObject:
             [NSMutableDictionary dictionaryWithObjectsAndKeys:
              [subArray lastObject], @"action",
              [NSNumber numberWithInt: 1], @"voteCount",
              nil]];
        }
        
        
        //NSLog(@"%@",[subArray lastObject]);
    }
    
    
    __block NSString *highKey;
    __block NSNumber *highVal;
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSNumber *val, BOOL *stop) {
        if (highVal == nil || [val compare:highVal] == NSOrderedDescending) {
            if (![key isEqualToString:@"voteCount"] ) {
                highKey = key;
                highVal = val;
            }
        }
    }];
    
    //NSLog(@"key: %@, val: %@", highKey, highVal);
    
    
    NSString *result = [NSString stringWithFormat:@"%@", highVal];
    return result;
}


- (IBAction)backToHome:(id)sender {
    [self.motionManager stopAccelerometerUpdates];
    [self.motionManager stopDeviceMotionUpdates];
}
@end

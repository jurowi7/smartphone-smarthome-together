//
//  AppDelegate.h
//  PredictUserActions
//
//  Created by Justin Wilkinson on 11/6/15.
//  Copyright © 2015 Justin Wilkinson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

// Set global variables
@property (strong, nonatomic) NSString *activity_desc;
@property (nonatomic) int activityDuration;
@property (nonatomic) double retrievalRate;

// Setup project to use CoreData (store data on phone)
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end


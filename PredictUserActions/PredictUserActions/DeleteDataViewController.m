//
//  DeleteDataViewController.m
//  PredictUserActions
//
//  Created by Justin Wilkinson on 11/12/15.
//  Copyright © 2015 Justin Wilkinson. All rights reserved.
//

#import "DeleteDataViewController.h"
#import "AppDelegate.h"

@interface DeleteDataViewController ()

@end

@implementation DeleteDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (IBAction)deleteAction:(id)sender {
    // Delete data for specific action
    
    NSMutableArray *dataToRemove = [[NSMutableArray alloc] initWithCapacity:0];
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"ActionData"];
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"activity_desc == %@", self.actionToDelete.text];
    [fetchRequest setPredicate:predicate];
    dataToRemove = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    if (dataToRemove.count > 0) {
        for (NSManagedObject *action in dataToRemove) {
            [managedObjectContext deleteObject:action];
        }
    }
    NSError * error = nil;
    if (![managedObjectContext save:&error]) {
        NSLog(@"Couldn't save: %@", error);
    }
    
    [self performSegueWithIdentifier:@"pushFromDeleteDataToViewData" sender:self];
}

- (IBAction)deleteAllActions:(id)sender {
    // Delete all action data
    
    NSMutableArray *dataToRemove = [[NSMutableArray alloc] initWithCapacity:0];
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"ActionData"];
    dataToRemove = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    if (dataToRemove.count > 0) {
        for(NSManagedObject *managedObject in dataToRemove){
            [managedObjectContext deleteObject:managedObject];
        }
    }
    NSError * error = nil;
    if (![managedObjectContext save:&error]) {
        NSLog(@"Couldn't save: %@", error);
    }
    
    [self performSegueWithIdentifier:@"pushFromDeleteDataToViewData" sender:self];
}


@end

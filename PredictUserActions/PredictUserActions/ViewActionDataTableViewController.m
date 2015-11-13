//
//  ViewActionDataTableViewController.m
//  PredictUserActions
//
//  Created by Justin Wilkinson on 11/10/15.
//  Copyright © 2015 Justin Wilkinson. All rights reserved.
//

#import "ViewActionDataTableViewController.h"
#import "AppDelegate.h"

@interface ViewActionDataTableViewController ()
@property (strong) NSMutableArray *actionData;

@end

@implementation ViewActionDataTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Fetch the devices from persistent data store
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"ActionData"];
    self.actionData = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.actionData.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSManagedObject *actions = [self.actionData objectAtIndex:indexPath.row];
    [cell.textLabel setText:[actions valueForKey:@"activity_desc"]];
    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@ %@", [actions valueForKey:@"movement_time"], [actions valueForKey:@"accx"], [actions valueForKey:@"accy"], [actions valueForKey:@"accz"], [actions valueForKey:@"yaw"], [actions valueForKey:@"pitch"], [actions valueForKey:@"roll"]]];
    
    return cell;
}


@end

//
//  ActionNameViewController.m
//  PredictUserActions
//
//  Created by Justin Wilkinson on 11/9/15.
//  Copyright © 2015 Justin Wilkinson. All rights reserved.
//

#import "ActionNameViewController.h"
#import "AppDelegate.h"


@interface ActionNameViewController ()

@end
@implementation ActionNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Hide keyboard when user touches screen outside input box
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    // Set static values for user to choose from for capture duration and rate
    self.duration = @[@"2 seconds",@"4 seconds", @"6 seconds"];
    self.rate = @[@"10 times/second",@"50 times/second", @"100 times/second"];
    
    self.picker.dataSource = self;
    self.picker.delegate = self;
    self.picker2.dataSource = self;
    self.picker2.delegate = self;
    
}

- (void)viewDidAppear:(BOOL)animated {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    
    // Set default rate and duration values
    delegate.activityDuration = 2;
    delegate.retrievalRate = .1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)dismissKeyboard {
    [self.activityDesc resignFirstResponder];
}

// The number of columns of data
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
        return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if([pickerView isEqual: self.picker]){
        return self.duration.count;
    }
    else
        return self.rate.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if([pickerView isEqual: self.picker]){
        return self.duration[row];
    }
    else
        return self.rate[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // Set global variables to be passed to next screen
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    if([pickerView isEqual: self.picker]){
        NSString *durationSelected = self.duration[row];
        if ([durationSelected isEqual: @"2 seconds"]) {
            delegate.activityDuration = 2;
        }
        if ([durationSelected isEqual: @"4 seconds"]) {
            delegate.activityDuration = 4;
        }
        if ([durationSelected isEqual: @"6 seconds"]) {
            delegate.activityDuration = 6;
        }
    } else {
        NSString *rateSelected = self.rate[row];
        if ([rateSelected isEqual: @"10 times/second"]) {
            delegate.retrievalRate = 0.1;
        }
        if ([rateSelected isEqual: @"50 times/second"]) {
            delegate.retrievalRate = 0.05;
        }
        if ([rateSelected isEqual: @"100 times/second"]) {
            delegate.retrievalRate = 0.01;
        }
    }
}

- (IBAction)pushToActionData:(id)sender {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    delegate.activity_desc = self.activityDesc.text;
}
@end

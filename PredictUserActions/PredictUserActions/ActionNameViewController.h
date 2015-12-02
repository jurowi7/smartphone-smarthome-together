//
//  ActionNameViewController.h
//  PredictUserActions
//
//  Created by Justin Wilkinson on 11/9/15.
//  Copyright © 2015 Justin Wilkinson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActionNameViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate>
@property (strong, nonatomic) NSArray *duration;
@property (strong, nonatomic) NSArray *rate;

// Set outlets for user input fields
@property (strong, nonatomic) IBOutlet UITextField *activityDesc;
@property (strong, nonatomic) IBOutlet UIPickerView *picker;
@property (strong, nonatomic) IBOutlet UIPickerView *picker2;

// Trigger action when user presses Start
- (IBAction)pushToActionData:(id)sender;

@end

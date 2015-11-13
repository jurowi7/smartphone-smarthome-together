//
//  DeleteDataViewController.h
//  PredictUserActions
//
//  Created by Justin Wilkinson on 11/12/15.
//  Copyright © 2015 Justin Wilkinson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeleteDataViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *actionToDelete;
- (IBAction)deleteAction:(id)sender;
- (IBAction)deleteAllActions:(id)sender;
@end

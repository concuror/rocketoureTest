//
//  RTViewController.h
//  RoketureTest
//
//  Created by Andrii Titov on 8/10/13.
//  Copyright (c) 2013 Andrii Titov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"


@interface RTViewController : UIViewController<UITextFieldDelegate> {
    
    AFHTTPClient *client;
    
    IBOutlet UITextField *work;
    IBOutlet UITextField *password;
    
    IBOutlet UIButton *loginButton;
    IBOutlet UIButton *weatherButton;
    
}

-(IBAction) createUser:(id)sender;

-(IBAction)getWeather:(id)sender;


@end

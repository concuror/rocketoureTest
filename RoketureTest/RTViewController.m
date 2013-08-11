//
//  RTViewController.m
//  RoketureTest
//
//  Created by Andrii Titov on 8/10/13.
//  Copyright (c) 2013 Andrii Titov. All rights reserved.
//

#import "RTViewController.h"
#import "RTUser.h"
#import "NSString+MD5.h"

#define API_URL @"https://api.rocketroute.com"

@interface RTViewController ()

@end

@implementation RTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:API_URL]];
}

- (IBAction)createUser:(id)sender {
    RTUser *user = [RTUser user];
    user.mail = work.text;
    user.passw = [password.text toMD5];
    password.hidden = YES;
    work.text = nil;
}

- (IBAction)getWeather:(id)sender {
    if ([work.text length] < 4) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please, enter correct ICAO" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        return;
    }
    static NSString *format = @"<REQWX>\
    <USR>%@</USR>\
    <PASSWD>%@</PASSWD>\
    <ICAO>%@</ICAO>\
    </REQWX>";
    RTUser *user = [RTUser user];
    NSString *reqvBody = [NSString stringWithFormat:format,user.mail,user.passw,work.text];
    NSMutableURLRequest *reqv = [client requestWithMethod:@"POST" path:@"/wx/v1/service.wsdl" parameters:nil];
    [reqv setHTTPBody:[reqvBody dataUsingEncoding:NSUTF8StringEncoding]];
    AFXMLRequestOperation *opertaion = [[AFXMLRequestOperation alloc] initWithRequest:reqv];
    [opertaion setCompletionBlockWithSuccess:
     ^(AFHTTPRequestOperation *operation, id XML) {
         NSLog(@"%@",XML);
    }
                                     failure:
     ^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"%@",error);
     }];
    [opertaion start];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

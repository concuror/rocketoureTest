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
#import "SVProgressHUD.h"
#import "RTResultVC.h"

#define API_URL @"https://apidev.rocketroute.com/wx/v1"
#define AUTH_URL @"https://mobiledev.rocketroute.com"

@interface RTViewController () {
    NSMutableString *response;
    NSMutableDictionary *weather;
    
    NSString *currentElement;
}

@end

@implementation RTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:API_URL]];
}

- (IBAction)createUser:(id)sender {
    RTUser *user = [RTUser user];
    if ([user.mail length] <= 0) {
        if ([work.text length] + [password.text length] <= 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please, enter correct ICAO" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
            return;
        }
        user.mail = work.text;
        user.passw = [password.text toMD5];
        password.hidden = YES;
        work.enabled = NO;
        [loginButton setTitle:@"Logout" forState:UIControlStateNormal];
        [self makeLoginRequest];
    } else {
        [self clearUser];
    }
    work.text = nil;
    password.text = nil;
}

- (void)clearUser {
    RTUser *user = [RTUser user];
    user.mail = nil;
    user.passw = nil;
    work.enabled = YES;
    password.hidden = NO;
    [loginButton setTitle:@"Login" forState:UIControlStateNormal];
}

- (void)makeLoginRequest {
    AFHTTPClient *tmpClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:AUTH_URL]];
    static NSString *authTemplate =@"req=<?xml version=\"1.0\" encoding=\"UTF-8\"?>\
    <AUTH>\
     <USR>%@</USR>\
    <PASSWD>%@</PASSWD>\
    <DEVICEID>%@</DEVICEID>\
    <PCATEGORY>RocketRoute</PCATEGORY>\
    <APPMD5>9193a8ec39d7dd2a5aefb28dfdffed7e</APPMD5>\
    </AUTH>";
    NSString *devID;
    UIDevice *device = [UIDevice currentDevice];
    if ([device respondsToSelector:@selector(identifierForVendor)]) {
        devID = [[device identifierForVendor] UUIDString];
    } else {
        devID = [device uniqueIdentifier];
    }
    RTUser *user = [RTUser user];
    NSString *reqvBody = [NSString stringWithFormat:authTemplate,user.mail,user.passw,@"e138231a68ad82f054e3d756c6634ba1"/*devID*/];
    NSMutableURLRequest *reqv = [tmpClient requestWithMethod:@"POST" path:@"remote/auth" parameters:nil];
    [reqv setHTTPBody:[reqvBody dataUsingEncoding:NSUTF8StringEncoding]];
    AFXMLRequestOperation *opertaion = [[AFXMLRequestOperation alloc] initWithRequest:reqv];
    [SVProgressHUD show];
    [opertaion setCompletionBlockWithSuccess:
     ^(AFHTTPRequestOperation *operation, id XML) {
         [SVProgressHUD dismiss];
         [work resignFirstResponder];
         [password resignFirstResponder];
         if ([XML isKindOfClass:[NSXMLParser class]]) {
             NSXMLParser *parser = XML;
             parser.delegate = self;
             [parser parse];
         } else {
             [self clearUser];
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Response was not in XML format" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
             [alert show];
         }
     }
                                     failure:
     ^(AFHTTPRequestOperation *operation, NSError *error) {
         [SVProgressHUD dismiss];
         [work resignFirstResponder];
         [password resignFirstResponder];
         [SVProgressHUD show];
         NSLog(@"%@",error);
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
         [alert show];
     }];
    [opertaion start];
}

- (IBAction)getWeather:(id)sender {
    if ([work.text length] < 4) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please, enter correct ICAO" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        return;
    }
    static NSString *envelope = @"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?><SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tns=\"urn:wx/v1/\" xmlns:soap=\"http://schemas.xmlsoap.org/wsdl/soap/\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenc=\"http://schemas.xmlsoap.org/soap/encoding/\" xmlns:wsdl=\"http://schemas.xmlsoap.org/wsdl/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"><SOAP-ENV:Body><request xmlns=\"urn:xmethods-wx\">%@</request></SOAP-ENV:Body></SOAP-ENV:Envelope>";
    static NSString *format = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\
    <REQWX><USR>%@</USR><PASSWD>%@</PASSWD><ICAO>%@</ICAO></REQWX>";
    RTUser *user = [RTUser user];
    NSString *reqvBody = [NSString stringWithFormat:format,user.mail,user.passw,work.text];
    reqvBody = [NSString stringWithFormat:envelope,[reqvBody xmlSimpleEscape]];
    NSMutableURLRequest *reqv = [client requestWithMethod:@"POST" path:@"" parameters:nil];
    [reqv setHTTPBody:[reqvBody dataUsingEncoding:NSUTF8StringEncoding]];
    [reqv addValue:@"urn:xmethods-wx#getWx" forHTTPHeaderField:@"SOAPAction"];
    AFXMLRequestOperation *opertaion = [[AFXMLRequestOperation alloc] initWithRequest:reqv];
    [SVProgressHUD show];
    [opertaion setCompletionBlockWithSuccess:
     ^(AFHTTPRequestOperation *operation, id XML) {
         [SVProgressHUD dismiss];
         if ([XML isKindOfClass:[NSXMLParser class]]) {
             NSXMLParser *parser = XML;
             parser.delegate = self;
             [parser parse];
         } else {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Response was not in XML format" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
             [alert show];
         }
    }
                                     failure:
     ^(AFHTTPRequestOperation *operation, NSError *error) {
         [SVProgressHUD dismiss];
         NSLog(@"%@",error);
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
         [alert show];
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

#pragma mark - view lifecycle

-(void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark - XMLParsing

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"WIND"]) {
        [response appendFormat:@"Wind, lat %@, long: %@ ",[attributeDict objectForKey:@"lat"], [attributeDict objectForKey:@"lon"]];
    } else if ([elementName isEqualToString:@"LVL"]) {
        [response appendString:@" lvl: "];
    } else if ([elementName isEqualToString:@"KTS"]) {
        [response appendString:@" kts: "];
    } else if ([elementName isEqualToString:@"DIR"]) {
        [response appendString:@" dir: "];
    } else if ([elementName isEqualToString:@"TMP"]) {
        [response appendString:@" tmp: "];
    } else if ( (weather != nil) ) {
        response = nil;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (response == nil) {
        response = [[NSMutableString alloc] init];
    }
    [response appendString:string];
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"SOAP-ENV:Envelope"]) {
        NSLog(@"%@",response);
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:[response dataUsingEncoding:NSUTF8StringEncoding]];
        weather = [[NSMutableDictionary alloc] initWithCapacity:3];
        response = nil;
        parser.delegate = self;
        [parser parse];
    } else if ([elementName isEqualToString:@"REQWX"]) {
        //NSLog(@"weather :%@",weather);
        RTResultVC *view = [[RTResultVC alloc] initWithNibName:@"RTResultVC" bundle:nil];
        view.result = [weather description];
        [self.navigationController pushViewController:view animated:YES];
    } else if ([elementName isEqualToString:@"METAR"]) {
        if (response.length > 0) {
            [weather setObject:response forKey:@"METAR"];
        }
    } else if ([elementName isEqualToString:@"TAF"]) {
        if (response.length > 0) {
            [response replaceOccurrencesOfString:@"\n" withString:@"\r" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [response length])];
            [weather setObject:response forKey:@"TAF"];
        }
    } else if ([elementName isEqualToString:@"WINDS"]) {
        if (response.length > 0) {
            [weather setObject:response forKey:@"WINDS"];
        }
    } else if ([elementName isEqualToString:@"RESULT"]) {
        if ([[[response stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString] isEqualToString:@"error"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Sorry, something went wrong. Please try again" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            [self clearUser];
        }
    } else if ([elementName isEqualToString:@"AUTH"]) {
        response = nil;
        work.enabled = YES;
    } else if ([elementName isEqualToString:@"WIND"]) {
        [response appendFormat:@"\r"];
    }
}

@end

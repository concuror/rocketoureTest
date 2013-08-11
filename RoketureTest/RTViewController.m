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

#define API_URL @"https://api.rocketroute.com/wx/v1"

@interface RTViewController () {
    NSMutableString *response;
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
    //<request xmlns=\"urn:xmethods-wx">UKLL</request>
    static NSString *envelope = @"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?><SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tns=\"urn:wx/v1/\" xmlns:soap=\"http://schemas.xmlsoap.org/wsdl/soap/\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenc=\"http://schemas.xmlsoap.org/soap/encoding/\" xmlns:wsdl=\"http://schemas.xmlsoap.org/wsdl/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"><SOAP-ENV:Body><request xmlns=\"urn:xmethods-wx\">%@</request></SOAP-ENV:Body></SOAP-ENV:Envelope>";
    static NSString *format = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\
    <REQWX><USR>%@</USR><PASSWD>%@</PASSWD><ICAO>%@</ICAO></REQWX>";
    RTUser *user = [RTUser user];
    NSString *reqvBody = [NSString stringWithFormat:format,user.mail,user.passw,work.text];
    NSLog(@"%@",[reqvBody xmlSimpleEscape]);
    reqvBody = [NSString stringWithFormat:envelope,[reqvBody xmlSimpleEscape]];
    NSMutableURLRequest *reqv = [client requestWithMethod:@"POST" path:@"" parameters:nil];
    [reqv setHTTPBody:[reqvBody dataUsingEncoding:NSUTF8StringEncoding]];
    //[reqv addValue:@"application/soap+xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [reqv addValue:@"urn:xmethods-wx#getWx" forHTTPHeaderField:@"SOAPAction"];
    AFXMLRequestOperation *opertaion = [[AFXMLRequestOperation alloc] initWithRequest:reqv];
    [opertaion setCompletionBlockWithSuccess:
     ^(AFHTTPRequestOperation *operation, id XML) {
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

#pragma mark - XMLParsing

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    NSLog(@"%@ \nattr: %@",elementName,attributeDict);
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (response == nil) {
        response = [[NSMutableString alloc] init];
    }
    [response appendString:string];
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"SOAP-ENV:Body"]) {
        NSLog(@"%@", response);
    } else if ([elementName isEqualToString:@"REQWX"]) {
        
    }
}

@end

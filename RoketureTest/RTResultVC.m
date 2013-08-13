//
//  RTResultVC.m
//  RoketureTest
//
//  Created by Andrii Titov on 8/13/13.
//  Copyright (c) 2013 Andrii Titov. All rights reserved.
//

#import "RTResultVC.h"

@interface RTResultVC ()

@end

@implementation RTResultVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    textView.text = _result;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

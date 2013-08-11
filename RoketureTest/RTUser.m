//
//  RTUser.m
//  RoketureTest
//
//  Created by Andrii Titov on 8/11/13.
//  Copyright (c) 2013 Andrii Titov. All rights reserved.
//

#import "RTUser.h"

static RTUser *user;

@implementation RTUser

+(RTUser *)user {
    static dispatch_once_t once;
    dispatch_once(&once, ^ { user = [[RTUser alloc] init]; });
    return user;
}



@end

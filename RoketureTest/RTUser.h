//
//  RTUser.h
//  RoketureTest
//
//  Created by Andrii Titov on 8/11/13.
//  Copyright (c) 2013 Andrii Titov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RTUser : NSObject

@property NSString *mail;
@property NSString *passw;

+(RTUser *)user;


@end

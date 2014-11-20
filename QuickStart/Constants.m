//
//  Constants.m
//  QuickStart
//
//  Created by Abir Majumdar on 10/15/14.
//  Copyright (c) 2014 Abir Majumdar. All rights reserved.
//

#import "Constants.h"

#if TARGET_IPHONE_SIMULATOR
//If on simulator use local service to get identiferToken
NSString * const kUserID = @"Simulator";
NSString * const kParticipant = @"Device";
#else
//If on device use remote service to get identiferToken
NSString * const kUserID = @"Device";
NSString * const kParticipant = @"Simulator";
#endif

NSString * const kAppID = @"YOUR_APP_ID";
NSString * const kMIMETypeTextPlain = @"text/plain";

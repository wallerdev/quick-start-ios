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

//NSString * const kAppID = @"1ad97934-6c39-11e4-8185-1ded050004dd";
NSString * const kAppID = @"5a731a4c-63be-11e4-9124-aaa5020075f8";
NSString * const kMIMETypeTextPlain = @"text/plain";

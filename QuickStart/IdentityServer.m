//
//  IdentityServer.m
//  QuickStart
//
//  Created by Abir Majumdar on 10/15/14.
//  Copyright (c) 2014 Abir Majumdar. All rights reserved.
//

#import "IdentityServer.h"

@implementation IdentityServer

@synthesize delegate;

- (id)initWithAppID:(NSString*)appID nonce:(NSString*)nonce userID:(NSString*)userID
{
    self = [super init];
    if (self)
    {
        _appID = appID;
        _nonce = nonce;
        _userID = userID;
    }
    return self;
}

- (void)generateIdentityTokenWithCompletion:(void (^)(BOOL success,NSString* identityToken,NSError *error))completion
{
}

@end

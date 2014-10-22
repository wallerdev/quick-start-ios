//
//  IdentityServerProvider.m
//  QuickStart
//
//  Created by Abir Majumdar on 10/16/14.
//  Copyright (c) 2014 Abir Majumdar. All rights reserved.
//

#import "IdentityServerProvider.h"

@implementation IdentityServerProvider

+ (IdentityServer *)buildIdentityServerFromCustomClass:(NSString *)customClassName
                                                       delegate:(id<IdentityServerDelegate>)delegate
{
    return [self buildIdentityServerFromCustomClass:customClassName delegate:delegate appID:@"" nonce:@"" userID:@""];
}

+ (IdentityServer *)buildIdentityServerFromCustomClass:(NSString *)customClassName
                                              delegate:(id<IdentityServerDelegate>)delegate appID:(NSString*)appID nonce:(NSString*)nonce userID:(NSString*)userID
{
    Class customClass = NSClassFromString(customClassName);
    IdentityServer *is = [[customClass alloc] initWithAppID:appID nonce:nonce userID:userID];
    if (![is isKindOfClass:[IdentityServer class]]) {
        NSLog(@"**** Custom Class: %@ does not extend IdentityServer ****", NSStringFromClass(customClass));
        return nil;
    }
    is.delegate = delegate;
    return is;
}

@end

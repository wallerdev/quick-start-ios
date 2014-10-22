//
//  IdentityServerProvider.h
//  QuickStart
//
//  Created by Abir Majumdar on 10/16/14.
//  Copyright (c) 2014 Abir Majumdar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IdentityServer.h"

@class IdentityServer;
@protocol IdentityServerDelegate;

@interface IdentityServerProvider : NSObject

+ (IdentityServer *)buildIdentityServerFromCustomClass:(NSString *)customClassName
                                                                  delegate:(id<IdentityServerDelegate>)delegate;

+ (IdentityServer *)buildIdentityServerFromCustomClass:(NSString *)customClassName
                                              delegate:(id<IdentityServerDelegate>)delegate appID:(NSString*)appID nonce:(NSString*)nonce userID:(NSString*)userID;

@end

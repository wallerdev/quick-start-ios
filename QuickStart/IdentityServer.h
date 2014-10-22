//
//  IdentityServer.h
//  QuickStart
//
//  Created by Abir Majumdar on 10/15/14.
//  Copyright (c) 2014 Abir Majumdar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IdentityServerDelegate.h"

@interface IdentityServer : NSObject

@property (nonatomic, weak) id<IdentityServerDelegate> delegate;
@property (nonatomic, retain) NSString *identityToken;
@property (nonatomic, retain) NSString *appID, *nonce, *userID;

- (id)initWithAppID:(NSString *)appID nonce:(NSString *)nonce userID:(NSString *)userID;
- (void)generateIdentityTokenWithCompletion:(void (^)(BOOL success,NSString* identityToken,NSError *error))completion;

@end

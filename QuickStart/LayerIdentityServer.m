//
//  LayerIdentityServer.m
//  QuickStart
//
//  Created by Abir Majumdar on 10/15/14.
//  Copyright (c) 2014 Abir Majumdar. All rights reserved.
//

#import "LayerIdentityServer.h"

NSString *kIdentityServerURL = @"https://layer-identity-provider.herokuapp.com/identity_tokens";

@interface LayerIdentityServer ()

@end

@implementation LayerIdentityServer


- (void)generateIdentityTokenWithCompletion:(void (^)(BOOL success,NSString* identityToken,NSError *error))completion
{
    NSURL *identityTokenURL = [NSURL URLWithString:kIdentityServerURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:identityTokenURL];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSDictionary *parameters = @{ @"app_id": self.appID, @"user_id": self.userID, @"nonce": self.nonce };
    NSData *requestBody = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    request.HTTPBody = requestBody;
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        // Deserialize the response
        //NSError* responseError = nil;
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        self.identityToken = responseObject[@"identity_token"];
        NSLog(@"getIdentityTokenWithCompletion: %@", self.identityToken);
        completion(YES,responseObject[@"identity_token"],error);
    }] resume];
}

@end
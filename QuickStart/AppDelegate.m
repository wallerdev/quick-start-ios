//
//  AppDelegate.m
//  QuickStart
//
//  Created by Abir Majumdar on 10/14/14.
//  Copyright (c) 2014 Abir Majumdar. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate () <IdentityServerDelegate>

@end

@implementation AppDelegate
{
    ViewController *viewController;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    viewController = (ViewController *)self.window.rootViewController;
    
    // Initializes a LYRClient object
    NSUUID *appID = [[NSUUID alloc] initWithUUIDString:kAppID];
    
    viewController.layerClient = [LYRClient clientWithAppID:appID];
        
    if(!viewController.layerClient.isConnected)
    {
        // Tells LYRClient to establish a connection with the Layer service
        [viewController.layerClient connectWithCompletion:^(BOOL success, NSError *error) {
            if (success) {                
                
                [viewController logMessage:[NSString stringWithFormat: @"Connected to appID %@", [viewController.layerClient.appID UUIDString]]];
                if(viewController.layerClient.authenticatedUserID)
                {
                    [viewController logMessage:[NSString stringWithFormat: @"authenticatedUserID: %@", viewController.layerClient.authenticatedUserID]];
                    [viewController logMessage:[NSString stringWithFormat: @"Already Authenticated as User: %@",viewController.layerClient.authenticatedUserID]];
                    
                    
                    //[self sendMessage:@"Hi, how are you?"];
                }
                else
                {
                    NSString *userIDString = kUserID;
                    [viewController logMessage:@"User Not authenticated"];
                    [viewController logMessage:[NSString stringWithFormat: @"Requesting Authentications for: %@",userIDString]];
                    [self requestAuth:userIDString];
                }
            }
        }];
    }

    return YES;
}

- (void)requestAuth:(NSString*) userID{
    [viewController.layerClient requestAuthenticationNonceWithCompletion:^(NSString *nonce, NSError *error) {
        IdentityServer *lis = [IdentityServerProvider buildIdentityServerFromCustomClass:@"LayerIdentityServer"
                                                                                delegate:self
                                                                                   appID:[viewController.layerClient.appID UUIDString]
                                                                                   nonce:nonce
                                                                                  userID:userID];
        [lis generateIdentityTokenWithCompletion:^(BOOL success, NSString *identityToken, NSError *error) {
            if (success) {
                [viewController.layerClient authenticateWithIdentityToken:identityToken completion:^(NSString *authenticatedUserID, NSError *error) {
                    if (authenticatedUserID) {
                        [viewController logMessage:[NSString stringWithFormat: @"Authenticated Success! Authenticated as User: %@", authenticatedUserID]];
                    }
                }];
            }
            else
            {
                NSLog(@"There was an error: %@", error);
            }
        }];
    }];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

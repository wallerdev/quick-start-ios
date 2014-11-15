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
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        // This is the first launch ever
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hello!" message:@"This app is a very simple chat app using Layer.  Launch this app on a Simulator and a Device to start a 1:1 conversation." delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        [alert addButtonWithTitle:@"Got It!"];
        [alert show];
    }
    
    // Set up push notifications
    // Checking if app is running iOS 8
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        // Register device for iOS8
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound
                                                                                             categories:nil];
        [application registerUserNotificationSettings:notificationSettings];
        [application registerForRemoteNotifications];
    } else {
        // Register device for iOS7
        [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge];
    }
    
    
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
                    [viewController logMessage:[NSString stringWithFormat: @"User '%@' authenticated.", viewController.layerClient.authenticatedUserID]];
                    //[viewController logMessage:[NSString stringWithFormat: @"Already Authenticated as User: %@",viewController.layerClient.authenticatedUserID]];
                    
                    
                    //[self sendMessage:@"Hi, how are you?"];
                }
                else
                {
                    NSString *userIDString = kUserID;
//                    [viewController logMessage:@"User Not authenticated"];
                    [viewController logMessage:[NSString stringWithFormat: @"User '%@' not authenticated. Requesting Authentication",userIDString]];
                    
                    [self requestAuth:userIDString];
                }
                // Creates and returns a new conversation object with a single participant represented by
                // your backend's user identifier for the participant
                
                //LYRConversation *conversation = [LYRConversation conversationWithParticipants:[NSSet setWithArray:@[kParticipant]]];
                NSSet *conversations = [viewController.layerClient conversationsForIdentifiers:nil];
                //NSLog(@"conversations.count: %lu",(unsigned long)conversations.count);
                if (conversations.count == 0) {
                    viewController.conversation = [LYRConversation conversationWithParticipants:[NSSet setWithObjects:kUserID,kParticipant, nil]];
                    [viewController logMessage:[NSString stringWithFormat:@"Creating First Conversation"]];                    
                }
                else
                {
                    
                    NSArray *myArray = [conversations allObjects];
                    viewController.conversation = [myArray lastObject];
                    [viewController logMessage:[NSString stringWithFormat:@"Get last conversation object: %@", viewController.conversation.identifier]];
                    
                    NSOrderedSet *messages = [viewController.layerClient messagesForConversation:viewController.conversation];
                    NSLog(@"Initial Messages Count: %lu",(unsigned long)messages.count);
                    [viewController updateChatArea:viewController.conversation];
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
                NSLog(@"generateIdentityTokenWithCompletion SUCCESS");
                [viewController.layerClient authenticateWithIdentityToken:identityToken completion:^(NSString *authenticatedUserID, NSError *error) {
                    if(!error)
                    {
                        if (authenticatedUserID) {
                            [viewController logMessage:[NSString stringWithFormat: @"Authenticated Success! Authenticated as User: %@", authenticatedUserID]];
                        }
                    }
                    else
                    {
                        [viewController logMessage:[error localizedDescription]];   
                    }
                }];
            }
            else
            {
                //NSLog(@"There was an error with the identity server: %@", [error localizedDescription]);
                [viewController logMessage:[error localizedDescription]];
            }
        }];
    }];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSError *error;
    BOOL success = [viewController.layerClient updateRemoteNotificationDeviceToken:deviceToken error:&error];
    if (success) {
        NSLog(@"Application did register for remote notifications");
    } else {
        NSLog(@"Error updating Layer device token for push:%@", error);
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSError *error;
    BOOL success = [viewController.layerClient synchronizeWithRemoteNotification:userInfo completion:^(UIBackgroundFetchResult fetchResult, NSError *error) {
        if (fetchResult == UIBackgroundFetchResultFailed) {
            NSLog(@"Failed processing remote notification: %@", error);
        }
        completionHandler(fetchResult);
    }];
    if (success) {
        NSLog(@"Application did complete remote notification sycn");
    } else {
        NSLog(@"Error handling push notification: %@", error);
        completionHandler(UIBackgroundFetchResultNoData);
    }
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

//
//  LYRClient.h
//  LayerKit
//
//  Created by Klemen Verdnik on 7/23/13.
//  Copyright (c) 2013 Layer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "LYRConversation.h"
#import "LYRMessage.h"
#import "LYRMessagePart.h"
#import "LYRObjectChangeConstants.h"

@class LYRClient;

extern NSString *const LYRClientDidAuthenticateNotification;
extern NSString *const LYRClientAuthenticatedUserIDUserInfoKey;
extern NSString *const LYRClientDidDeauthenticateNotification;

extern NSString *const LYRClientWillBeginSynchronizationNotification;
extern NSString *const LYRClientDidFinishSynchronizationNotification;

/**
 @abstract Content deletion modes
 */
typedef NS_ENUM(NSUInteger, LYRDeletionMode) {
    LYRDeletionModeLocal            = 0,    /* Content is deleted from the current device only. */
    LYRDeletionModeAllParticipants  = 2     /* Content is deleted from all devices of all participants. */
};

///---------------------------
/// @name Change Notifications
///---------------------------

/**
 @abstract Posted when the objects associated with a client have changed due to local mutation or synchronization activities.
 @discussion The Layer client provides a flexible notification system for informing applications when changes have
 occured on domain objects in response to local mutation or synchronization activities. The system is designed to be general
 purpose and models changes as the creation, update, or deletion of an object. Changes are modeled as simple
 dictionaries with a fixed key space that is defined below.
 @see LYRObjectChangeConstants.h
 */
extern NSString *const LYRClientObjectsDidChangeNotification;

/**
 @abstract The key into the `userInfo` of a `LYRClientObjectsDidChangeNotification` notification for an array of changes.
 @discussion Each element in array retrieved from the user info for the `LYRClientObjectChangesUserInfoKey` key is a dictionary whose value models a 
 single object change event for a Layer model object. The change dictionary contains information about the object that changed, what type of
 change occurred (create, update, or delete) and additional details for updates such as the property that changed and its value before and after mutation.
 Change notifications are emitted after synchronization has completed and represent the current state of the Layer client's database.
 @see LYRObjectChangeConstants.h
 */
extern NSString *const LYRClientObjectChangesUserInfoKey;

/**
 @abstract Posted when the client has scheduled an attempt to connect to Layer.
 */
extern NSString *const LYRClientWillAttemptToConnectNotification;

/**
 @abstract Posted when the client has successfully connected to Layer.
 */
extern NSString *const LYRClientDidConnectNotification;

/**
 @abstract Posted when the client has lost an established connection to Layer.
 */
extern NSString *const LYRClientDidLoseConnectionNotification;

/**
 @abstract Posted when the client has lost the connection to Layer.
 */
extern NSString *const LYRClientDidDisconnectNotification;

/**
 @abstract The key into the `userInfo` of the error object passed by the delegate method `layerClient:didFailOperationWithError:` describing
 which public API method encountered the failure.
 @see layerClient:didFailOperationWithError:
 */
extern NSString *const LYRClientOperationErrorUserInfoKey;

/**
 @abstract Posted when a conversation object receives a change in typing indicator state.
 @discussion The `object` of the `NSNotification` is the `LYRConversation` that received the typing indicator.
 */
extern NSString *const LYRConversationDidReceiveTypingIndicatorNotification;

/**
 @abstract A key into the user info of a `LYRConversationDidReceiveTypingIndicatorNotification` notification whose value is
 a `NSNumber` containing a unsigned integer whose value corresponds to a `LYRTypingIndicator`.
 */
extern NSString *const LYRTypingIndicatorValueUserInfoKey;

/**
 @abstract A key into the user info of a `LYRConversationDidReceiveTypingIndicatorNotification` notification whose value is
 a `NSString` specifying the participant who changed typing state.
 */
extern NSString *const LYRTypingIndicatorParticipantUserInfoKey;

/**
 @abstract The `LYRTypingIndicator` enumeration describes the states of a typing status of a participant in a conversation.
 */
typedef NS_ENUM(NSUInteger, LYRTypingIndicator) {
    LYRTypingDidBegin   = 0,
    LYRTypingDidPause   = 1,
    LYRTypingDidFinish  = 2
};

///----------------------
/// @name Client Delegate
///----------------------

/**
 @abstract The `LYRClientDelegate` protocol provides a method for notifying the adopting delegate about information changes.
 */
@protocol LYRClientDelegate <NSObject>

@required

/**
 @abstract Tells the delegate that the server has issued an authentication challenge to the client and a new Identity Token must be submitted.
 @discussion At any time during the lifecycle of a Layer client session the server may issue an authentication challenge and require that
 the client confirm its identity. When such a challenge is encountered, the client will immediately become deauthenticated and will no
 longer be able to interact with communication services until reauthenticated. The nonce value issued with the challenge must be submitted
 to the remote identity provider in order to obtain a new Identity Token.
 @see LayerClient#authenticateWithIdentityToken:completion:
 @param client The client that received the authentication challenge.
 @param nonce The nonce value associated with the challenge.
 */
- (void)layerClient:(LYRClient *)client didReceiveAuthenticationChallengeWithNonce:(NSString *)nonce;

@optional

/**
 @abstract Informs the delegate that the client is making an attempt to connect to Layer.
 @param client The client attempting the connection.
 @param attemptNumber The current attempt (of the attempt limit) that is being made.
 @param delayInterval The delay, if any, before the attempt will actually be made.
 @param attemptLimit The total number of attempts that will be made before the client gives up.
 */
- (void)layerClient:(LYRClient *)client willAttemptToConnect:(NSUInteger)attemptNumber afterDelay:(NSTimeInterval)delayInterval maximumNumberOfAttempts:(NSUInteger)attemptLimit;

/**
 @abstract Informs the delegate that the client has successfully connected to Layer.
 @param client The client that made the connection.
 */
- (void)layerClientDidConnect:(LYRClient *)client;

/**
 @abstract Informs the delegate that the client has lost an established connection with Layer due to an error.
 @param client The client that lost the connection.
 @param error The error that occurred.
 */
- (void)layerClient:(LYRClient *)client didLoseConnectionWithError:(NSError *)error;

/**
 @abstract Informs the delegate that the client has disconnected from Layer.
 @param client The client that has disconnected.
 */
- (void)layerClientDidDisconnect:(LYRClient *)client;

/**
 @abstract Tells the delegate that a client has successfully authenticated with Layer.
 @param client The client that has authenticated successfully.
 @param userID The user identifier in Identity Provider from which the Identity Token was obtained. Typically the primary key, username, or email
    of the user that was authenticated.
 */
- (void)layerClient:(LYRClient *)client didAuthenticateAsUserID:(NSString *)userID;

/**
 @abstract Tells the delegate that a client has been deauthenticated.
 @discussion The client may become deauthenticated either by an explicit call to `deauthenticateWithCompletion:` or by encountering an authentication challenge.
 @param client The client that was deauthenticated.
 */
- (void)layerClientDidDeauthenticate:(LYRClient *)client;

/**
 @abstract Tells the delegate that a client has finished synchronization and applied a set of changes.
 @param client The client that received the changes.
 @param changes An array of `NSDictionary` objects, each one describing a change.
 */
- (void)layerClient:(LYRClient *)client didFinishSynchronizationWithChanges:(NSArray *)changes DEPRECATED_ATTRIBUTE;

/**
 @abstract Tells the delegate the client encountered an error during synchronization.
 @param client The client that failed synchronization.
 @param error An error describing the nature of the sync failure.
 */
- (void)layerClient:(LYRClient *)client didFailSynchronizationWithError:(NSError *)error DEPRECATED_ATTRIBUTE;

/**
 @abstract Tells the delegate that objects associated with the client have changed due to local mutation or synchronization activities.
 @param client The client that received the changes.
 @param changes An array of `NSDictionary` objects, each one describing a change.
 @see LYRObjectChangeConstants.h
 */
- (void)layerClient:(LYRClient *)client objectsDidChange:(NSArray *)changes;

/**
 @abstract Tells the delegate that an operation encountered an error during a local mutation or synchronization activity.
 @param client The client that failed the operation.
 @param error An error describing the nature of the operation failure.
 */
- (void)layerClient:(LYRClient *)client didFailOperationWithError:(NSError *)error;

@end

/**
 @abstract The `LYRClient` class is the primary interface for developer interaction with the Layer platform.
 @discussion The `LYRClient` class and related classes provide an API for rich messaging via the Layer platform. This API supports the exchange of multi-part Messages within multi-user Conversations and advanced features such
 as mutation of the participants, deletion of messages or the entire conversation, and the attachment of free-form user defined metadata. The API is sychronization based, fully supporting offline usage and providing full access
 to the history of messages across devices.
 */
@interface LYRClient : NSObject

///----------------------------
/// @name Initializing a Client
///----------------------------

/**
 @abstract Creates and returns a new Layer client instance.
 */
+ (instancetype)clientWithAppID:(NSUUID *)appID;

/**
 @abstract The object that acts as the delegate of the receiving client.
 */
@property (nonatomic, weak) id<LYRClientDelegate> delegate;

/**
 @abstract The app key.
 */
@property (nonatomic, copy, readonly) NSUUID *appID;

///--------------------------------
/// @name Managing Connection State
///--------------------------------

/**
 @abstract Signals the receiver to establish a network connection and initiate synchronization.
 @discussion If the client has previously established an authenticated identity then the session is resumed and synchronization is activated.
 @param completion An optional block to be executed once connection state is determined. The block has no return value and accepts two arguments: a Boolean value indicating if the connection was made 
 successfully and an error object that, upon failure, indicates the reason that connection was unsuccessful.
*/
- (void)connectWithCompletion:(void (^)(BOOL success, NSError *error))completion;

/**
 @abstract Signals the receiver to end the established network connection.
 */
- (void)disconnect;

/**
 @abstract Returns a Boolean value that indicates if the client is in the process of connecting to Layer.
 */
@property (nonatomic, readonly) BOOL isConnecting;

/**
 @abstract Returns a Boolean value that indicates if the client is connected to Layer.
 */
@property (nonatomic, readonly) BOOL isConnected;

///--------------------------
/// @name User Authentication
///--------------------------

/**
 @abstract Returns a string object specifying the user ID of the currently authenticated user or `nil` if the client is not authenticated.
 @discussion A client is considered authenticated if it has previously established identity via the submission of an identity token
 and the token has not yet expired. The Layer server may at any time issue an authentication challenge and deauthenticate the client.
*/
@property (nonatomic, readonly) NSString *authenticatedUserID;

/**
 @abstract Requests an authentication nonce from Layer.
 @discussion Authenticating a Layer client requires that an Identity Token be obtained from a remote backend application that has been designated to act as an
 Identity Provider on behalf of your application. When requesting an Identity Token from a provider, you are required to provide a nonce value that will be included
 in the cryptographically signed data that comprises the Identity Token. This method asynchronously requests such a nonce value from Layer.
 @warning Nonce values can be issued by Layer at any time in the form of an authentication challenge. You must be prepared to handle server issued nonces as well as those
 explicitly requested by a call to `requestAuthenticationNonceWithCompletion:`.
 @param completion A block to be called upon completion of the asynchronous request for a nonce. The block takes two parameters: the nonce value that was obtained (or `nil`
 in the case of failure) and an error object that upon failure describes the nature of the failure.
 @see LYRClientDelegate#layerClient:didReceiveAuthenticationChallengeWithNonce:
 */
- (void)requestAuthenticationNonceWithCompletion:(void (^)(NSString *nonce, NSError *error))completion;

/**
 @abstract Authenticates the client by submitting an Identity Token to Layer for evaluation.
 @discussion Authenticating a Layer client requires the submission of an Identity Token from a remote backend application that has been designated to act as an
 Identity Provider on behalf of your application. The Identity Token is a JSON Web Signature (JWS) string that encodes a cryptographically signed set of claims
 about the identity of a Layer client. An Identity Token must be obtained from your provider via an application defined mechanism (most commonly a JSON over HTTP
 request). Once an Identity Token has been obtained, it must be submitted to Layer via this method in ordr to authenticate the client and begin utilizing communication
 services. Upon successful authentication, the client remains in an authenticated state until explicitly deauthenticated by a call to `deauthenticateWithCompletion:` or
 via a server-issued authentication challenge.
 @param identityToken A string object encoding a JSON Web Signature that asserts a set of claims about the identity of the client. Must be obtained from a remote identity
 provider and include a nonce value that was previously obtained by a call to `requestAuthenticationNonceWithCompletion:` or via a server initiated authentication challenge.
 @param completion A block to be called upon completion of the asynchronous request for authentication. The block takes two parameters: a string encoding the remote user ID that
 was authenticated (or `nil` if authentication was unsuccessful) and an error object that upon failure describes the nature of the failure.
 @see http://tools.ietf.org/html/draft-ietf-jose-json-web-signature-25
 */
- (void)authenticateWithIdentityToken:(NSString *)identityToken completion:(void (^)(NSString *authenticatedUserID, NSError *error))completion;

/**
 @abstract Deauthenticates the client, disposing of any previously established user identity and disallowing access to the Layer communication services until a new identity is established. All existing messaging data is purged from the database.
 */
- (void)deauthenticateWithCompletion:(void (^)(BOOL success, NSError *error))completion;

///-------------------------------------------------------
/// @name Registering For and Receiving Push Notifications
///-------------------------------------------------------

/**
 @abstract Tells the receiver to update the device token used to deliver Push Notificaitons to the current device via the Apple Push Notification Service.
 @param deviceToken An `NSData` object containing the device token.
 @param error A reference to an `NSError` object that will contain error information in case the action was not successful.
 @return A Boolean value that determines whether the action was successful.
 @discussion The device token is expected to be an `NSData` object returned by the method application:didRegisterForRemoteNotificationsWithDeviceToken:. The device token is cached locally and is sent to Layer cloud automatically when the connection is established.
 */
- (BOOL)updateRemoteNotificationDeviceToken:(NSData *)deviceToken error:(NSError **)error;

/**
 @abstract Inspects an incoming push notification and synchronizes the client if it was sent by Layer.
 @param userInfo The user info dictionary received from the UIApplicaton delegate method application:didReceiveRemoteNotification:fetchCompletionHandler:'s `userInfo` parameter.
 @param completion The block that will be called once Layer has successfully downloaded new data associated with the `userInfo` dictionary passed in. It is your responsibility to call the UIApplication delegate method's fetch completion handler with the given `fetchResult`. Note that this block is only called if the method returns `YES`.
 @return A Boolean value that determines whether the push was handled. Will be `NO` if this was not a push notification meant for Layer and the completion block will not be called.
 @note The receiver must be authenticated else a warning will be logged and `NO` will be returned. The completion is only invoked if the return value is `YES`.
 */
- (BOOL)synchronizeWithRemoteNotification:(NSDictionary *)userInfo completion:(void(^)(UIBackgroundFetchResult fetchResult, NSError *error))completion;

///----------------
/// @name Messaging
///----------------

/**
 @abstract Returns an existing conversation with a given identifier or `nil` if none could be found.
 @param identifier The identifier for an existing conversation.
 @return The conversation with the given identifier or `nil` if none could be found.
 @note The receiver must be authenticated else a warning will be logged and `nil` will be returned.
 */
- (LYRConversation *)conversationForIdentifier:(NSURL *)identifier;

/**
 @abstract Returns existing conversations with the given set of participants or `nil` if none could be found.
 @param participants A set of participants for which to query for a corresponding Conversation. Each element in the array is a string that corresponds to the user ID of the desired participant.
 @return A set of conversations with the given set of participants or `nil` if none could be found.
 @note The receiver must be authenticated else a warning will be logged and `nil` will be returned.
 */
- (NSSet *)conversationsForParticipants:(NSSet *)participants;

/**
 @abstract Adds participants to a given conversation.
 @param participants A set of `providerUserID` in a form of `NSString` objects.
 @param conversation The conversation which to add the participants. Cannot be `nil`.
 @param error A pointer to an error object that, upon failure, will be set to an error describing why the participants could not be added to the conversation.
 @return A Boolean value indicating if the operation of adding participants was successful.
 */
- (BOOL)addParticipants:(NSSet *)participants toConversation:(LYRConversation *)conversation error:(NSError **)error;

/**
 @abstract Removes participants from a given conversation.
 @param participants A set of `providerUserID` in a form of `NSString` objects.
 @param conversation The conversation from which to remove the participants. Cannot be `nil`.
 @param error A pointer to an error object that, upon failure, will be set to an error describing why the participants could not be removed from the conversation.
 @return A Boolean value indicating if the operation of removing participants was successful.
 */
- (BOOL)removeParticipants:(NSSet *)participants fromConversation:(LYRConversation *)conversation error:(NSError **)error;

/**
 @abstract Sends the specified message.
 @discussion The message is enqueued for delivery during the next synchronization after basic local validation of the message state is performed. Validation
 that may be performed includes checking that the maximum number of participants has not been execeeded and that parts of the message do not have an aggregate
 size in excess of the maximum for a message.
 @param message The message to be sent. Cannot be `nil`.
 @param error A pointer to an error object that, upon failure, will be set to an error describing why the message could not be sent.
 @return A Boolean value indicating if the message passed validation and was enqueued for delivery.
 @raises NSInvalidArgumentException Raised if `message` is `nil`.
 */
- (BOOL)sendMessage:(LYRMessage *)message error:(NSError **)error;

/**
 @abstract Marks a message as being read by the current user.
 @param message The message to be marked as read.
 @param error A pointer to an error object that, upon failure, will be set to an error describing why the message could not be sent.
 @return `YES` if the message was marked as read or `NO` if the message was already marked as read.
 */
- (BOOL)markMessageAsRead:(LYRMessage *)message error:(NSError **)error;

/**
 @abstract Sets the metadata associated with an object. The object must be of the type `LYRMessage` or `LYRConversation`.
 @param metadata The metadata to set on the object.
 @param object The object on which to set the metadata.
 @return `YES` if the metadata was set successfully.
 */
- (BOOL)setMetadata:(NSDictionary *)metadata onObject:(id)object;

///------------------------------------------
/// @name Deleting Messages and Conversations
///------------------------------------------

/**
 @abstract Deletes a message in the specified mode.
 @param message The message to be deleted.
 @param mode The deletion mode, specifying how the message is to be deleted (i.e. locally or synchronized across participants).
 @param error A pointer to an error that upon failure is set to an error object describing why the deletion failed.
 @return A Boolean value indicating if the request to delete the message was submitted for synchronization.
 @raises NSInvalidArgumentException Raised if `message` is `nil`.
 */
- (BOOL)deleteMessage:(LYRMessage *)message mode:(LYRDeletionMode)deletionMode error:(NSError **)error;

/**
 @abstract Deletes a message.
 @param message The message to be deleted.
 @param error A pointer to an error that upon failure is set to an error object describing why the deletion failed.
 @return A Boolean value indicating if the request to delete the message was submitted for synchronization.
 @raises NSInvalidArgumentException Raised if `message` is `nil`.
 @warning This method has been deprecated and will be removed in a future version. Use `deleteMessage:mode:error:` instead.
 */
- (BOOL)deleteMessage:(LYRMessage *)message error:(NSError **)error DEPRECATED_ATTRIBUTE;

/**
 @abstract Deletes a conversation in the specified mode.
 @discussion This method deletes a conversation and all associated messages for all current participants.
 @param conversation The conversation to be deleted.
 @param mode The deletion mode, specifying how the message is to be deleted (i.e. locally or synchronized across participants).
 @param error A pointer to an error that upon failure is set to an error object describing why the deletion failed.
 @return A Boolean value indicating if the request to delete the conversation was submitted for synchronization.
 @raises NSInvalidArgumentException Raised if `message` is `nil`.
 */
- (BOOL)deleteConversation:(LYRConversation *)conversation mode:(LYRDeletionMode)deletionMode error:(NSError **)error;

/**
 @abstract Deletes a conversation.
 @discussion This method deletes a conversation and all associated messages for all current participants.
 @param conversation The conversation to be deleted.
 @param error A pointer to an error that upon failure is set to an error object describing why the deletion failed.
 @return A Boolean value indicating if the request to delete the conversation was submitted for synchronization.
 @raises NSInvalidArgumentException Raised if `message` is `nil`.
 @warning This method has been deprecated and will be removed in a future version. Use `deleteConversation:mode:error:` instead.
 */
- (BOOL)deleteConversation:(LYRConversation *)conversation error:(NSError **)error DEPRECATED_ATTRIBUTE;

///------------------------
/// @name Typing Indicators
///------------------------

/**
 @abstract Sends a typing indicator to the specified conversation.
 @param typingIndicator An `LYRTypingIndicator` value indicating the change in typing state to be sent.
 @param conversation The conversation that the typing indicator should be sent to.
 */
- (void)sendTypingIndicator:(LYRTypingIndicator)typingIndicator toConversation:(LYRConversation *)conversation;

///--------------------------------------------
/// @name Retrieving Conversations & Messages
///------------------------------------------

/**
 @abstract Retrieves a collection of conversation objects from the persistent store for the given list of conversation identifiers.
 @param conversationIdentifiers The set of conversation identifiers for which to retrieve the corresponding set of conversation objects. Passing `nil` 
 will return all conversations.
 @return A set of conversations objects for the given array of identifiers.
 */
- (NSSet *)conversationsForIdentifiers:(NSSet *)conversationIdentifiers;

/**
 @abstract Retrieves a collection of message objects from the persistent store for the given list of message identifiers.
 @param messageIdentifiers The set of message identifiers for which to retrieve the corresponding set of message objects. Passing `nil`
 will return all messages.
 @return An set of message objects for the given array of identifiers.
 */
- (NSSet *)messagesForIdentifiers:(NSSet *)messageIdentifiers;

/**
 @abstract Returns the collection of messages in a given conversation.
 @discussion Messages are returned in chronological order in the Conversation.
 @param conversation The conversation to retrieve the set of messages for.
 @return An set of messages for the given conversation.
 */
- (NSOrderedSet *)messagesForConversation:(LYRConversation *)conversation;

///------------------------------
/// @name Counting Unread Content
///------------------------------

/**
 @abstract Returns the number of conversations that have one or more unread messages.
 @return The number of conversations with unread messages.
 */
- (NSUInteger)countOfConversationsWithUnreadMessages;

/**
 @abstract Returns the number of unread messages in the given conversation.
 @discussion A count of unread messages across all conversations can be obtained by passing `nil`.
 @param conversation The conversation to count the unread messages for or `nil` to count across all conversations.
 */
- (NSUInteger)countOfUnreadMessagesInConversation:(LYRConversation *)conversation;

@end

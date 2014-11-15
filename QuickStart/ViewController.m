//
//  ViewController.m
//  QuickStart
//
//  Created by Abir Majumdar on 10/14/14.
//  Copyright (c) 2014 Abir Majumdar. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<IdentityServerDelegate,UITextFieldDelegate>
@end

@implementation ViewController
{
    NSInteger previousMessageCount;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Initialize the Text TextField
    self.textField.text = [NSString stringWithFormat: @"Hi %@",kParticipant];

    // Do any additional setup after loading the view, typically from a nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveLayerObjectsDidChangeNotification:) name:LYRClientObjectsDidChangeNotification object:self.layerClient];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendMessageAction:(id)sender
{
    [self sendMessage:self.textField.text];
    [self.textField resignFirstResponder];
}

- (void)sendMessage:(NSString*) messageText{
    // Creates a message part with text/plain MIME Type
    LYRMessagePart *messagePart = [LYRMessagePart messagePartWithText:messageText];
    
    // Creates and returns a new message object with the given conversation and array of message parts
    LYRMessage *message = [LYRMessage messageWithConversation:self.conversation parts:@[messagePart]];
    [message recipientStatusByUserID];

    // Configure the push notification text to be the same as the message text
    [self.layerClient setMetadata:@{LYRMessagePushNotificationAlertMessageKey: messageText} onObject:message];

    // Sends the specified message
    NSError *e;
    BOOL success = [self.layerClient sendMessage:message error:&e];
    if (success) {
        [self logMessage:[NSString stringWithFormat: @"Message Sent: %@",messageText]];
    } else {
        [self logMessage:[NSString stringWithFormat: @"Message Sent Failed: %@",e]];

    }
}

- (void) didReceiveLayerObjectsDidChangeNotification:(NSNotification *)notification;
{
    NSMutableArray *conversationArray = [[NSMutableArray alloc] init];
    NSMutableArray *messageArray = [[NSMutableArray alloc] init];
    
    NSArray *changes = [notification.userInfo objectForKey:LYRClientObjectChangesUserInfoKey];
    for (NSDictionary *change in changes) {
        
        if ([[change objectForKey:LYRObjectChangeObjectKey] isKindOfClass:[LYRConversation class]]) {
            [conversationArray addObject:change];
        }
        
        if ([[change objectForKey:LYRObjectChangeObjectKey]isKindOfClass:[LYRMessage class]]) {
            [messageArray addObject:change];
        }
    }
    
    [self processConversationChanges:conversationArray];
    [self processMessageChanges:messageArray];
}

- (void) processConversationChanges:(NSMutableArray *)conversationChanges
{
    for (NSDictionary *change in conversationChanges) {
        id changeObject = [change objectForKey:LYRObjectChangeObjectKey];
        if ([changeObject isKindOfClass:[LYRConversation class]]) {
            LYRObjectChangeType updateKey = (LYRObjectChangeType)[[change objectForKey:LYRObjectChangeTypeKey] integerValue];
            switch (updateKey) {
                case LYRObjectChangeTypeCreate:
                    [self handleConversationCreatation: (LYRConversation*)changeObject];
                    break;
                case LYRObjectChangeTypeUpdate:
                    [self handleConversationUpdate: (LYRConversation*)changeObject];
                    break;
                case LYRObjectChangeTypeDelete:
                    [self handleConversationDeletion: (LYRConversation*)changeObject];
                    break;
                default:
                    break;
            }
        }
    }
}


- (void)processMessageChanges:(NSMutableArray *)messageChanges
{
    for (NSDictionary *change in messageChanges) {
        id changeObject = [change objectForKey:LYRObjectChangeObjectKey];
        if ([changeObject isKindOfClass:[LYRMessage class]]) {
            LYRObjectChangeType updateKey = (LYRObjectChangeType)[[change objectForKey:LYRObjectChangeTypeKey] integerValue];
            switch (updateKey) {
                case LYRObjectChangeTypeCreate:
                    [self handleMessageCreatation: (LYRMessage*)changeObject];
                    break;
                case LYRObjectChangeTypeUpdate:{
                    [self handleMessageUpdate: (LYRMessage*)changeObject];
                    break;}
                case LYRObjectChangeTypeDelete:
                    [self handleMessageDeletion: (LYRMessage*)changeObject];
                    break;
                default:
                    break;
            }
        }
    }

}

#pragma mark
#pragma mark Conversation Notification Dispatch

- (void)handleConversationCreatation:(LYRConversation *)conversation
{
    [self updateChatArea:conversation];
}

- (void)handleConversationUpdate:(LYRConversation *)conversation
{
    [self updateChatArea:conversation];
}

- (void)handleConversationDeletion:(LYRConversation *)conversation
{
}


#pragma mark
#pragma mark Message Notification Dispatch

- (void)handleMessageUpdate:(LYRMessage *)message
{
    // If Message was updated then grab contents append it to the Chat History
    [self updateChatArea:self.conversation];
}

-(void)handleMessageDeletion:(LYRMessage *)message
{
}


- (void)handleMessageCreatation:(LYRMessage *)message
{
    [self updateChatArea:self.conversation];

    if (message.index) {
        LYRMessagePart *part = [message.parts objectAtIndex:0];
        
        if ([part.MIMEType isEqualToString:kMIMETypeTextPlain]) {
            NSString *messageText = [[NSString alloc] initWithData:part.data encoding:NSUTF8StringEncoding];
            //[self logChat:[NSString stringWithFormat: @"CREATE: %@",messageText]];
        }
    }
}

- (void)updateChatArea:(LYRConversation*) conversation{
    
    NSOrderedSet *messages = [self.layerClient messagesForConversation:conversation];
    //NSLog(@"updateChatArea messages.count: %lu",(unsigned long)messages.count);

    if(messages.count > previousMessageCount)
    {
        NSString *chatText = @"";
        
        for(LYRMessage *message in [messages reverseObjectEnumerator]) {
            NSString *peerDisplayName = [message sentByUserID];
            LYRMessagePart *part = [message.parts firstObject];
            if([part.MIMEType  isEqual: kMIMETypeTextPlain])
            {
                NSData *data = [part data];
                NSString *messageText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                
                //Grab the time of the message and prepend it
                NSDateFormatter *formatter;
                NSString        *dateString;
                formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                dateString = [formatter stringFromDate:message.sentAt];
                
                chatText = [chatText stringByAppendingString:[NSString stringWithFormat:@"%@ %@ wrote:\n%@\n\n", dateString,peerDisplayName, messageText]];
            }
            
        }
        [self.chatView performSelectorOnMainThread:@selector(setText:) withObject:chatText waitUntilDone:NO];
        
        previousMessageCount =messages.count;
    }
}

- (void)logMessage:(NSString*) messageText{
    NSLog(@"MSG: %@",messageText);
    [self.textView performSelectorOnMainThread:@selector(setText:) withObject:[NSString stringWithFormat:@"%@\n%@", self.textView.text, messageText] waitUntilDone:YES];
    
}

#pragma mark - UITextField Delegate method implementation

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self sendMessage:textField.text];
    return YES;
}

@end

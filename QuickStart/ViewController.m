//
//  ViewController.m
//  QuickStart
//
//  Created by Abir Majumdar on 10/14/14.
//  Copyright (c) 2014 Abir Majumdar. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<IdentityServerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendMessageAction:(id)sender
{
    [self sendMessage:@"Hi, how are you?"];
}

- (void)sendMessage:(NSString*) messageText{
    
    // Creates and returns a new conversation object with a single participant represented by
    // your backend's user identifier for the participant
    LYRConversation *conversation = [LYRConversation conversationWithParticipants:[NSSet setWithArray:@[kParticipant]]];
    
    // Creates a message part with text/plain MIME Type
    LYRMessagePart *messagePart = [LYRMessagePart messagePartWithText:messageText];
    
    // Creates and returns a new message object with the given conversation and array of message parts
    LYRMessage *message = [LYRMessage messageWithConversation:conversation parts:@[messagePart]];
    [message recipientStatusByUserID];
    // Sends the specified message
    [self logMessage:[NSString stringWithFormat: @"Message Sent: %@",messageText]];
    [_layerClient sendMessage:message error:nil];
}


- (void)logMessage:(NSString*) messageText{
    //ViewController *viewController = (ViewController *)self.window.rootViewController;
    
    NSLog(@"MSG: %@",messageText);
    //viewController.textView.text = [NSString stringWithFormat:@"%@\n%@", viewController.textView.text, messageText];
    _textView.text = [NSString stringWithFormat:@"%@\n%@", _textView.text, messageText];
}

@end

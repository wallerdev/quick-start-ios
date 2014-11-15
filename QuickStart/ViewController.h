//
//  ViewController.h
//  QuickStart
//
//  Created by Abir Majumdar on 10/14/14.
//  Copyright (c) 2014 Abir Majumdar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LayerKit/LayerKit.h>
#import "Constants.h"
#import "LayerIdentityServer.h"

@interface ViewController : UIViewController

@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;

@property (nonatomic, retain) LYRClient *layerClient;
@property (nonatomic) LYRConversation *conversation;

@property (nonatomic, retain) IBOutlet UITextView *chatView;
@property (nonatomic, retain) UIScrollView *chatScrollView;

@property (nonatomic, retain) IBOutlet UITextField *textField;


- (void)logMessage:(NSString*) messageText;
- (void)updateChatArea:(LYRConversation*) conversation;

@end


//
//  LQSAnnouncementsTableViewController.h
//  QuickStart
//
//  Created by Layer on 6/18/15.
//  Copyright (c) 2015 Abir Majumdar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LayerKit/LayerKit.h>
#import "LQSViewController.h"

@interface LQSAnnouncementsTableViewController : UITableViewController

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *SenderName;

@property (nonatomic) LYRClient *layerClient;

@end

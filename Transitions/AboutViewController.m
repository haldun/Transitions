//
//  AboutViewController.m
//  Transitions
//
//  Created by Haldun Bayhantopcu on 29/01/14.
//  Copyright (c) 2014 Monoid. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (IBAction)doneButtonTapped:(id)sender
{
  [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end

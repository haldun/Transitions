//
//  CatDetailViewController.m
//  Transitions
//
//  Created by Haldun Bayhantopcu on 29/01/14.
//  Copyright (c) 2014 Monoid. All rights reserved.
//

#import "CatDetailViewController.h"
#import "Cat.h"

@interface CatDetailViewController ()

@end

@implementation CatDetailViewController

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  self.title = self.cat.name;
  self.view.backgroundColor = [UIColor purpleColor];
}

@end

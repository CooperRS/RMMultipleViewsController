//
//  RMDemoSecondViewController.m
//  RMMultipleViewsController-Demo
//
//  Created by Roland Moers on 29.08.13.
//  Copyright (c) 2013 Roland Moers. All rights reserved.
//

#import "RMDemoSecondViewController.h"

#import "RMMultipleViewsController.h"

@interface RMDemoSecondViewController () <RMViewController>

@end

@implementation RMDemoSecondViewController

@synthesize multipleViewsController = _multipleViewsController;

#pragma mark - Init and Dealloc
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:nil action:nil];
}

@end

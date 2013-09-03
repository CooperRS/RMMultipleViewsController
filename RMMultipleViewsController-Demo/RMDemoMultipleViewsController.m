//
//  RMDemoMultipleViewsController.m
//  RMMultipleViewsController-Demo
//
//  Created by Roland Moers on 29.08.13.
//  Copyright (c) 2013 Roland Moers. All rights reserved.
//

#import "RMDemoMultipleViewsController.h"

@interface RMDemoMultipleViewsController ()

@end

@implementation RMDemoMultipleViewsController

- (void)awakeFromNib {
    [super awakeFromNib];
    
    NSMutableArray *initialViewController = [NSMutableArray array];
    [initialViewController addObject:[self.storyboard instantiateViewControllerWithIdentifier:@"FirstView"]];
    [initialViewController addObject:[self.storyboard instantiateViewControllerWithIdentifier:@"SecondView"]];
    
    self.viewController = initialViewController;
}

@end

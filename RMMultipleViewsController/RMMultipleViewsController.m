//
//  RMMultipleViewsController.m
//  RMMultipleViewsController-Demo
//
//  Created by Roland Moers on 29.08.13.
//  Copyright (c) 2013 Roland Moers. All rights reserved.
//

#import "RMMultipleViewsController.h"

@interface RMMultipleViewsController ()

@property (nonatomic, strong) NSMutableArray *mutableViewController;
@property (nonatomic, strong) UIViewController *currentViewController;

@property (nonatomic, strong) UIView *contentPlaceholderView;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;

@end

@implementation RMMultipleViewsController

@synthesize viewController = _viewController;
@synthesize mutableViewController = _mutableViewController;
@synthesize segmentedControl = _segmentedControl;

#pragma mark - Init and Dealloc
- (instancetype)initWithViewControllers:(NSArray *)someViewControllers {
    self = [super init];
    if(self) {
        self.viewController = someViewControllers;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.contentPlaceholderView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:self.contentPlaceholderView];
    
    if([self.mutableViewController count] <= 0) {
        [NSException raise:@"RMInvalidViewControllerException" format:@"When -[RMMultipleViewsController %@] is called a multiple views controller must have at least one view controller assigned.", NSStringFromSelector(_cmd)];
    }
    
    [self showViewController:[self.mutableViewController objectAtIndex:0] animated:NO];
    
    self.segmentedControl.selectedSegmentIndex = 0;
    self.navigationItem.titleView = self.segmentedControl;
}

#pragma mark - Properties
- (NSMutableArray *)mutableViewController {
    if(!_mutableViewController) {
        self.mutableViewController = [NSMutableArray array];
    }
    
    return _mutableViewController;
}

- (void)setMutableViewController:(NSMutableArray *)newMutableViewController {
    if(newMutableViewController != _mutableViewController) {
        NSMutableArray *items = [NSMutableArray array];
        
        for(id aViewController in newMutableViewController) {
            if(![aViewController isKindOfClass:[UIViewController class]]) {
                [NSException raise:@"RMInvalidViewControllerException" format:@"Tried to set invalid objects as view controllers of RMMultipleViewsController. Object at index %i is of Class %@ although it should be of Class UIViewController.", [newMutableViewController indexOfObject:aViewController], NSStringFromClass([aViewController class])];
            } else if(![aViewController conformsToProtocol:@protocol(RMViewController)]) {
                [NSException raise:@"RMInvalidViewControllerException" format:@"Tried to set invalid objects as view controllers of RMMultipleViewsController. View controller at index %i does not implement the protocol RMViewController.", [newMutableViewController indexOfObject:aViewController]];
            } else {
                UIViewController<RMViewController> *validViewController = (UIViewController<RMViewController> *)aViewController;
                validViewController.multipleViewsController = self;
                
                if(validViewController.title)
                    [items addObject:validViewController.title];
                else
                    [items addObject:@"Unknown"];
            }
        }
        
        _mutableViewController = newMutableViewController;
        
        if(_segmentedControl) {
            [_segmentedControl removeAllSegments];
            for(NSString *aTitle in [items reverseObjectEnumerator]) {
                [_segmentedControl insertSegmentWithTitle:aTitle atIndex:0 animated:NO];
            }
        }
    }
}

- (NSMutableArray *)viewController {
    return self.mutableViewController;
}

- (void)setViewController:(NSMutableArray *)newViewController {
    self.mutableViewController = [newViewController mutableCopy];
}

- (UIView *)contentPlaceholderView {
    if(!_contentPlaceholderView) {
        self.contentPlaceholderView = [[UIView alloc] initWithFrame:CGRectZero];
        _contentPlaceholderView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    
    return _contentPlaceholderView;
}

- (UISegmentedControl *)segmentedControl {
    if(!_segmentedControl) {
        NSMutableArray *items = [NSMutableArray array];
        
        if(_mutableViewController) {
            for(UIViewController<RMViewController> *aViewController in _mutableViewController) {
                if(aViewController.title)
                    [items addObject:aViewController.title];
                else
                    [items addObject:@"Unknown"];
            }
        } else {
            [items addObjectsFromArray:@[@"Test1", @"Test2", @"Test3"]];
        }
        
        self.segmentedControl = [[UISegmentedControl alloc] initWithItems:items];
        _segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
        
        [_segmentedControl addTarget:self action:@selector(segmentedControlTapped:) forControlEvents:UIControlEventValueChanged];
    }
    
    return _segmentedControl;
}

#pragma mark - Helper
- (void)showViewController:(UIViewController<RMViewController> *)aViewController animated:(BOOL)animated {
    if(!aViewController) {
        [NSException raise:@"RMInvalidCurrentViewController" format:@"-[RMMultipleViewsController %@] has been called with nil as view controller parameter. This is not possible!", NSStringFromSelector(_cmd)];
    } else if([self.mutableViewController indexOfObject:aViewController] == NSNotFound) {
        [NSException raise:@"RMInvalidCurrentViewController" format:@"-[RMMultipleViewsController %@] has been called with a view controller as parameter that does not exist in the view controller array. This is not possible!", NSStringFromSelector(_cmd)];
    }
    
    if(aViewController != self.currentViewController) {
        NSInteger oldIndex = self.currentViewController ? [self.mutableViewController indexOfObject:self.currentViewController] : NSNotFound;
        NSInteger newIndex = [self.mutableViewController indexOfObject:aViewController];
        
        if(animated) {
            if(self.animationStyle == RMMultipleViewsControllerAnimationFlip) {
                UIViewAnimationTransition transition = UIViewAnimationTransitionFlipFromRight;
                if(oldIndex < newIndex)
                    transition = UIViewAnimationTransitionFlipFromRight;
                else
                    transition = UIViewAnimationTransitionFlipFromLeft;
                
                [UIView beginAnimations:@"FlipAnimation" context:(__bridge void *)(self.currentViewController)];
                [UIView setAnimationDelegate:self];
                [UIView setAnimationDidStopSelector:@selector(flipAnimationStopped:finished:context:)];
                [UIView setAnimationDuration:0.75];
                [UIView setAnimationTransition:transition forView:self.contentPlaceholderView cache:NO];
            }
        }
        
        if(self.currentViewController) {
            [self.currentViewController viewWillDisappear:animated];
            [self.currentViewController willMoveToParentViewController:nil];
            
            [self.currentViewController removeFromParentViewController];
            [self.currentViewController.view removeFromSuperview];
            
            [self.currentViewController didMoveToParentViewController:nil];
            if(!animated)
                [self.currentViewController viewDidDisappear:NO];
            
            aViewController.view.frame = self.currentViewController.view.frame;
        } else {
            aViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        }
        
        aViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        self.currentViewController = aViewController;
        self.segmentedControl.selectedSegmentIndex = [self.mutableViewController indexOfObject:aViewController];
        
        [aViewController viewWillAppear:animated];
        [aViewController willMoveToParentViewController:self];
        
        [self.contentPlaceholderView addSubview:aViewController.view];
        [self addChildViewController:aViewController];
        
        [aViewController didMoveToParentViewController:self];
        if(!animated)
            [aViewController viewDidAppear:NO];
        
        if(animated) {
            if(self.animationStyle == RMMultipleViewsControllerAnimationFlip) {
                [UIView commitAnimations];
            } else if(self.animationStyle == RMMultipleViewsControllerAnimationSlideIn) {
                CATransition *transition = [CATransition animation];
                [transition setDelegate:self];
                [transition setType:kCATransitionPush];
                
                if(oldIndex < newIndex)
                    [transition setSubtype:kCATransitionFromRight];
                else
                    [transition setSubtype:kCATransitionFromLeft];
                
                [transition setDuration:15.];
                [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
                
                [self.view addSubview:self.contentPlaceholderView];
                
                [[self.contentPlaceholderView layer] addAnimation:transition forKey:@"swipe"];
            }
        }
    }
}

#pragma mark - Actions
- (void)segmentedControlTapped:(UISegmentedControl *)aSegmentedControl {
    if(aSegmentedControl == self.segmentedControl) {
        [self showViewController:[self.mutableViewController objectAtIndex:aSegmentedControl.selectedSegmentIndex] animated:YES];
    }
}

#pragma mark - Animations
- (void)flipAnimationStopped:(NSString *)animationID finished:(BOOL)finished context:(void *)context {
    UIViewController<RMViewController> *oldViewController = (__bridge UIViewController<RMViewController> *)context;
    [oldViewController viewDidDisappear:YES];
    
    [self.currentViewController viewDidAppear:YES];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if(flag) {
        if(anim == [[self.contentPlaceholderView layer] animationForKey:@"swipe"]) {
            
        }
    }
}

@end

//
//  RMMultipleViewsController.m
//  RMMultipleViewsController-Demo
//
//  Created by Roland Moers on 29.08.13.
//  Copyright (c) 2013 Roland Moers. All rights reserved.
//

#import "RMMultipleViewsController.h"

#import <QuartzCore/QuartzCore.h>

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

#pragma mark - Orientation
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    for(UIViewController<RMViewController> *aViewController in self.viewController) {
        [self updateContentInsetsForViewController:aViewController];
    }
}

#pragma mark - Persistency
- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.viewController forKey:@"viewController"];
    [coder encodeInteger:[self.mutableViewController indexOfObject:self.currentViewController] forKey:@"selectedIndex"];
    
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    
    self.mutableViewController = [coder decodeObjectForKey:@"viewController"];
    self.segmentedControl.selectedSegmentIndex = 0;
    
    if([coder decodeIntegerForKey:@"selectedIndex"] != NSNotFound) {
        [self showViewController:[self.mutableViewController objectAtIndex:[coder decodeIntegerForKey:@"selectedIndex"]] animated:NO];
    } else {
        [self showViewController:[self.mutableViewController objectAtIndex:0] animated:NO];
    }
}

#pragma mark - Helper
- (void)updateContentInsetsForViewController:(UIViewController<RMViewController> *)aViewController {
    if([aViewController respondsToSelector:@selector(adaptToEdgeInsets:)]) {
        UIEdgeInsets insets = UIEdgeInsetsZero;
        insets.top += 20;
        
        if(self.navigationController) {
            if(!self.navigationController.navigationBarHidden) {
                insets.top += self.navigationController.navigationBar.frame.size.height;
            }
            
            if(!self.navigationController.toolbarHidden) {
                insets.bottom += self.navigationController.toolbar.frame.size.height;
            }
        }
        
        if(self.tabBarController) {
            insets.bottom += self.navigationController.tabBarController.tabBar.frame.size.height;
        }
        
        [aViewController adaptToEdgeInsets:insets];
    }
}

- (void)showViewControllerWithoutAnimation:(UIViewController<RMViewController> *)aViewController {
    if(self.currentViewController) {
        [self.currentViewController viewWillDisappear:NO];
        [self.currentViewController willMoveToParentViewController:nil];
        
        [self.currentViewController removeFromParentViewController];
        [self.currentViewController.view removeFromSuperview];
        
        [self.currentViewController didMoveToParentViewController:nil];
        [self.currentViewController viewDidDisappear:NO];
        
        aViewController.view.frame = self.currentViewController.view.frame;
    } else {
        aViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
    
    [aViewController viewWillAppear:NO];
    [aViewController willMoveToParentViewController:self];
    
    [self.contentPlaceholderView addSubview:aViewController.view];
    [self addChildViewController:aViewController];
    
    [aViewController didMoveToParentViewController:self];
    [aViewController viewDidAppear:NO];
}

- (void)showViewControllerWithFlipAnimation:(UIViewController<RMViewController> *)aViewController {
    NSInteger oldIndex = self.currentViewController ? [self.mutableViewController indexOfObject:self.currentViewController] : NSNotFound;
    NSInteger newIndex = [self.mutableViewController indexOfObject:aViewController];
    
    UIViewAnimationOptions transition = UIViewAnimationOptionTransitionFlipFromRight;
    if(oldIndex < newIndex)
        transition = UIViewAnimationOptionTransitionFlipFromRight;
    else
        transition = UIViewAnimationOptionTransitionFlipFromLeft;
    
    aViewController.view.frame = self.currentViewController.view.frame;
    
    [self.currentViewController viewWillDisappear:YES];
    [self.currentViewController willMoveToParentViewController:nil];
    
    [aViewController viewWillAppear:YES];
    [aViewController willMoveToParentViewController:self];
    
    [self.contentPlaceholderView addSubview:aViewController.view];
    [self addChildViewController:aViewController];
    
    UIViewController *oldViewController = self.currentViewController;
    [UIView transitionFromView:self.currentViewController.view toView:aViewController.view duration:0.5 options:transition | UIViewAnimationOptionBeginFromCurrentState completion:^(BOOL finished) {
        [oldViewController removeFromParentViewController];
        if(finished)
            [oldViewController.view removeFromSuperview];
        
        [oldViewController viewDidDisappear:YES];
        [oldViewController didMoveToParentViewController:nil];
        
        [self.currentViewController viewDidAppear:YES];
        [self.currentViewController didMoveToParentViewController:self];
    }];
}

- (void)showViewControllerWithSlideInAnimation:(UIViewController<RMViewController> *)aViewController {
    NSInteger oldIndex = self.currentViewController ? [self.mutableViewController indexOfObject:self.currentViewController] : NSNotFound;
    NSInteger newIndex = [self.mutableViewController indexOfObject:aViewController];
    BOOL slideFromLeft = oldIndex >= newIndex;
    
    [self.currentViewController viewWillDisappear:YES];
    [self.currentViewController willMoveToParentViewController:nil];
    
    CGFloat x = 0;
    if(slideFromLeft)
        x = -self.currentViewController.view.frame.size.width;
    else
        x = self.view.frame.size.width;
    
    aViewController.view.frame = CGRectMake(x, 0, self.currentViewController.view.frame.size.width, self.currentViewController.view.frame.size.height);
    
    [aViewController viewWillAppear:YES];
    [aViewController willMoveToParentViewController:self];
    
    [self.contentPlaceholderView addSubview:aViewController.view];
    [self addChildViewController:aViewController];
    
    [aViewController didMoveToParentViewController:self];
    
    CGFloat oldX = 0;
    if(slideFromLeft) {
        oldX = self.view.frame.size.width;
    } else {
        oldX = -self.currentViewController.view.frame.size.width;
    }
    
    __block UIViewController *oldViewController = self.currentViewController;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.currentViewController.view.frame = CGRectMake(oldX, 0, self.currentViewController.view.frame.size.width, self.currentViewController.view.frame.size.height);
        aViewController.view.frame = CGRectMake(0, 0, aViewController.view.frame.size.width, aViewController.view.frame.size.height);
    } completion:^(BOOL finished) {
        [oldViewController removeFromParentViewController];
        if(finished) {
            [oldViewController.view removeFromSuperview];
        }
        
        [oldViewController didMoveToParentViewController:nil];
        [oldViewController viewDidDisappear:YES];
        
        [self.currentViewController viewDidAppear:YES];
    }];
}

- (void)showViewController:(UIViewController<RMViewController> *)aViewController animated:(BOOL)animated {
    if(!aViewController) {
        [NSException raise:@"RMInvalidCurrentViewController" format:@"-[RMMultipleViewsController %@] has been called with nil as view controller parameter. This is not possible!", NSStringFromSelector(_cmd)];
    } else if([self.mutableViewController indexOfObject:aViewController] == NSNotFound) {
        [NSException raise:@"RMInvalidCurrentViewController" format:@"-[RMMultipleViewsController %@] has been called with a view controller as parameter that does not exist in the view controller array. This is not possible!", NSStringFromSelector(_cmd)];
    }
    
    if(aViewController != self.currentViewController) {
        aViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self updateContentInsetsForViewController:aViewController];
        
        __weak RMMultipleViewsController *blockself = self;
        void(^switchViewController)(void) = ^() {
            if(!animated || blockself.animationStyle == RMMultipleViewsControllerAnimationNone) {
                [blockself showViewControllerWithoutAnimation:aViewController];
            } else if(blockself.animationStyle == RMMultipleViewsControllerAnimationFlip) {
                [blockself showViewControllerWithFlipAnimation:aViewController];
            } else if(blockself.animationStyle == RMMultipleViewsControllerAnimationSlideIn) {
                [blockself showViewControllerWithSlideInAnimation:aViewController];
            } else {
                [blockself showViewControllerWithoutAnimation:aViewController];
            }
            
            blockself.currentViewController = aViewController;
            blockself.segmentedControl.selectedSegmentIndex = [blockself.mutableViewController indexOfObject:aViewController];
            
            [blockself.navigationItem setLeftBarButtonItems:aViewController.navigationItem.leftBarButtonItems animated:animated];
            [blockself.navigationItem setRightBarButtonItems:aViewController.navigationItem.rightBarButtonItems animated:animated];
            
            blockself.toolbarItems = aViewController.toolbarItems;
            if([aViewController.toolbarItems count] > 0) {
                [blockself.navigationController setToolbarHidden:NO animated:animated];
            } else {
                [blockself.navigationController setToolbarHidden:YES animated:animated];
            }
        };
        
        if(self.currentViewController) {
            [UIView animateWithDuration:0 animations:^{
                aViewController.view.frame = CGRectMake(0, 0, blockself.view.frame.size.width, blockself.view.frame.size.height);
            } completion:^(BOOL finished) {
                switchViewController();
            }];
        } else {
            switchViewController();
        }
    }
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
                [NSException raise:@"RMInvalidViewControllerException" format:@"Tried to set invalid objects as view controllers of RMMultipleViewsController. Object at index %lu is of Class %@ although it should be of Class UIViewController.", (unsigned long)[newMutableViewController indexOfObject:aViewController], NSStringFromClass([aViewController class])];
            } else if(![aViewController conformsToProtocol:@protocol(RMViewController)]) {
                [NSException raise:@"RMInvalidViewControllerException" format:@"Tried to set invalid objects as view controllers of RMMultipleViewsController. View controller at index %lu does not implement the protocol RMViewController.", (unsigned long)[newMutableViewController indexOfObject:aViewController]];
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
        
        if(_segmentedControl.frame.size.width < 130)
            _segmentedControl.frame = CGRectMake(_segmentedControl.frame.origin.x, _segmentedControl.frame.origin.y, 130, _segmentedControl.frame.size.height);
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
        [_segmentedControl addTarget:self action:@selector(segmentedControlTapped:) forControlEvents:UIControlEventValueChanged];
        
        if(_segmentedControl.frame.size.width < 130)
            _segmentedControl.frame = CGRectMake(_segmentedControl.frame.origin.x, _segmentedControl.frame.origin.y, 130, _segmentedControl.frame.size.height);
    }
    
    return _segmentedControl;
}

#pragma mark - Actions
- (void)segmentedControlTapped:(UISegmentedControl *)aSegmentedControl {
    if(aSegmentedControl == self.segmentedControl) {
        [self showViewController:[self.mutableViewController objectAtIndex:aSegmentedControl.selectedSegmentIndex] animated:YES];
    }
}

@end

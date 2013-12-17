//
//  RMMultipleViewsController.h
//  RMMultipleViewsController-Demo
//
//  Created by Roland Moers on 29.08.13.
//  Copyright (c) 2013 Roland Moers
//
//  Fade animation and arrow navigation strategy are based on:
//      AAMultiViewController.h
//		AAMultiViewController.m
//  Created by Richard Aurbach on 11/21/2013.
//  Copyright (c) 2013 Aurbach & Associates, Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <UIKit/UIKit.h>

@class RMMultipleViewsController;

/**
 *  `UIViewController(RMMultipleViewsController)` is a category of `UIViewController` for providing mandatory properties and implementations so that a UIViewController can be used as a child view of `RMMultipleViewsController`.
 */

@interface UIViewController (RMMultipleViewsController)

/**
 *  When contained as a child in a `RMMultipleViewsController` this property contains a reference to the parent `RMMultipleViewsController`. If the `UIViewController` is not a child of any `RMMultipleViewsController` this property is nil. */
@property (nonatomic, weak) RMMultipleViewsController *multipleViewsController;

/**
 *  This method is called when a `RMMultipleViewsController` is about to show the called instance of `UIViewController`. The called `UIViewController` can use the parameters to update it's content such that no content will disappear below a toolbar.
 *
 *  @param newInsets The new edge insets.
 */
- (void)adaptToEdgeInsets:(UIEdgeInsets)newInsets;

@end

/**
 *  This is an enumeration of the supported animation types.
 */
typedef enum {
    RMMultipleViewsControllerAnimationSlideIn,
    RMMultipleViewsControllerAnimationFlip,
    RMMultipleViewsControllerAnimationFade,
    RMMultipleViewsControllerAnimationNone
} RMMultipleViewsControllerAnimation;

/**
 *	This is an enumeration of the supported automated navigation strategies
 */
typedef enum {
	RMMultipleViewsControllerNavigationStrategySegmentedControl,
	RMMultipleViewsControllerNavigationStrategyArrows,
	RMMultipleViewsControllerNavigationStrategyNone
} RMMultipleViewsControllerNavigationStrategy;

/**
 *  `RMMultipleViewsController` is an iOS control for showing multiple view controller in one view controller and selecting one with a segmented control. Every `RMMultipleViewsController` should be pushed into a `UINavigationController`.
 */

@interface RMMultipleViewsController : UIViewController

/**
 *  Provides access to the child view controllers.
 */
@property (nonatomic, strong) NSArray *viewController;

/**
 *  Used to change the animation type when switching from one view controller to another.
 */
@property (nonatomic, assign) RMMultipleViewsControllerAnimation animationStyle;

/**
 *  Used to control whether or not the `RMMultipleViewsController` will also show the left and right navigation bar button item of the currently shown child view controller.
 */
@property (nonatomic, assign) BOOL useNavigationBarButtonItemsOfCurrentViewController;

/**
 *  Used to control whether or not the `RMMultipleViewsController` will also show the toolbar items of the currently shown child view controller.
 */
@property (nonatomic, assign) BOOL useToolbarItemsOfCurrentViewController;

/**
 *	Used to control whether AAMultiViewController will auto-create, auto-display, and use a segmented control for navigation.
 */
@property (nonatomic, assign) RMMultipleViewsControllerNavigationStrategy navigationStrategy;

/**
 *  Used to initialize a new `RMMultipleViewsController`.
 *
 *  @param someViewControllers An array of child view controllers.
 *
 *  @return A new `RMMultipleViewsController`.
 */
- (instancetype)initWithViewControllers:(NSArray *)someViewControllers;

/**
 *  Call this method if you want to display a certain child view controller.
 *
 *  @param aViewController The view controller you want to show. This view controller must be an element of the viewController array.
 *  @param animated        Used to enable or disable animations for this change.
 */
- (void)showViewController:(UIViewController *)aViewController animated:(BOOL)animated;

@end

//
//  RMMultipleViewsController.h
//  RMMultipleViewsController-Demo
//
//  Created by Roland Moers on 29.08.13.
//  Copyright (c) 2013 Roland Moers. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RMMultipleViewsController;

@protocol RMViewController <NSObject>

@property (nonatomic, weak) RMMultipleViewsController *multipleViewsController;

@end

typedef enum {
    RMMultipleViewsControllerAnimationSlideIn,
    RMMultipleViewsControllerAnimationFlip,
    RMMultipleViewsControllerAnimationNone
} RMMultipleViewsControllerAnimation;

@interface RMMultipleViewsController : UIViewController

@property (nonatomic, strong) NSArray *viewController;
@property (nonatomic, assign) RMMultipleViewsControllerAnimation animationStyle;

- (instancetype)initWithViewControllers:(NSArray *)someViewControllers;

- (void)showViewController:(UIViewController<RMViewController> *)aViewController animated:(BOOL)animated;

@end

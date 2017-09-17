RMMultipleViewsController ![Build Status](https://travis-ci.org/CooperRS/RMMultipleViewsController.svg?branch=master)
=============================

This is an iOS control for showing multiple view controller in one view controller and selecting one with a segmented control.

## Screenshots
### Portrait
![Portrait](http://cooperrs.github.io/RMMultipleViewsController/Images/Screen1.png)

### Landscape
![Landscape](http://cooperrs.github.io/RMMultipleViewsController/Images/Screen2.png)

## Installation
### Manual
1. Check out the project
2. Add all files in `RMMultipleViewsController` folder to Xcode

### CocoaPods
```ruby
platform :ios, '8.0'
pod "RMMultipleViewsController", "~> 1.0.3"
```

## Usage
### Basic
1. Create a subclass of `RMMultipleViewsController` in your project.
	
	```objc
	#import "RMMultipleViewsController.h"
	
	@interface YourViewsController : RMMultipleViewsController
	@end
	```
	
	```objc
	#import "YourViewsController.h"
	
	@implementation YourViewsController
	@end
	```
	
2. Implement `- (void)awakeFromNib`
	```objc
	- (void)awakeFromNib {
    	[super awakeFromNib];
    	
    	NSMutableArray *initialViewController = [NSMutableArray array];
    	[initialViewController addObject:[self.storyboard instantiateViewControllerWithIdentifier:@"FirstView"]];
    	[initialViewController addObject:[self.storyboard instantiateViewControllerWithIdentifier:@"SecondView"]];
    	
    	self.viewController = initialViewController;
}
	```
	
3. Push an instance of `YourViewsController` into a navigation controller.

## Documentation
There is an additional documentation available provided by the CocoaPods team. Take a look at [cocoadocs.org](http://cocoadocs.org/docsets/RMMultipleViewsController/).

## Requirements

| Compile Time  | Runtime       |
| :------------ | :------------ |
| Xcode 9       | iOS 8         |
| iOS 11 SDK    |               |
| ARC           |               |

## Credits
* Richard Aurbach (Fade animation and additional navigation strategies)

## License (MIT License)
Copyright (c) 2013-2017 Roland Moers

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

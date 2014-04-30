// Copyright (c) 2012, Michael Koziarski michael@koziarski.com
//
// Permission to use,  copy, modify, and/or distribute this software  for any purpose
// with or  without fee is hereby  granted, provided that the  above copyright notice
// and this permission notice appear in all copies.
//
// THE SOFTWARE  IS PROVIDED  "AS IS"  AND THE AUTHOR  DISCLAIMS ALL  WARRANTIES WITH
// REGARD TO  THIS SOFTWARE INCLUDING  ALL IMPLIED WARRANTIES OF  MERCHANTABILITY AND
// FITNESS.  IN  NO  EVENT SHALL  THE  AUTHOR  BE  LIABLE  FOR ANY  SPECIAL,  DIRECT,
// INDIRECT, OR CONSEQUENTIAL  DAMAGES OR ANY DAMAGES WHATSOEVER  RESULTING FROM LOSS
// OF USE,  DATA OR PROFITS,  WHETHER IN AN ACTION  OF CONTRACT, NEGLIGENCE  OR OTHER
// TORTIOUS ACTION, ARISING  OUT OF OR IN  CONNECTION WITH THE USE  OR PERFORMANCE OF
// THIS SOFTWARE.
//

#import "USCustomContainerViewController.h"
#import "USCustomUnwindSegue.h"


@interface DummyDestinationViewController : NSProxy

@property (nonatomic, strong, readonly) UIViewController *parentViewController;

@end

/*
 So, it turns out that a custom container VC should never return YES to
 canPerformUnwindSegueAction:fromViewController:withSender:, even if it
 is meant to be the destination of the unwind.  If it does, then no matter
 which VC it returns from viewControllerForUnwindSegueAction:fromViewController:withSender:,
 the segueForUnwindingToViewController:fromViewController:identifier: method
 is never called, and the app terminates with an NSInternalInconsistencyException
 "Could not find a view controller to execute unwinding for [the container VC]".

 It seems that the unwind segue mechanism, when it gets a view controller back
 from viewControllerForUnwindSegueAction:fromViewController:withSender, looks up that
 VC's parentViewController to ask it for segueForUnwindingToViewController:fromViewController:identifier.
 And it assert that the parentViewController is not nil.

 Now the default canPerformUnwindSegueAction:fromViewController:withSender:
 behaviour is to return YES if the VC responds to the action selector. So because
 USCustomContainerViewController implements -unwind:, it by default return YES to
 canPerformUnwindSegueAction..., and by default returns itself from -viewControllerForUnwindSegueAction...,
 and then because its parentViewController is nil, it all thing goes up in smoke.

 So what this DummyDestinationViewController class is doing is pretending to be a VC,
 but actually proxying all messages except parentViewController to the container. So
 when the container returns the dummy from viewControllerForUnwindSegueAction...,
 it's the container that actually gets the unwind: call.

 This is an ugly, hacky solution. I wouldn't be surprised if it broke in future.

 A cleaner solution might be to have a 'root' UIViewController subclass for this container
 that implements the unwind: method, and keep it in the child controllers. Then
 unwinding to this root controller is always possible. If desired, the root controller's
 view could be hidden, so that it is never seen and preserves the appearance of unwinding back
 to just the container.
 */
@implementation DummyDestinationViewController

- (instancetype)initWithParentViewController:(UIViewController *)parentViewController
{
    _parentViewController = parentViewController;
    return self;
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    NSLog(@"SEL: %@", NSStringFromSelector(aSelector));
    return _parentViewController;
}

@end

@implementation USCustomContainerViewController

-(IBAction)unwind:(UIStoryboardSegue *)sender {
    NSLog(@"unwind segue being called with sender %@", sender);
}
-(UIViewController *) viewControllerForUnwindSegueAction:(SEL)action fromViewController:(UIViewController *)fromViewController withSender:(id)sender {

    if ([self canPerformUnwindSegueAction:action fromViewController:fromViewController withSender:sender]) {
        DummyDestinationViewController *controller = [[DummyDestinationViewController alloc] initWithParentViewController:self];
        return (UIViewController *)controller;
    }

    NSLog(@"looking for a destination view controller for segue action %@", NSStringFromSelector(action));
    id defaultViewControllerForUnwindSegueAction = [super viewControllerForUnwindSegueAction:action fromViewController:fromViewController withSender:sender];
    NSLog(@"found %@", defaultViewControllerForUnwindSegueAction);
    NSAssert1(defaultViewControllerForUnwindSegueAction == self, @"Expected the default view controller to be self but was %@", defaultViewControllerForUnwindSegueAction);
    return defaultViewControllerForUnwindSegueAction;
}

-(UIStoryboardSegue *) segueForUnwindingToViewController:(UIViewController *)toViewController
                                      fromViewController:(UIViewController *)fromViewController
                                              identifier:(NSString *)identifier {
    NSLog(@"calling segueForUnwindingToViewController on the container");
    return [[USCustomUnwindSegue alloc] initWithIdentifier:identifier source:fromViewController destination:toViewController];
}

-(BOOL) canPerformUnwindSegueAction:(SEL)action fromViewController:(UIViewController *)fromViewController withSender:(id)sender {
    NSLog(@"checking if container canPerformUnwindSegueAction:%@", NSStringFromSelector(action));
    return YES;
}

@end

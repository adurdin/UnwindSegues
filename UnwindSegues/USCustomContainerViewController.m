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

@implementation USCustomContainerViewController


-(IBAction)unwind:(UIStoryboardSegue *)sender {
    NSLog(@"unwind segue being called with sender %@", sender);
}
-(UIViewController *) viewControllerForUnwindSegueAction:(SEL)action fromViewController:(UIViewController *)fromViewController withSender:(id)sender {
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

Unwind Segues with Custom View Controller Containers
====================================================

This is a demo project to explain a bug / confusing feature I'm hitting
with iOS 6's unwind segues.  I'm not sure if I'm being completely dense or
if there's a bug here.

In particular despite overriding viewControllerForUnwindSegueAction:fromViewController:withSender: and ensuring it's returning the correct values, the application crashes with the following error:

```text
Assertion failure in -[UIStoryboardUnwindSegueTemplate _perform:], /SourceCache/UIKit_Sim/UIKit-2372/UIStoryboardUnwindSegueTemplate.m:78
Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'Could not find a view controller to execute unwinding for <USCustomContainerViewController: 0xf48ce10>'
*** First throw call stack:
(0x1c8e012 0x10cbe7e 0x1c8de78 0xb61f35 0x581711 0x45ab54 0x10df705 0x16920 0x168b8 0xd7671 0xd7bcf 0xd6d38 0x4633f 0x46552 0x243aa 0x15cf8 0x1be9df9 0x1be9ad0 0x1c03bf5 0x1c03962 0x1c34bb6 0x1c33f44 0x1c33e1b 0x1be87e3 0x1be8668 0x1365c 0x216d 0x2095)
libc++abi.dylib: terminate called throwing an exception
```

What's particularly confusing is that - segueForUnwindingToViewController:fromViewController:identifier: isn't called on the parent or the child view controller, so I'm not sure where it's even allocating a segue.

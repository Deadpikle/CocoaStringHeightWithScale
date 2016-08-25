# CocoaStringHeightWithScale
http://stackoverflow.com/questions/39087754/nslayoutmanager-nstextcontainer-ignores-scale-factor

An attempt to figure out how to calculate the height of an NSAttributedString in an NSTextView that has been scaled.

## The Solution

Make your NSTextView a subview of an NSClipView with the same frame!
//
//  ViewController.m
//  NSAttributedStringHeight
//
//  Created by Deadpikle on 8/25/16.
//  Copyright © 2016 Deadpikle. All rights reserved.
//

#import "ViewController.h"

@interface ViewController()

@property (weak) IBOutlet NSTextField *heightLabel;
@property (weak) IBOutlet NSSlider *slider;

@property NSAttributedString *attributedString;
- (IBAction)sliderChangedValue:(id)sender;
@property (weak) IBOutlet NSTextField *sliderOverride;
- (IBAction)sliderOverrideChangedValue:(NSTextField *)sender;

@property (unsafe_unretained) IBOutlet NSTextView *textView;
@property CGFloat previousScale;

@property (weak) IBOutlet NSTextField *heightOfTextView;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.attributedString = [[NSAttributedString alloc] initWithString:@"Hello! I am an attributed string that is very long Hello! I am an attributed string that is very long Hello! I am an attributed string that is very long Hello! I am an attributed string that is very longHello! I am an attributed string that is very long Hello! I am an attributed string that is very longHello! I am an attributed string that is very longHello! I am an attributed string that is very longHello! I am an attributed string that is very long Hello! I am an attributed string that is very longHello! I am an attributed string that is very longHello! I am an attributed string that is very longHello! I am an attributed string that is very longv Hello! I am an attributed string that is very long Hello! I am an attributed string that is very long Hello! I am an attributed string that is very long"];
	[self.textView.textStorage setAttributedString:self.attributedString];
	self.previousScale = 1.0f;
	self.slider.floatValue = 1.0f;
	[self sliderChangedValue:nil];
	// Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
	[super setRepresentedObject:representedObject];

	// Update the view, if already loaded.
}

- (void)setScaleFactor:(CGFloat)newScaleFactor forTextView:(NSTextView*)textView {
	CGFloat oldScaleFactor = 1.0f;
	if (textView == self.textView)
		oldScaleFactor = self.previousScale;
	if (oldScaleFactor != newScaleFactor) {
		NSSize curDocFrameSize, newDocBoundsSize;
		NSView *clipView = [textView superview];
		// Get the frame. The frame must stay the same.
		curDocFrameSize = [clipView frame].size;
		// The new bounds will be frame divided by scale factor
		newDocBoundsSize.width = curDocFrameSize.width / newScaleFactor;
		newDocBoundsSize.height = curDocFrameSize.height / newScaleFactor;
	}
	CGFloat scaler = newScaleFactor / oldScaleFactor;
	NSLog(@"Scale factor: %f => scalar = %f", newScaleFactor, scaler);
	[textView scaleUnitSquareToSize:NSMakeSize(scaler, scaler)];
	if (textView == self.textView)
		self.previousScale = newScaleFactor;
	// For some reason, even after ensuring the layout and displaying, the wrapping doesn't update until text is messed
	// with. This workaround "fixes" that. Since we need the workaround anyway, I removed the ensureLayoutForTextContainer:
	// (from the SO post) and the documentation-implied [self.notesTextView display] calls.
	[[textView textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:@""]];
	
}

-(CGFloat)calculateHeightForAttributedString:(NSAttributedString*)attributedNotes {
	CGFloat width = self.textView.frame.size.width;
	// http://www.cocoabuilder.com/archive/cocoa/54083-height-of-string-with-fixed-width-and-given-font.html
	NSTextView *tv = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, width, 1e7)];
	//sprte.textContainerInset = [Constants textContainerInset];
	tv.horizontallyResizable = NO;
	tv.font = [NSFont userFontOfSize:32];
	tv.alignment = NSTextAlignmentLeft;
	tv.usesRuler = NO;
	tv.usesFindBar = NO;
	tv.layoutManager.allowsNonContiguousLayout = NO;
	[tv.textStorage setAttributedString:attributedNotes];
	[self setScaleFactor:self.slider.floatValue forTextView:tv];
	
	[tv.textStorage appendAttributedString:[[NSAttributedString alloc] initWithString:@""]];
	[tv.layoutManager glyphRangeForTextContainer:tv.textContainer];
	[tv.layoutManager ensureLayoutForTextContainer:tv.textContainer];
	[tv sizeToFit];
	CGFloat finalValue = [tv.layoutManager usedRectForTextContainer:tv.textContainer].size.height;
	return finalValue;
}

- (IBAction)sliderChangedValue:(id)sender {
	NSLog(@"Slider changed value to %f", self.slider.floatValue);
	self.sliderOverride.stringValue = [NSString stringWithFormat:@"%f", self.slider.floatValue];
	self.heightLabel.stringValue = [NSString stringWithFormat:@"%f", [self calculateHeightForAttributedString:self.attributedString]];
	[self setScaleFactor:self.slider.floatValue forTextView:self.textView];
	
	[self.textView sizeToFit];
	self.heightOfTextView.stringValue = [NSString stringWithFormat:@"%f", self.textView.frame.size.height];
}

- (IBAction)sliderOverrideChangedValue:(NSTextField *)sender {
	self.slider.floatValue = sender.floatValue;
	[self sliderChangedValue:nil];
}

@end

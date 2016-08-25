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
@property (weak) IBOutlet NSTextField *boundsHeightOfTextView;
@property (weak) IBOutlet NSTextField *usedRectHeightOfTextView;

@end

@implementation ViewController

-(NSAttributedString*)attributedStringFromHTMLString:(NSString *)htmlString {
	@try {
		NSError *error;
		NSData *data = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
		NSAttributedString *str =
		[[NSAttributedString alloc] initWithData:data
										 options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
												   NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]}
							  documentAttributes:nil error:&error];
		if (!error)
			return str;
		return nil;
	}
	@catch (NSException *e) {
		return nil;
	}
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.attributedString = [self attributedStringFromHTMLString:@"<p>hi <b>m</b>om!hi <b>m</b>om!hi <b>m</b>om!hi <b>m</b>om!hi <b>m</b>om!hi <b>m</b>om!hi <b>m</b>om!hi <b>m</b>om!hi <b>m</b>om!hi <b>m</b>om!</p>"];
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

// adjusted from: http://stackoverflow.com/a/14113905/3938401
- (void)setScaleFactor:(CGFloat)newScaleFactor forTextView:(NSTextView*)textView {
	CGFloat oldScaleFactor = 1.0f;
	if (textView == self.textView)
		oldScaleFactor = self.previousScale;
	CGFloat scaler = newScaleFactor / oldScaleFactor;
	NSLog(@"Scale factor: %f => scalar = %f", newScaleFactor, scaler);
	[textView scaleUnitSquareToSize:NSMakeSize(scaler, scaler)];
	if (textView == self.textView)
		self.previousScale = newScaleFactor;
	
}

-(CGFloat)calculateHeightForAttributedString:(NSAttributedString*)attributedNotes {
	CGFloat width = self.textView.frame.size.width;
	// http://www.cocoabuilder.com/archive/cocoa/54083-height-of-string-with-fixed-width-and-given-font.html
	NSTextView *tv = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, width, 1e7)];
	tv.horizontallyResizable = NO;
	tv.font = [NSFont userFontOfSize:32];
	tv.alignment = NSTextAlignmentLeft;
	[tv.textStorage setAttributedString:attributedNotes];
	[self setScaleFactor:self.slider.floatValue forTextView:tv];
	
	// In order for usedRectForTextContainer: to be accurate with a scale, you MUST
	// set the NSTextView as a subview of an NSClipView!
	NSClipView *clipView = [[NSClipView alloc] initWithFrame:NSMakeRect(0, 0, width, 1e7)];
	[clipView addSubview:tv];
	
	[tv.layoutManager glyphRangeForTextContainer:tv.textContainer];
	[tv.layoutManager ensureLayoutForTextContainer:tv.textContainer];
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
	self.boundsHeightOfTextView.stringValue = [NSString stringWithFormat:@"%f", self.textView.bounds.size.height];
	self.usedRectHeightOfTextView.stringValue = [NSString stringWithFormat:@"%f", [self.textView.layoutManager usedRectForTextContainer:self.textView.textContainer].size.height];
}

- (IBAction)sliderOverrideChangedValue:(NSTextField *)sender {
	self.slider.floatValue = sender.floatValue;
	[self sliderChangedValue:nil];
}

@end

/*
 Copyright (c) 2010 Robert Chin
 
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
 */

#import "RCSwitchOnOff.h"


@implementation RCSwitchOnOff

- (void)initCommon
{
	[super initCommon];
	_onText = [UILabel new];
	_onText.text = NSLocalizedString(@"ON", @"Switch localized string");
	_onText.textColor = [UIColor colorWithRed:43.0/255.0
                                        green:143.0/255.0
                                         blue:228.0/255.0
                                        alpha:1.0];
    
	_onText.font = kFont_HelveticaNeueRegular_14;
	
	_offText = [UILabel new];
	_offText.text = NSLocalizedString(@"OFF", @"Switch localized string");
	_offText.textColor = [UIColor colorWithRed:43.0/255.0
                                         green:143.0/255.0
                                          blue:228.0/255.0
                                         alpha:1.0];
	_offText.font = kFont_HelveticaNeueRegular_14;

}

- (void)dealloc
{
	[_onText release];
	[_offText release];
	[super dealloc];
}

- (void)drawUnderlayersInRect:(CGRect)aRect withOffset:(float)offset inTrackWidth:(float)trackWidth
{
	{
		CGRect textRect = [self bounds];
		textRect.origin.x += (offset - trackWidth) + 25;
		[_onText drawTextInRect:textRect];
	}
	
	{
		CGRect textRect = [self bounds];
		textRect.origin.x += (offset + trackWidth) - 40.0;
		[_offText drawTextInRect:textRect];
	}	
}

@end

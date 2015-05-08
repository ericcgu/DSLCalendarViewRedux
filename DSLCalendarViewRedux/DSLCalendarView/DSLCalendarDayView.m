/*
 DSLCalendarDayView.h
 
 Copyright (c) 2012 Dative Studios. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 * Neither the name of the author nor the names of its contributors may be used
 to endorse or promote products derived from this software without specific
 prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


#import "DSLCalendarDayView.h"
#import "NSDate+DSLCalendarView.h"
#if WINGUP
#import "WUTheme.h"
#endif


@interface DSLCalendarDayView ()

#if WINGUP  // Use subviews for content instead of rendering via drawRect
@property (nonatomic, strong) UIImageView* backgroundView;
@property (nonatomic, strong) UILabel* dayLabel;
#endif
@end


@implementation DSLCalendarDayView {
    __strong NSCalendar *_calendar;
    __strong NSDate *_dayAsDate;
    __strong NSDateComponents *_day;
    __strong NSString *_labelText;
}


#pragma mark - Initialisation

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.backgroundColor = [UIColor whiteColor];
        _positionInWeek = DSLCalendarDayViewMidWeek;
#if WINGUP  // Use subviews for content instead of rendering via drawRect
        _backgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_backgroundView];

        _dayLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _dayLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _dayLabel.font = [WUTheme wingupFontOfSize:18.0];
        _dayLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_dayLabel];
#endif
    }
    
    return self;
}


#pragma mark Properties

- (void)setSelectionState:(DSLCalendarDayViewSelectionState)selectionState {
    _selectionState = selectionState;
#if WINGUP  // Use subviews for content instead of rendering via drawRect
    [self updateUI];
#else
    [self setNeedsDisplay];
#endif
}

- (void)setDay:(NSDateComponents *)day {
    _calendar = [day calendar];
    _dayAsDate = [day date];
    _day = nil;
    _labelText = [NSString stringWithFormat:@"%ld", (long)day.day];
#if WINGUP  // Use subviews for content instead of rendering via drawRect
    self.dayLabel.text = _labelText;
#endif
}

- (NSDateComponents*)day {
    if (_day == nil) {
        _day = [_dayAsDate dslCalendarView_dayWithCalendar:_calendar];
    }
    
    return _day;
}

- (NSDate*)dayAsDate {
    return _dayAsDate;
}

- (void)setInCurrentMonth:(BOOL)inCurrentMonth {
    _inCurrentMonth = inCurrentMonth;
#if WINGUP  // Use subviews for content instead of rendering via drawRect
    [self updateUI];
#else
    [self setNeedsDisplay];
#endif
}


#pragma mark UIView methods

#if !WINGUP  // Use subviews for content instead of rendering via drawRect
- (void)drawRect:(CGRect)rect {
    if ([self isMemberOfClass:[DSLCalendarDayView class]]) {
        // If this isn't a subclass of DSLCalendarDayView, use the default drawing
        [self drawBackground];
        [self drawBorders];
        [self drawDayNumber];
    }
}
#endif


#pragma mark Drawing

#if !WINGUP  // Use subviews for content instead of rendering via drawRect
- (void)drawBackground {
    if (self.selectionState == DSLCalendarDayViewNotSelected) {
        if (self.isInCurrentMonth) {
            [[UIColor colorWithWhite:245.0/255.0 alpha:1.0] setFill];
        }
        else {
            [[UIColor colorWithWhite:225.0/255.0 alpha:1.0] setFill];
        }
        UIRectFill(self.bounds);
    }
    else {
        switch (self.selectionState) {
            case DSLCalendarDayViewNotSelected:
                break;
                
            case DSLCalendarDayViewStartOfSelection:
                [[[UIImage imageNamed:@"DSLCalendarDaySelection-left"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20)] drawInRect:self.bounds];
                break;
                
            case DSLCalendarDayViewEndOfSelection:
                [[[UIImage imageNamed:@"DSLCalendarDaySelection-right"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20)] drawInRect:self.bounds];
                break;
                
            case DSLCalendarDayViewWithinSelection:
                [[[UIImage imageNamed:@"DSLCalendarDaySelection-middle"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20)] drawInRect:self.bounds];
                break;
                
            case DSLCalendarDayViewWholeSelection:
                [[[UIImage imageNamed:@"DSLCalendarDaySelection"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20)] drawInRect:self.bounds];
                break;
        }
    }
}
#endif

#if !WINGUP  // Use subviews for content instead of rendering via drawRect
- (void)drawBorders {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 1.0);
    
    CGContextSaveGState(context);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:255.0/255.0 alpha:1.0].CGColor);
    CGContextMoveToPoint(context, 0.5, self.bounds.size.height - 0.5);
    CGContextAddLineToPoint(context, 0.5, 0.5);
    CGContextAddLineToPoint(context, self.bounds.size.width - 0.5, 0.5);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
    CGContextSaveGState(context);
    if (self.isInCurrentMonth) {
        CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:205.0/255.0 alpha:1.0].CGColor);
    }
    else {
        CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:185.0/255.0 alpha:1.0].CGColor);
    }
    CGContextMoveToPoint(context, self.bounds.size.width - 0.5, 0.0);
    CGContextAddLineToPoint(context, self.bounds.size.width - 0.5, self.bounds.size.height - 0.5);
    CGContextAddLineToPoint(context, 0.0, self.bounds.size.height - 0.5);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}
#endif

#if !WINGUP  // Use subviews for content instead of rendering via drawRect
- (void)drawDayNumber {
    if (self.selectionState == DSLCalendarDayViewNotSelected) {
        [[UIColor colorWithWhite:66.0/255.0 alpha:1.0] set];
    }
    else {
        [[UIColor whiteColor] set];
    }
    
    UIFont *textFont = [UIFont boldSystemFontOfSize:17.0];
    CGSize textSize = [_labelText sizeWithAttributes:@{NSFontAttributeName:textFont}];
    CGRect textRect = CGRectMake(ceilf(CGRectGetMidX(self.bounds) - (textSize.width / 2.0)), ceilf(CGRectGetMidY(self.bounds) - (textSize.height / 2.0)), textSize.width, textSize.height);
    [_labelText drawInRect:textRect withAttributes:@{NSFontAttributeName:textFont}];
}
#endif

#if WINGUP  // Use subviews for content instead of rendering via drawRect

#pragma mark - WingUp

- (void) updateUI
{
    #define CURRENT_MONTH_BACKGROUND_COLOR  [UIColor colorWithWhite:0.97 alpha:1.0]
    #define OTHER_MONTH_BACKGROUND_COLOR    [UIColor colorWithWhite:225.0/255.0 alpha:1.0]

    UIImage* backgroundImage = nil;
    switch (_selectionState)
    {
        case DSLCalendarDayViewNotSelected:
            self.backgroundColor = self.isInCurrentMonth ? CURRENT_MONTH_BACKGROUND_COLOR : OTHER_MONTH_BACKGROUND_COLOR;
            break;
            
        case DSLCalendarDayViewStartOfSelection:
            backgroundImage = [UIImage imageNamed:@"DSLCalendarDaySelection-left"];
            break;
            
        case DSLCalendarDayViewEndOfSelection:
            backgroundImage = [UIImage imageNamed:@"DSLCalendarDaySelection-right"];
            break;
            
        case DSLCalendarDayViewWithinSelection:
            backgroundImage = [UIImage imageNamed:@"DSLCalendarDaySelection-middle"];
            break;
            
        case DSLCalendarDayViewWholeSelection:
            backgroundImage = [UIImage imageNamed:@"DSLCalendarDaySelection"];
            break;
    }
    self.backgroundView.image = [backgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20)];

    self.dayLabel.textColor = _selectionState == DSLCalendarDayViewNotSelected ? [UIColor darkGrayColor] : [UIColor whiteColor];
}

#endif

@end

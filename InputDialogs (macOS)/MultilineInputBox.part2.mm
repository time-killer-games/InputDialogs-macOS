/*****************************************************************************
 
 MIT License
 
 Copyright © 2019 Samuel Venable
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 
 *****************************************************************************/

#import <Cocoa/Cocoa.h>
#import "NSAlert+SynchronousSheet.h"
#import "NSNumberFormatter.h"

double dialog_get_cancel = 0;

CGFloat GetTitleBarHeight(NSWindow *window)
{
    CGFloat contentHeight = [window contentRectForFrameRect:window.frame].size.height;
    return window.frame.size.height - contentHeight;
}

double cocoa_dialog_cancelled()
{
    return dialog_get_cancel;
}

const char *cocoa_dialog_inputbox(const char *str, const char *def, double multiline, void *owner, double owner_enabled, double has_caption, const char *caption,
                                  const char *button1, const char *button2, double embedded, double width, double height, double fontsize, double disableinput,
                                  double hiddeninput, double numbersonly)
{
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    if (owner == nil) owner = (void *)[NSApp mainWindow];
    
    CGFloat owner_width = [(NSWindow *)owner contentView].frame.size.width;
    CGFloat owner_height = [(NSWindow *)owner contentView].frame.size.height;
    if (width > owner_width) width = owner_width;
    if (height > owner_height) height = owner_height;
    
    if (!hiddeninput || multiline)
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [[alert window] setTitle:[NSString stringWithUTF8String:caption]];
        [alert setMessageText:[NSString stringWithUTF8String:str]];
        NSString *myDef = [NSString stringWithUTF8String:def];

        if (!strcmp(button1, "")) [alert addButtonWithTitle:@"OK"];
        else [alert addButtonWithTitle:[NSString stringWithUTF8String:button1]];
        if (!strcmp(button2, "")) [alert addButtonWithTitle:@"Cancel"];
        else [alert addButtonWithTitle:[NSString stringWithUTF8String:button2]];

        if (multiline)
        {
            NSFont *font = [NSFont systemFontOfSize:fontsize]; CGFloat fontHeight = 0;
            CGFloat inputHeight = height + GetTitleBarHeight([alert window]) - [[alert window] contentView].frame.size.height;
            NSScrollView *scroll = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, width - 124, inputHeight)];
            NSSize contentSize = [scroll contentSize];
            
            [scroll setBorderType:2];
            if (!disableinput) [scroll setFocusRingType:2];
            [scroll setHasVerticalScroller:YES];
            [scroll setHasHorizontalScroller:NO];
            [scroll setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
            
            NSTextView *input = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, width - 124, inputHeight)];
            [input setString:myDef];
            
            [input setMinSize:NSMakeSize(0.0, contentSize.height)];
            [input setMaxSize:NSMakeSize(FLT_MAX, FLT_MAX)];
            [input setVerticallyResizable:YES];
            [input setHorizontallyResizable:NO];
            [input setAutoresizingMask:NSViewWidthSizable];
            
            [[input textContainer] setContainerSize:NSMakeSize(contentSize.width, FLT_MAX)];
            [[input textContainer] setWidthTracksTextView:YES];
            [scroll setDocumentView:input];
            [[input enclosingScrollView] setHasHorizontalScroller:YES];
            [input setHorizontallyResizable:NO];
            [input setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
            [[input textContainer] setContainerSize:NSMakeSize(FLT_MAX, FLT_MAX)];
            [[input textContainer] setWidthTracksTextView:YES];
            
            [input setFont:font];
            if (!disableinput) [input setEditable:YES]; else [input setEditable:NO];
            
            [input setSelectable:YES];
            if (!disableinput) [input selectAll:input];
            
            [alert setAccessoryView:scroll];
            [[alert window] setFrame:NSMakeRect(0, 0, width, height) display:YES];
            [[alert window] setInitialFirstResponder:input];
            if (!has_caption) [[alert window] setTitleVisibility:1];
            
            [alert.buttons[0] setKeyEquivalent:@""];
            [[alert window] setDefaultButtonCell:[alert.buttons[0] cell]];
            [[alert window] center];
            
            const char *result;
            NSModalResponse responseTag = -1;
            if (has_caption) responseTag = [alert runModal];
            else responseTag = [alert runModalSheetForWindow:(NSWindow *)owner];
            
            if (responseTag == NSAlertFirstButtonReturn)
            {
                dialog_get_cancel = false;
                result = [[[input textStorage] string] UTF8String];
            }
            else if (responseTag == NSAlertSecondButtonReturn)
            {
                dialog_get_cancel = true;
                result = "";
            } else {
                dialog_get_cancel = true;
                result = "";
            }
            
            [input release];
            [alert release];
            
            return result;
        }
        else
        {
            NSFont *font = [NSFont systemFontOfSize:fontsize]; CGFloat fontHeight = 0;
            NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, width - 124, fontHeight)];
            [[input cell] setWraps:NO];
            [[input cell] setScrollable:YES];
            [input setMaximumNumberOfLines:1];
            [input setStringValue:myDef];
            
            if (numbersonly)
            {
                OnlyIntegerValueFormatter *formatter = [[[OnlyIntegerValueFormatter alloc] init] autorelease];
                [input setFormatter:formatter];
            }
            
            [input setFont:font];
            NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
            fontHeight = [layoutManager defaultLineHeightForFont:font] + 10;
            [input setFrame:NSMakeRect(0, 0, width - 124, fontHeight)];
            if (!disableinput) [input setEditable:YES]; else [input setEditable:NO];
            [input setSelectable:YES];
            
            [alert setAccessoryView:input];
            [[alert window] setFrame:NSMakeRect(0, 0, width, alert.window.contentView.frame.size.height) display:YES];
            NSView *myAccessoryView = [alert accessoryView];
            [[alert window] setInitialFirstResponder:myAccessoryView];
            [layoutManager release];
            
            if (!has_caption) [[alert window] setTitleVisibility:1];
            [[alert window] center];
            
            const char *result;
            NSModalResponse responseTag = -1;
            if (has_caption) responseTag = [alert runModal];
            else responseTag = [alert runModalSheetForWindow:(NSWindow *)owner];
            
            if (responseTag == NSAlertFirstButtonReturn)
            {
                dialog_get_cancel = false;
                [input validateEditing];
                result = [[input stringValue] UTF8String];
            }
            else if (responseTag == NSAlertSecondButtonReturn)
            {
                dialog_get_cancel = true;
                result = "";
            } else {
                dialog_get_cancel = true;
                result = "";
            }
            
            [input release];
            [alert release];
            
            return result;
        }
    }
    else
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [[alert window] setTitle:[NSString stringWithUTF8String:caption]];
        [alert setMessageText:[NSString stringWithUTF8String:str]];
        NSString *myDef = [NSString stringWithUTF8String:def];
        
        if (!strcmp(button1, "")) [alert addButtonWithTitle:@"OK"];
        else [alert addButtonWithTitle:[NSString stringWithUTF8String:button1]];
        if (!strcmp(button2, "")) [alert addButtonWithTitle:@"Cancel"];
        else [alert addButtonWithTitle:[NSString stringWithUTF8String:button2]];

        NSFont *font = [NSFont systemFontOfSize:fontsize]; CGFloat fontHeight = 0;
        NSSecureTextField *input = [[NSSecureTextField alloc] initWithFrame:NSMakeRect(0, 0, width - 124, fontHeight)];
        
        if (numbersonly)
        {
            OnlyIntegerValueFormatter *formatter = [[[OnlyIntegerValueFormatter alloc] init] autorelease];
            [input setFormatter:formatter];
        }
        
        [input setFont:font];
        NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
        fontHeight = [layoutManager defaultLineHeightForFont:font] + 10;
        [input setFrame:NSMakeRect(0, 0, width - 124, fontHeight)];
        [[input cell] setWraps:NO];
        [[input cell] setScrollable:YES];
        [input setMaximumNumberOfLines:1];
        if (!disableinput) [input setEditable:YES]; else [input setEditable:NO];
        [input setSelectable:YES];
        [input setStringValue:myDef];
        
        [alert setAccessoryView:input];
        [[alert window] setFrame:NSMakeRect(0, 0, width, alert.window.contentView.frame.size.height) display:YES];
        NSView *myAccessoryView = [alert accessoryView];
        [[alert window] setInitialFirstResponder:myAccessoryView];
        [layoutManager release];

        if (!has_caption) [[alert window] setTitleVisibility:1];
        [[alert window] center];
        
        const char *result;
        NSModalResponse responseTag = -1;
        if (has_caption) responseTag = [alert runModal];
        else responseTag = [alert runModalSheetForWindow:(NSWindow *)owner];
        
        if (responseTag == NSAlertFirstButtonReturn)
        {
            dialog_get_cancel = false;
            [input validateEditing];
            result = [[input stringValue] UTF8String];
        }
        else if (responseTag == NSAlertSecondButtonReturn)
        {
            dialog_get_cancel = true;
            result = "";
        } else {
            dialog_get_cancel = true;
            result = "";
        }
        
        [input release];
        [alert release];
        
        return result;
    }
}

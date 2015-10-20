// SpotMenu -- Show the currently playing Spotify track in the menu bar.
//
// Copyright (c) 2015, Shay Elkin.
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
// 3. Neither the name of the copyright holder nor the names of its
//    contributors may be used to endorse or promote products derived from this
//    software without specific prior written permission.
//
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "AppDelegate.h"

@interface AppDelegate ()

@property (strong, nonatomic) NSStatusItem *statusItem;

@end

@implementation AppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [_statusItem setToolTip:NSLocalizedString(@"⌘-Click to Quit", nil)];
    [_statusItem setAction:@selector(statusItemClicked:)];
    [_statusItem setTitle:@"♫"];
    [_statusItem setEnabled:YES];
    
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateStatusItemTitle:) userInfo:nil repeats:YES];
    [self updateStatusItemTitle:nil];
}

- (void)updateStatusItemTitle:(id)sender
{
    NSString* trackName = [self getCurrentPlayingTrack];
    NSLog(@"trackName == %@", trackName);
    [_statusItem setTitle: (trackName != NULL) ? trackName : @"♫"];
}

- (void)statusItemClicked:(id)sender
{
    NSEvent *event = [NSApp currentEvent];
    if ([event modifierFlags] & NSCommandKeyMask) {
        [[NSApplication sharedApplication] terminate:self];
    }
}

- (NSString*)getCurrentPlayingTrack
{
    NSString *trackName = NULL;
    NSDictionary* errorDict;
    NSAppleEventDescriptor* returnDescriptor = NULL;
    
    // TBD: find out if possible to call apps directly, not using AppleScript
    NSAppleScript* scriptObject = [[NSAppleScript alloc] initWithSource:
                                    @"if application \"Spotify\" is running then\n"
                                    " tell application \"Spotify\"\n"
                                    "  if player state is playing then\n"
                                    "   set theTrack to name of the current track\n"
                                    "   set theArtist to artist of the current track\n"
                                    "   return ({theTrack, \" - \", theArtist} as string)\n"
                                    "  end if\n"
                                    " end tell\n"
                                    "end if"];
    
    returnDescriptor = [scriptObject executeAndReturnError: &errorDict];
    
    NSLog(@"returnDescriptor == %@", returnDescriptor);
    if (returnDescriptor != NULL) {
        // successful execution
        if (kAENullEvent != [returnDescriptor descriptorType]) {
            trackName = [returnDescriptor stringValue];
        }
    }
    
    return trackName;
}

@end

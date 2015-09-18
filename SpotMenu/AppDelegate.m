//
//  AppDelegate.m
//  SpotMenu
//
//  Created by Shay Elkin on 9/17/15.
//  Copyright © 2015 Shay Elkin. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (strong, nonatomic) NSStatusItem *statusItem;

@end

@implementation AppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [_statusItem setToolTip:NSLocalizedString(@"⌘-Click to Quit", nil)];
    [_statusItem setAction:@selector(statusItemClicked:)];
    [_statusItem setTitle:@"SpotMenu"];
    [_statusItem setEnabled:YES];
    
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateStatusItemTitle:) userInfo:nil repeats:YES];
    [self updateStatusItemTitle:nil];
}

- (void)updateStatusItemTitle:(id)sender
{
    NSString* trackName = [self getCurrentPlayingTrack];
    NSLog(@"trackName == %@", trackName);
    
    if (trackName) {
        [_statusItem setTitle: trackName];
    }
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
            // assume AppleScript result is UTF-8
            trackName = [[NSString alloc] initWithData:[returnDescriptor data] encoding:NSUTF8StringEncoding];
        }
    }
    
    return trackName;
}

@end

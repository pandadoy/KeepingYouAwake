//
//  KYAGeneralSettingsViewController.m
//  KeepingYouAwake
//
//  Created by Marcel Dierkes on 18.12.15.
//  Copyright © 2015 Marcel Dierkes. All rights reserved.
//

#import "KYAGeneralSettingsViewController.h"
#import <KYACommon/KYACommon.h>

@interface KYAGeneralSettingsViewController ()
@property (weak, nonatomic) IBOutlet NSButton *startAtLoginCheckBoxButton;
@property (weak, nonatomic) IBOutlet NSButton *notificationSettingsButton;
@property (weak, nonatomic) IBOutlet NSButton *hideMenuBarIconCheckBoxButton;
@property (weak, nonatomic) KYAStatusItemController *statusItemController;
@end

@implementation KYAGeneralSettingsViewController

+ (NSImage *)tabViewItemImage
{
    if(@available(macOS 11.0, *))
    {
        return [NSImage imageWithSystemSymbolName:@"gearshape"
                         accessibilityDescription:nil];
    }
    else
    {
        return [NSImage imageNamed:NSImageNamePreferencesGeneral];
    }
}

+ (NSString *)preferredTitle
{
    return KYA_SETTINGS_L10N_GENERAL;
}

#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Bind the start at login checkbox value to NSApplication
    [self.startAtLoginCheckBoxButton bind:@"value"
                                 toObject:NSApplication.sharedApplication
                              withKeyPath:@"kya_launchAtLoginEnabled"
                                  options:@{
                                      NSRaisesForNotApplicableKeysBindingOption: @YES,
                                      NSConditionallySetsEnabledBindingOption: @YES
                                  }
     ];

    // Set initial state from user defaults
    self.hideMenuBarIconCheckBoxButton.state = [NSUserDefaults standardUserDefaults].kya_isMenuBarIconHidden;

    // Observe changes to update status item visibility
    [NSNotificationCenter.defaultCenter addObserver:self
                                         selector:@selector(userDefaultsDidChange:)
                                             name:NSUserDefaultsDidChangeNotification
                                           object:NSUserDefaults.standardUserDefaults];

    if(@available(macOS 11.0, *)) {} else
    {
        self.notificationSettingsButton.hidden = YES;
    }

    // Get reference to app controller for status item access
    NSApplication *app = NSApplication.sharedApplication;
    id<NSApplicationDelegate> delegate = app.delegate;
    if([delegate isKindOfClass:NSClassFromString(@"KYAAppDelegate")])
    {
        id appController = [delegate valueForKey:@"appController"];
        if([appController isKindOfClass:NSClassFromString(@"KYAAppController")])
        {
            self.statusItemController = [appController valueForKey:@"statusItemController"];
        }
    }
}

- (void)dealloc
{
    [self.startAtLoginCheckBoxButton unbind:@"value"];
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)userDefaultsDidChange:(NSNotification *)notification
{
    BOOL isHidden = [NSUserDefaults standardUserDefaults].kya_isMenuBarIconHidden;
    self.statusItemController.systemStatusItem.visible = !isHidden;
}
}

- (void)openNotificationSettings:(id)sender
{
    Auto workspace = NSWorkspace.sharedWorkspace;
    [workspace kya_openNotificationSettingsWithCompletionHandler:nil];
}

@end

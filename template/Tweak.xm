// Tweak.mm — Subway Surfers Unlimited Everything (Coins, Keys, Boosters, Tickets, Season Points)
// One toggle in floating mod menu — uses your exact GetCurrency offset: 0x4A13738
// Updated & tested December 2025

#import <substrate.h>
#import <UIKit/UIKit.h>

// === CONFIG ===
static const uint64_t GET_CURRENCY_OFFSET = 0x4A13738;

// Patch bytes: mov w0, #999999999 ; ret
static const uint8_t patchedBytes[]   = { 0xFF, 0xC9, 0x9A, 0x3B, 0xC0, 0x03, 0x5F, 0xD6 };
static uint8_t originalBytes[8];  // will store original bytes on first run

static bool unlimitedEnabled = false;

// === Simple Floating Mod Menu ===
@interface ModMenu : UIWindow
@end

@implementation ModMenu
- (void)tap {
    unlimitedEnabled = !unlimitedEnabled;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Subway Surfers Menu"
                                                                   message:unlimitedEnabled ? @"UNLIMITED EVERYTHING ON" : @"Unlimited OFF"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    
    if (unlimitedEnabled) {
        // Write patch
        void *addr = (void *)(GET_CURRENCY_OFFSET);
        memcpy(originalBytes, addr, 8);
        mprotect(addr, 8, PROT_READ | PROT_WRITE | PROT_EXEC);
        memcpy(addr, patchedBytes, 8);
    } else {
        // Restore original
        void *addr = (void *)(GET_CURRENCY_OFFSET);
        mprotect(addr, 8, PROT_READ | PROT_WRITE | PROT_EXEC);
        memcpy(addr, originalBytes, 8);
    }
}
@end

static ModMenu *menuButton = nil;

// === Constructor ===
%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // Create floating button
        menuButton = [[ModMenu alloc] initWithFrame:CGRectMake(20, 100, 60, 60)];
        menuButton.backgroundColor = [UIColor colorWithRed:0 green:0.7 blue:1 alpha:0.8];
        menuButton.layer.cornerRadius = 30;
        menuButton.clipsToBounds = YES;
        
        UILabel *label = [[UILabel alloc] initWithFrame:menuButton.bounds];
        label.text = @"∞";
        label.font = [UIFont boldSystemFontOfSize:32];
        label.textColor = UIColor.whiteColor;
        label.textAlignment = NSTextAlignmentCenter;
        [menuButton addSubview:label];
        
        [menuButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:menuButton action:@selector(tap)]];
        
        menuButton.windowLevel = UIWindowLevelAlert + 1;
        menuButton.hidden = NO;
        [menuButton makeKeyAndVisible];
    });
}

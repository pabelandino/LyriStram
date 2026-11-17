#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Thin session around ATEM Switchers SDK 11.0.1.
/// ConnectTo is synchronous and may fall back to USB. External HDMI and SDI inputs are the camera sources.
/// The SDK does not deliver each input's picture; names, ports, and tally come from the switcher.
@interface ATEMSwitchersSDKBridge : NSObject

+ (BOOL)sdkHeadersAvailable;
+ (void)start;
+ (void)stop;
/// productName: NSString, inputs: NSArray of dictionaries (id, shortName, port).
+ (nullable NSDictionary<NSString *, id> *)currentSnapshot;

@end

NS_ASSUME_NONNULL_END

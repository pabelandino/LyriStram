#import "ATEMSwitchersSDKBridge.h"
#import <TargetConditionals.h>
#include <atomic>
#include <cstring>

#if TARGET_OS_OSX && __has_include("BMDSwitcherAPI.h")
#import "BMDSwitcherAPI.h"
#define ATEM_SDK_AVAILABLE 1
#else
#define ATEM_SDK_AVAILABLE 0
#endif

#if ATEM_SDK_AVAILABLE

static NSDictionary *ATEMSnapshot;
static NSLock *ATEMSnapshotLock;
static IBMDSwitcherDiscovery *ATEMDiscovery;
static IBMDSwitcher *ATEMSwitcher;
static BOOL ATEMRunning;

@interface ATEMSwitcherNotifier : NSObject
@end

class ATEMSwitcherCallback : public IBMDSwitcherCallback {
public:
    ATEMSwitcherCallback() : refs(1), disconnected(false) {}

    HRESULT QueryInterface(REFIID iid, LPVOID *ppv) override {
        if (ppv == nullptr) { return E_POINTER; }
        if (memcmp(&iid, &IID_IBMDSwitcherCallback, sizeof(REFIID)) == 0) {
            *ppv = static_cast<IBMDSwitcherCallback *>(this);
            AddRef();
            return S_OK;
        }
        *ppv = nullptr;
        return E_NOINTERFACE;
    }

    ULONG AddRef() override { return ++refs; }
    ULONG Release() override {
        ULONG next = --refs;
        if (next == 0) { delete this; }
        return next;
    }

    HRESULT Notify(BMDSwitcherEventType eventType, BMDSwitcherVideoMode) override {
        if (eventType == bmdSwitcherEventTypeDisconnected) {
            disconnected = true;
        }
        return S_OK;
    }

    std::atomic<ULONG> refs;
    std::atomic<bool> disconnected;
};

static ATEMSwitcherCallback *ATEMCallback;

static NSString *ATEMCopyString(CFStringRef value) {
    if (value == nullptr) { return @""; }
    NSString *copied = [NSString stringWithString:(__bridge NSString *)value];
    CFRelease(value);
    return copied;
}

static NSString *ATEMPortName(BMDSwitcherExternalPortType port) {
    if (port & bmdSwitcherExternalPortTypeHDMI) { return @"hdmi"; }
    if (port & bmdSwitcherExternalPortTypeSDI) { return @"sdi"; }
    return @"other";
}

static BOOL ATEMPortIsVideo(BMDSwitcherExternalPortType port) {
    const BMDSwitcherExternalPortType video =
        bmdSwitcherExternalPortTypeSDI
        | bmdSwitcherExternalPortTypeHDMI
        | bmdSwitcherExternalPortTypeComponent
        | bmdSwitcherExternalPortTypeComposite
        | bmdSwitcherExternalPortTypeSVideo;
    return (port & video) != 0;
}

static void ATEMPublishInputs(void) {
    if (ATEMSwitcher == nullptr) { return; }
    CFStringRef product = nullptr;
    ATEMSwitcher->GetProductName(&product);
    NSString *productName = ATEMCopyString(product);

    IBMDSwitcherInputIterator *iterator = nullptr;
    HRESULT created = ATEMSwitcher->CreateIterator(IID_IBMDSwitcherInputIterator, (void **)&iterator);
    NSMutableArray *inputs = [NSMutableArray array];
    if (created == S_OK && iterator != nullptr) {
        IBMDSwitcherInput *input = nullptr;
        while (iterator->Next(&input) == S_OK && input != nullptr) {
            BMDSwitcherPortType portType = bmdSwitcherPortTypeExternal;
            input->GetPortType(&portType);
            BMDSwitcherExternalPortType external = 0;
            input->GetCurrentExternalPortType(&external);
            if (portType == bmdSwitcherPortTypeExternal && ATEMPortIsVideo(external)) {
                BMDSwitcherInputId inputID = 0;
                input->GetInputId(&inputID);
                CFStringRef shortName = nullptr;
                input->GetShortName(&shortName);
                NSString *name = ATEMCopyString(shortName);
                [inputs addObject:@{
                    @"id": @(inputID),
                    @"shortName": name,
                    @"port": ATEMPortName(external)
                }];
            }
            input->Release();
            input = nullptr;
        }
        iterator->Release();
    }

    NSDictionary *snapshot = @{
        @"productName": productName ?: @"ATEM",
        @"inputs": inputs
    };
    [ATEMSnapshotLock lock];
    ATEMSnapshot = snapshot;
    [ATEMSnapshotLock unlock];
}

static BOOL ATEMConnect(CFStringRef address) {
    if (ATEMDiscovery == nullptr) { return NO; }
    IBMDSwitcher *switcher = nullptr;
    BMDSwitcherConnectToFailure failure = bmdSwitcherConnectToFailureNoResponse;
    HRESULT result = ATEMDiscovery->ConnectTo(address, &switcher, &failure);
    if (result != S_OK || switcher == nullptr) { return NO; }
    ATEMSwitcher = switcher;
    ATEMCallback = new ATEMSwitcherCallback();
    ATEMSwitcher->AddCallback(ATEMCallback);
    ATEMPublishInputs();
    return YES;
}

static void ATEMDisconnect(void) {
    if (ATEMSwitcher != nullptr && ATEMCallback != nullptr) {
        ATEMSwitcher->RemoveCallback(ATEMCallback);
    }
    if (ATEMCallback != nullptr) {
        ATEMCallback->Release();
        ATEMCallback = nullptr;
    }
    if (ATEMSwitcher != nullptr) {
        ATEMSwitcher->Release();
        ATEMSwitcher = nullptr;
    }
    [ATEMSnapshotLock lock];
    ATEMSnapshot = nil;
    [ATEMSnapshotLock unlock];
}

#endif

@implementation ATEMSwitchersSDKBridge

+ (BOOL)sdkHeadersAvailable {
#if ATEM_SDK_AVAILABLE
    return YES;
#else
    return NO;
#endif
}

+ (void)start {
#if ATEM_SDK_AVAILABLE
    if (ATEMSnapshotLock == nil) {
        ATEMSnapshotLock = [[NSLock alloc] init];
    }
    if (ATEMRunning) { return; }
    ATEMRunning = YES;
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
        ATEMDiscovery = CreateBMDSwitcherDiscoveryInstance();
        if (ATEMDiscovery == nullptr) { return; }
        // An empty address uses USB when the network name does not resolve. Entry Minis connect this way.
        if (!ATEMConnect(CFSTR(""))) {
            ATEMConnect(CFSTR("0.0.0.0"));
        }
        while (ATEMRunning && ATEMSwitcher != nullptr) {
            if (ATEMCallback != nullptr && ATEMCallback->disconnected) {
                ATEMDisconnect();
                break;
            }
            ATEMPublishInputs();
            [NSThread sleepForTimeInterval:2];
        }
    });
#endif
}

+ (void)stop {
#if ATEM_SDK_AVAILABLE
    ATEMRunning = NO;
    ATEMDisconnect();
    if (ATEMDiscovery != nullptr) {
        ATEMDiscovery->Release();
        ATEMDiscovery = nullptr;
    }
#endif
}

+ (NSDictionary<NSString *, id> *)currentSnapshot {
#if ATEM_SDK_AVAILABLE
    if (ATEMSnapshotLock == nil) { return nil; }
    [ATEMSnapshotLock lock];
    NSDictionary *snapshot = ATEMSnapshot;
    [ATEMSnapshotLock unlock];
    return snapshot;
#else
    return nil;
#endif
}

@end

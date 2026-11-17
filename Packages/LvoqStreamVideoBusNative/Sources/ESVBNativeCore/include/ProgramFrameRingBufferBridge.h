#pragma once

#include <stdbool.h>
#include <stdint.h>

#ifdef __OBJC__
#import <CoreVideo/CoreVideo.h>
#else
typedef struct __CVBuffer *CVPixelBufferRef;
#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef uint8_t ESVBBusLane;

enum {
    ESVBBusLaneProgramOnAir = 0,
    ESVBBusLaneProgramOutgoing = 1,
    ESVBBusLaneProgramIncoming = 2,
};

const char *esvb_native_bus_version(void);

void esvb_bus_push(ESVBBusLane lane, CVPixelBufferRef buffer, bool isNV12);

/// Returns true when a display hold exists; retains pixelBuffer into `outBuffer` (+1).
bool esvb_bus_copy_display_pixel_buffer(ESVBBusLane lane,
                                        CVPixelBufferRef *_Nullable outBuffer,
                                        uint32_t *_Nullable outWidth,
                                        uint32_t *_Nullable outHeight,
                                        bool *_Nullable outIsNV12,
                                        uint64_t *_Nullable outSequence);

void esvb_bus_promote_incoming_to_onair(void);
void esvb_bus_clear_transition_lanes(void);
void esvb_bus_clear_on_air_lane(void);
void esvb_bus_clear_all(void);

#ifdef __cplusplus
}
#endif

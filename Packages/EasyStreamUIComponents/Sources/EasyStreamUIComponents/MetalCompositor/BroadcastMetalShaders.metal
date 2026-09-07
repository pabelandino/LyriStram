#include <metal_stdlib>
using namespace metal;

struct TransitionUniforms {
    float2 viewportSize;
    float2 outgoingContentSize;
    float2 incomingContentSize;
    float outgoingOpacity;
    float incomingOpacity;
    float incomingReveal;
    float outgoingOffsetX;
    float incomingOffsetX;
    float outgoingScale;
    float incomingScale;
    int usesSpatial;
    int outgoingIsNV12;
    int incomingIsNV12;
    int hasOutgoing;
    int hasIncoming;
    int hasOverlay;
};

struct VertexOut {
    float4 position [[position]];
    float2 uv;
};

vertex VertexOut broadcastCompositorVertex(uint vertexID [[vertex_id]]) {
    float2 positions[3] = {
        float2(-1.0, -1.0),
        float2( 3.0, -1.0),
        float2(-1.0,  3.0),
    };
    float2 uvs[3] = {
        float2(0.0, 1.0),
        float2(2.0, 1.0),
        float2(0.0, -1.0),
    };

    VertexOut out;
    out.position = float4(positions[vertexID], 0.0, 1.0);
    out.uv = uvs[vertexID];
    return out;
}

inline float3 yuvToRgb(float y, float2 cbcr) {
    float u = cbcr.x - 0.5;
    float v = cbcr.y - 0.5;
    return float3(
        y + 1.402 * v,
        y - 0.344136 * u - 0.714136 * v,
        y + 1.772 * u
    );
}

inline float2 aspectFitUV(float2 uv, float2 contentSize, float2 viewportSize) {
    (void)contentSize;
    (void)viewportSize;
    return uv;
}

inline float4 sampleBGRA(
    texture2d<float, access::sample> texture,
    sampler texSampler,
    float2 uv
) {
    if (texture.get_width() == 0) {
        return float4(0.0);
    }
    return texture.sample(texSampler, uv);
}

inline float4 sampleNV12(
    texture2d<float, access::sample> yTexture,
    texture2d<float, access::sample> cbcrTexture,
    sampler texSampler,
    float2 uv
) {
    if (yTexture.get_width() == 0) {
        return float4(0.0);
    }
    float y = yTexture.sample(texSampler, uv).r;
    float2 cbcr = cbcrTexture.sample(texSampler, uv).rg;
    return float4(yuvToRgb(y, cbcr), 1.0);
}

inline float4 sampleSlot(
    texture2d<float, access::sample> bgraTexture,
    texture2d<float, access::sample> yTexture,
    texture2d<float, access::sample> cbcrTexture,
    sampler texSampler,
    float2 uv,
    float2 contentSize,
    float2 viewportSize,
    int isNV12
) {
    float2 fitted = aspectFitUV(uv, contentSize, viewportSize);
    if (fitted.x < 0.0 || fitted.x > 1.0 || fitted.y < 0.0 || fitted.y > 1.0) {
        return float4(0.0);
    }
    if (isNV12 != 0) {
        return sampleNV12(yTexture, cbcrTexture, texSampler, fitted);
    }
    return sampleBGRA(bgraTexture, texSampler, fitted);
}

inline float2 spatialUV(float2 uv, float offsetX, float scale) {
    float2 centered = uv - 0.5;
    centered.x -= offsetX;
    centered /= max(scale, 0.001);
    return centered + 0.5;
}

fragment float4 broadcastCompositorFragment(
    VertexOut in [[stage_in]],
    constant TransitionUniforms &uniforms [[buffer(0)]],
    texture2d<float, access::sample> outgoingBGRA [[texture(0)]],
    texture2d<float, access::sample> outgoingY [[texture(1)]],
    texture2d<float, access::sample> outgoingCbCr [[texture(2)]],
    texture2d<float, access::sample> incomingBGRA [[texture(3)]],
    texture2d<float, access::sample> incomingY [[texture(4)]],
    texture2d<float, access::sample> incomingCbCr [[texture(5)]],
    texture2d<float, access::sample> overlayBGRA [[texture(6)]],
    sampler texSampler [[sampler(0)]]
) {
    float2 viewport = max(uniforms.viewportSize, float2(1.0));
    float2 uv = in.uv;
    float3 color = float3(0.0);

    if (uniforms.hasOutgoing != 0 && uniforms.outgoingOpacity > 0.001) {
        float2 outUV = uniforms.usesSpatial != 0
            ? spatialUV(uv, uniforms.outgoingOffsetX, uniforms.outgoingScale)
            : uv;
        float4 outgoing = sampleSlot(
            outgoingBGRA, outgoingY, outgoingCbCr, texSampler,
            outUV, uniforms.outgoingContentSize, viewport, uniforms.outgoingIsNV12
        );
        color = mix(color, outgoing.rgb, uniforms.outgoingOpacity);
    }

    if (uniforms.hasIncoming != 0 && uniforms.incomingOpacity > 0.001) {
        float2 inUV = uniforms.usesSpatial != 0
            ? spatialUV(uv, uniforms.incomingOffsetX, uniforms.incomingScale)
            : uv;

        float incomingWeight = uniforms.incomingOpacity;
        if (uniforms.incomingReveal >= 0.0) {
            incomingWeight *= smoothstep(uniforms.incomingReveal, uniforms.incomingReveal + 0.001, uv.x);
        }

        if (incomingWeight > 0.001) {
            float4 incoming = sampleSlot(
                incomingBGRA, incomingY, incomingCbCr, texSampler,
                inUV, uniforms.incomingContentSize, viewport, uniforms.incomingIsNV12
            );
            color = mix(color, incoming.rgb, incomingWeight);
        }
    }

    if (uniforms.hasOverlay != 0 && overlayBGRA.get_width() > 0) {
        float4 overlay = overlayBGRA.sample(texSampler, uv);
        color = mix(color, overlay.rgb, overlay.a);
    }

    return float4(color, 1.0);
}

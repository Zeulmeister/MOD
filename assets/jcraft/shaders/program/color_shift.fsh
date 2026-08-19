#version 150

in vec2 texCoord;
in vec4 vPosition;

uniform sampler2D DiffuseSampler;
uniform float Intensity;
uniform float HueShift;

out vec4 fragColor;

vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
    vec4 src = texture(DiffuseSampler, texCoord);
    if (Intensity <= 0.001) {
        fragColor = src;
        return;
    }

    vec3 hsv = rgb2hsv(src.rgb);
    // Rotate hue and boost saturation for authentic JoJo anime palette shift
    hsv.x = fract(hsv.x + HueShift);
    hsv.y = clamp(hsv.y * 1.35, 0.0, 1.0);
    
    vec3 shiftedRgb = hsv2rgb(hsv);
    shiftedRgb = pow(shiftedRgb, vec3(0.92));

    vec3 finalRgb = mix(src.rgb, shiftedRgb, clamp(Intensity, 0.0, 1.0));
    fragColor = vec4(finalRgb, src.a);
}

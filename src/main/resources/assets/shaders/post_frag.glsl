/*
 * Copyright 2012 Benjamin Glatzel <benjamin.glatzel@me.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

uniform sampler2D texScene;
#ifdef BLOOM
uniform sampler2D texBloom;
#endif
#ifndef NO_BLUR
uniform sampler2D texBlur;
#endif
uniform sampler2D texVignette;
uniform sampler2D texDepth;

uniform bool swimming;

#if 0
uniform float fogIntensity = 0.1;
uniform float fogLinearIntensity = 0.1;
#endif

uniform float viewingDistance;

#define Z_NEAR 0.1
#define BLUR_START 0.6
#define BLUR_LENGTH 0.05

float linDepth() {
    float z = texture2D(texDepth, gl_TexCoord[0].xy).x;
    return (2.0 * Z_NEAR) / (viewingDistance + Z_NEAR - z * (viewingDistance - Z_NEAR));
}

void main() {
#ifndef NO_BLUR
    vec4 colorBlur = texture2D(texBlur, gl_TexCoord[0].xy);
#endif

#ifndef NO_BLUR
    float depth = linDepth();
    float blur = 0.0;

    if (depth > BLUR_START && !swimming)
       blur = clamp((depth - BLUR_START) / BLUR_LENGTH, 0.0, 1.0);
    else if (swimming)
       blur = 1.0;
#endif

    /* COLOR */
    vec4 color = texture2D(texScene, gl_TexCoord[0].xy);

#ifdef BLOOM
    vec4 colorBloom = texture2D(texBloom, gl_TexCoord[0].xy);
    color = clamp(color + colorBloom, 0.0, 1.0);
#endif

#ifndef NO_BLUR
    colorBlur = clamp(colorBlur , 0.0, 1.0);
#endif

#ifndef NO_BLUR
    vec4 finalColor = mix(color, colorBlur, blur);
#else
    vec4 finalColor = color;
#endif

#ifdef VIGNETTE
    float vig = texture2D(texVignette, gl_TexCoord[0].xy).x;

    if (!swimming) {
        finalColor.rgb *= vig;
    } else {
        finalColor.rgb *= vig * vig * vig;
        finalColor.rgb *= vec3(0.1, 0.2, 0.2);
    }
#endif

    gl_FragColor = finalColor;
}

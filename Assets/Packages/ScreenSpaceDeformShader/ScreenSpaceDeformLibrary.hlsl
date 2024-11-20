#ifndef SCREEN_SPACE_DEFORM_LIBRARY_INCLUDED
#define SCREEN_SPACE_DEFORM_LIBRARY_INCLUDED

#include "UnityCG.cginc"

sampler2D _GlobalScreenSpaceDeformTex;

float4 ScreenSpaceDeform(float4 rawVertex)
{
    // STEP1:
    // Get deform power

    float4 clipPos   = UnityObjectToClipPos(rawVertex);
    float2 ndcPos    = clipPos.xy / clipPos.w; // -1,1
    float2 viewPos   = 0.5 * (ndcPos + 1);     // 0,1(Y-Flip)
    float4 deformPow = tex2Dlod(_GlobalScreenSpaceDeformTex, float4(viewPos.x, 1 - viewPos.y, 0, 0));
           deformPow.rg /= 0.5;

    // STEP2:
    // Deform vertex relative to the object space origin.

    float4 objectOrigin = float4(0,0,0,1);
    float4 originInClip = UnityObjectToClipPos(objectOrigin);

    // NOTE:
    // If _GlobalScreenSpaceDeformTex is not set, tex2Dlod returns rgba = 1.

    clipPos.xy = deformPow.b == 1 ?
                 clipPos.xy :
                 (clipPos.xy - originInClip.xy) * deformPow.xy + originInClip.xy;

    return clipPos;
}

#endif // SCREEN_SPACE_DEFORM_LIBRARY_INCLUDED
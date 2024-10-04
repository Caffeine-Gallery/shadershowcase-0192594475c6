import Array "mo:base/Array";
import Text "mo:base/Text";

actor ShaderExamples {
    type ShaderExample = {
        name: Text;
        fragmentShader: Text;
    };

    let examples: [ShaderExample] = [
        {
            name = "Fractal Spiral";
            fragmentShader = "
                precision highp float;
                uniform float u_time;
                uniform vec2 u_resolution;
                
                void main() {
                    vec2 st = gl_FragCoord.xy/u_resolution.xy;
                    vec3 color = vec3(0.0);
                    
                    st = st * 2.0 - 1.0;
                    float r = length(st);
                    float a = atan(st.y, st.x);
                    
                    float f = cos(a * 3.0 + u_time) * sin(r * 10.0 - u_time * 2.0);
                    color = vec3(1.0 - smoothstep(0.0, 0.1, f));
                    
                    gl_FragColor = vec4(color, 1.0);
                }
            ";
        },
        {
            name = "Plasma Effect";
            fragmentShader = "
                precision highp float;
                uniform float u_time;
                uniform vec2 u_resolution;
                
                void main() {
                    vec2 st = gl_FragCoord.xy/u_resolution.xy;
                    float x = st.x * 10.0;
                    float y = st.y * 10.0;
                    
                    float v1 = sin(x + u_time);
                    float v2 = sin(y + u_time);
                    float v3 = sin(x + y + u_time);
                    float v4 = sin(sqrt(x*x + y*y) + u_time);
                    
                    float v = (v1 + v2 + v3 + v4) / 4.0;
                    
                    vec3 color = vec3(sin(v*3.14159), sin(v*3.14159+2.0), sin(v*3.14159+4.0));
                    
                    gl_FragColor = vec4(color, 1.0);
                }
            ";
        },
        {
            name = "Kaleidoscope";
            fragmentShader = "
                precision highp float;
                uniform float u_time;
                uniform vec2 u_resolution;
                
                void main() {
                    vec2 st = gl_FragCoord.xy/u_resolution.xy;
                    st = st * 2.0 - 1.0;
                    
                    float a = atan(st.y, st.x);
                    float r = length(st);
                    
                    float sides = 6.0;
                    float angle = 3.14159 * 2.0 / sides;
                    a = mod(a, angle) - angle / 2.0;
                    
                    vec2 uv = vec2(cos(a), sin(a)) * r;
                    
                    float f = cos(uv.x * 10.0 + u_time) * sin(uv.y * 10.0 - u_time);
                    vec3 color = vec3(1.0 - smoothstep(0.0, 0.1, f));
                    
                    gl_FragColor = vec4(color, 1.0);
                }
            ";
        }
    ];

    public query func getExampleNames() : async [Text] {
        Array.map<ShaderExample, Text>(examples, func(example) { example.name })
    };

    public query func getShaderCode(name: Text) : async ?Text {
        switch (Array.find<ShaderExample>(examples, func(example) { example.name == name })) {
            case (null) { null };
            case (?example) { ?example.fragmentShader };
        }
    };
}

import Int "mo:base/Int";

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
        },
        {
            name = "Realistic Water";
            fragmentShader = "
                precision highp float;
                uniform float u_time;
                uniform vec2 u_resolution;
                uniform vec2 u_mouse;
                uniform int u_mouseClicks;

                const int ITERATIONS = 5;
                const float TAU = 6.28318530718;

                float wave(vec2 position, float time, float speed, float frequency, float amplitude) {
                    float x = dot(normalize(position), position) * frequency + time * speed;
                    return sin(x) * amplitude;
                }

                void main() {
                    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
                    vec2 position = uv * 2.0 - 1.0;
                    position.x *= u_resolution.x / u_resolution.y;

                    float time = u_time * 0.5;
                    
                    float height = 0.0;
                    for(int i = 0; i < ITERATIONS; i++) {
                        float amplitude = 0.01 / float(i + 1);
                        float frequency = 20.0 * float(i * i + 1);
                        float speed = 2.0 + float(i) * 0.5;
                        height += wave(position, time, speed, frequency, amplitude);
                    }

                    // Add drops on mouse click
                    vec2 mousePos = u_mouse / u_resolution.xy;
                    mousePos = mousePos * 2.0 - 1.0;
                    mousePos.x *= u_resolution.x / u_resolution.y;
                    float dropStrength = 0.05 / (length(position - mousePos) + 0.1);
                    dropStrength *= float(u_mouseClicks);
                    height += dropStrength * sin(length(position - mousePos) * 80.0 - time * 10.0);

                    vec3 normal = normalize(vec3(dFdx(height), dFdy(height), 1.0));
                    
                    vec3 lightDir = normalize(vec3(1.0, 1.0, -1.0));
                    float diffuse = max(dot(normal, lightDir), 0.0);
                    
                    vec3 viewDir = normalize(vec3(0.0, 0.0, -1.0));
                    vec3 reflectDir = reflect(-lightDir, normal);
                    float specular = pow(max(dot(viewDir, reflectDir), 0.0), 32.0);
                    
                    vec3 waterColor = vec3(0.0, 0.3, 0.5);
                    vec3 color = waterColor * (diffuse * 0.7 + 0.3) + vec3(1.0) * specular * 0.5;
                    
                    gl_FragColor = vec4(color, 1.0);
                }
            ";
        },
        {
            name = "Ray Marching";
            fragmentShader = "
                precision highp float;
                uniform float u_time;
                uniform vec2 u_resolution;
                
                float sdSphere(vec3 p, float r) {
                    return length(p) - r;
                }
                
                float map(vec3 p) {
                    return sdSphere(p, 1.0);
                }
                
                void main() {
                    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
                    vec3 ro = vec3(0.0, 0.0, -3.0);
                    vec3 rd = normalize(vec3(uv, 1.0));
                    
                    float t = 0.0;
                    for(int i = 0; i < 100; i++) {
                        vec3 p = ro + rd * t;
                        float d = map(p);
                        t += d;
                        if(d < 0.001 || t > 100.0) break;
                    }
                    
                    vec3 color = vec3(1.0 - t * 0.02);
                    gl_FragColor = vec4(color, 1.0);
                }
            ";
        },
        {
            name = "Bird Agents";
            fragmentShader = "
                precision highp float;
                uniform float u_time;
                uniform vec2 u_resolution;
                uniform vec2 u_mouse;

                #define NUM_BIRDS 50
                #define PI 3.14159265359

                float random(vec2 st) {
                    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
                }

                vec2 rotate(vec2 v, float a) {
                    float s = sin(a);
                    float c = cos(a);
                    mat2 m = mat2(c, -s, s, c);
                    return m * v;
                }

                void main() {
                    vec2 st = gl_FragCoord.xy/u_resolution.xy;
                    vec3 color = vec3(0.5, 0.8, 1.0); // Sky color

                    vec2 mousePos = u_mouse/u_resolution.xy;

                    for(int i = 0; i < NUM_BIRDS; i++) {
                        float t = u_time * 0.5 + float(i);
                        vec2 birdPos = vec2(
                            mod(t * (0.1 + random(vec2(float(i), 0.0)) * 0.1), 1.0),
                            mod(sin(t * 0.5) * 0.2 + 0.5 + random(vec2(0.0, float(i))) * 0.5, 1.0)
                        );

                        // Move towards mouse
                        vec2 toMouse = mousePos - birdPos;
                        birdPos += normalize(toMouse) * 0.001 * length(toMouse);

                        vec2 birdDir = normalize(vec2(1.0, sin(t * 2.0) * 0.2));

                        // Draw bird
                        vec2 pos = st - birdPos;
                        pos = rotate(pos, atan(birdDir.y, birdDir.x));
                        float bird = max(
                            smoothstep(0.01, 0.0, abs(pos.x) - 0.02 + sin(pos.x * 100.0) * 0.005),
                            smoothstep(0.01, 0.0, length(pos - vec2(-0.02, 0.0)) - 0.005)
                        );

                        color = mix(color, vec3(0.0), bird);
                    }

                    gl_FragColor = vec4(color, 1.0);
                }
            ";
        },
        {
            name = "Interactive Lava Lamp";
            fragmentShader = "
                precision highp float;
                uniform float u_time;
                uniform vec2 u_resolution;
                uniform vec2 u_mouse;
                
                float metaball(vec2 p, vec2 center, float radius) {
                    return radius / length(p - center);
                }
                
                float sdEllipse(vec2 p, vec2 ab) {
                    p = abs(p);
                    if (p.x > p.y) {
                        p = p.yx;
                        ab = ab.yx;
                    }
                    float l = ab.y*ab.y - ab.x*ab.x;
                    float m = ab.x*p.x/l;
                    float m2 = m*m;
                    float n = ab.y*p.y/l;
                    float n2 = n*n;
                    float c = (m2 + n2 - 1.0)/3.0;
                    float c3 = c*c*c;
                    float q = c3 + m2*n2*2.0;
                    float d = c3 + m2*n2;
                    float g = m + m*n2;
                    float co;
                    if (d < 0.0) {
                        float h = acos(q/c3)/3.0;
                        float s = cos(h);
                        float t = sin(h)*sqrt(3.0);
                        float rx = sqrt(-c*(s + t + 2.0) + m2);
                        float ry = sqrt(-c*(s - t + 2.0) + m2);
                        co = (ry + sign(l)*rx + abs(g)/(rx*ry) - m)/2.0;
                    } else {
                        float h = 2.0*m*n*sqrt(d);
                        float s = sign(q + h)*pow(abs(q + h), 1.0/3.0);
                        float u = sign(q - h)*pow(abs(q - h), 1.0/3.0);
                        float rx = -s - u - c*4.0 + 2.0*m2;
                        float ry = (s - u)*sqrt(3.0);
                        float rm = sqrt(rx*rx + ry*ry);
                        co = (ry/sqrt(rm-rx) + 2.0*g/rm - m)/2.0;
                    }
                    float si = sqrt(1.0 - co*co);
                    vec2 r = vec2(ab.x*co, ab.y*si);
                    return length(r - p) * sign(p.y - r.y);
                }
                
                void main() {
                    vec2 st = gl_FragCoord.xy/u_resolution.xy;
                    st = st * 2.0 - 1.0;
                    st.x *= u_resolution.x / u_resolution.y;
                    
                    // Lamp shape
                    float lampShape = sdEllipse(st, vec2(0.4, 0.8));
                    
                    float m = 0.0;
                    vec2 mouse = u_mouse/u_resolution.xy * 2.0 - 1.0;
                    mouse.x *= u_resolution.x / u_resolution.y;
                    
                    for (int i = 0; i < 5; i++) {
                        float t = u_time * 0.5 + float(i) * 1.0;
                        vec2 pos = vec2(sin(t) * 0.3, cos(t * 0.5) * 0.6);
                        
                        // Add wall interaction
                        float wallForce = 1.0 / max(abs(pos.x) - 0.35, 0.01);
                        pos.x += sign(pos.x) * wallForce * 0.01;
                        
                        m += metaball(st, pos, 0.1);
                    }
                    
                    // Add mouse interaction
                    m += metaball(st, mouse, 0.2);
                    
                    vec3 color = vec3(1.0, 0.5, 0.0) * step(1.0, m);
                    color += vec3(1.0, 0.8, 0.0) * step(1.2, m);
                    
                    // Apply lamp shape
                    color *= 1.0 - smoothstep(0.0, 0.01, lampShape);
                    
                    // Add glow
                    color += vec3(1.0, 0.5, 0.2) * (1.0 - smoothstep(0.0, 0.1, lampShape)) * 0.5;
                    
                    gl_FragColor = vec4(color, 1.0);
                }
            ";
        },
        {
            name = "Interactive Lava Lamp (No Walls)";
            fragmentShader = "
                precision highp float;
                uniform float u_time;
                uniform vec2 u_resolution;
                uniform vec2 u_mouse;
                
                float metaball(vec2 p, vec2 center, float radius) {
                    return radius / length(p - center);
                }
                
                void main() {
                    vec2 st = gl_FragCoord.xy/u_resolution.xy;
                    st = st * 2.0 - 1.0;
                    st.x *= u_resolution.x / u_resolution.y;
                    
                    float m = 0.0;
                    vec2 mouse = u_mouse/u_resolution.xy * 2.0 - 1.0;
                    mouse.x *= u_resolution.x / u_resolution.y;
                    
                    for (int i = 0; i < 5; i++) {
                        float t = u_time * 0.5 + float(i) * 1.0;
                        vec2 pos = vec2(sin(t) * 0.5, cos(t * 0.5) * 0.5);
                        m += metaball(st, pos, 0.1);
                    }
                    
                    // Add mouse interaction
                    m += metaball(st, mouse, 0.2);
                    
                    vec3 color = vec3(1.0, 0.5, 0.0) * step(1.0, m);
                    color += vec3(1.0, 0.8, 0.0) * step(1.2, m);
                    
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

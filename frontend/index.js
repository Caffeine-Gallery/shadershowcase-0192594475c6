import { backend } from 'declarations/backend';

let gl;
let program;
let positionAttributeLocation;
let resolutionUniformLocation;
let timeUniformLocation;
let mouseUniformLocation;
let mouseClicksUniformLocation;
let startTime;
let mousePosition = { x: 0, y: 0 };
let mouseClicks = 0;

const vertexShaderSource = `
    attribute vec4 a_position;
    void main() {
        gl_Position = a_position;
    }
`;

async function init() {
    const canvas = document.getElementById('glCanvas');
    gl = canvas.getContext('webgl');

    if (!gl) {
        console.error('WebGL not supported');
        return;
    }

    const shaderSelect = document.getElementById('shaderSelect');
    const exampleNames = await backend.getExampleNames();

    exampleNames.forEach(name => {
        const option = document.createElement('option');
        option.value = name;
        option.textContent = name;
        shaderSelect.appendChild(option);
    });

    shaderSelect.addEventListener('change', async (event) => {
        const selectedShader = await backend.getShaderCode(event.target.value);
        if (selectedShader) {
            setupShader(selectedShader);
        }
    });

    if (exampleNames.length > 0) {
        const firstShader = await backend.getShaderCode(exampleNames[0]);
        if (firstShader) {
            setupShader(firstShader);
        }
    }

    startTime = Date.now();
    resizeCanvas();
    window.addEventListener('resize', resizeCanvas);
    canvas.addEventListener('mousemove', updateMousePosition);
    canvas.addEventListener('touchmove', updateTouchPosition);
    canvas.addEventListener('click', handleClick);
    canvas.addEventListener('touchstart', handleClick);
    requestAnimationFrame(render);
}

function resizeCanvas() {
    const canvas = gl.canvas;
    const displayWidth = canvas.clientWidth;
    const displayHeight = canvas.clientHeight;

    if (canvas.width !== displayWidth || canvas.height !== displayHeight) {
        canvas.width = displayWidth;
        canvas.height = displayHeight;
        gl.viewport(0, 0, canvas.width, canvas.height);
    }
}

function updateMousePosition(event) {
    const canvas = gl.canvas;
    const rect = canvas.getBoundingClientRect();
    mousePosition.x = event.clientX - rect.left;
    mousePosition.y = canvas.height - (event.clientY - rect.top);
}

function updateTouchPosition(event) {
    event.preventDefault();
    const canvas = gl.canvas;
    const rect = canvas.getBoundingClientRect();
    const touch = event.touches[0];
    mousePosition.x = touch.clientX - rect.left;
    mousePosition.y = canvas.height - (touch.clientY - rect.top);
}

function handleClick() {
    mouseClicks++;
    setTimeout(() => {
        mouseClicks--;
    }, 1000);
}

function setupShader(fragmentShaderSource) {
    const vertexShader = createShader(gl, gl.VERTEX_SHADER, vertexShaderSource);
    const fragmentShader = createShader(gl, gl.FRAGMENT_SHADER, fragmentShaderSource);

    program = createProgram(gl, vertexShader, fragmentShader);

    positionAttributeLocation = gl.getAttribLocation(program, 'a_position');
    resolutionUniformLocation = gl.getUniformLocation(program, 'u_resolution');
    timeUniformLocation = gl.getUniformLocation(program, 'u_time');
    mouseUniformLocation = gl.getUniformLocation(program, 'u_mouse');
    mouseClicksUniformLocation = gl.getUniformLocation(program, 'u_mouseClicks');

    const positionBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);

    const positions = [
        -1, -1,
         1, -1,
        -1,  1,
        -1,  1,
         1, -1,
         1,  1,
    ];
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(positions), gl.STATIC_DRAW);
}

function createShader(gl, type, source) {
    const shader = gl.createShader(type);
    gl.shaderSource(shader, source);
    gl.compileShader(shader);
    if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
        console.error('Shader compilation error:', gl.getShaderInfoLog(shader));
        gl.deleteShader(shader);
        return null;
    }
    return shader;
}

function createProgram(gl, vertexShader, fragmentShader) {
    const program = gl.createProgram();
    gl.attachShader(program, vertexShader);
    gl.attachShader(program, fragmentShader);
    gl.linkProgram(program);
    if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
        console.error('Program linking error:', gl.getProgramInfoLog(program));
        gl.deleteProgram(program);
        return null;
    }
    return program;
}

function render() {
    resizeCanvas();
    gl.clearColor(0, 0, 0, 1);
    gl.clear(gl.COLOR_BUFFER_BIT);

    gl.useProgram(program);

    gl.enableVertexAttribArray(positionAttributeLocation);
    gl.vertexAttribPointer(positionAttributeLocation, 2, gl.FLOAT, false, 0, 0);

    gl.uniform2f(resolutionUniformLocation, gl.canvas.width, gl.canvas.height);
    gl.uniform1f(timeUniformLocation, (Date.now() - startTime) / 1000);
    gl.uniform2f(mouseUniformLocation, mousePosition.x, mousePosition.y);
    gl.uniform1i(mouseClicksUniformLocation, mouseClicks);

    gl.drawArrays(gl.TRIANGLES, 0, 6);

    requestAnimationFrame(render);
}

window.addEventListener('load', init);

// Wait for the module to be ready
const status = document.getElementById('status');
const output = document.getElementById('output');

// Initialize CodeMirror
const editor = CodeMirror.fromTextArea(document.getElementById('editor'), {
    lineNumbers: true,
    mode: 'text/x-c++src',
    indentUnit: 4
});

// Initialize the application
async function initialize() {
    try {
        status.textContent = 'Loading WebAssembly...';
        console.log("Loading WebAssembly module...");
        
        // Wait for the module to be ready
        const Module = await window.bokModulePromise;
        console.log("WebAssembly module loaded:", Module);
        
        // Test the module
        try {
            console.log("Testing module functions...");
            
            // Get the function pointer
            const testResult = Module.ccall(
                'testFunction',  // function name
                'string',        // return type
                [],              // argument types
                []               // arguments
            );
            
            console.log("testFunction result:", testResult);
            output.textContent = `Test successful! ${testResult}\n\n`;
            
            // Store the module for later use
            window.bokModule = Module;
            status.textContent = 'Ready';
            document.getElementById('run-btn').disabled = false;
            console.log("Initialization complete");
        } catch (e) {
            console.error("Error testing module:", e);
            throw new Error(`Module test failed: ${e}`);
        }
    } catch (e) {
        const errorMsg = `Initialization failed: ${e}`;
        console.error(errorMsg, e);
        status.textContent = errorMsg;
        output.textContent = `Error details: ${e.stack || e}`;
    }
}

// Run button handler
document.getElementById('run-btn').addEventListener('click', async () => {
    const status = document.getElementById('status');
    const output = document.getElementById('output');
    
    status.textContent = 'Running...';
    
    try {
        if (!window.bokModule) {
            throw new Error("WebAssembly module not loaded");
        }
        
        const code = editor.getValue();
        console.log("Running with code:", code);
        
        // Call the C++ function using ccall
        const result = window.bokModule.ccall(
            'processBokCode',  // function name
            'string',           // return type
            ['string'],         // argument types
            [code]              // arguments
        );
        
        output.textContent += `> ${code}\n${result}\n\n`;
        status.textContent = 'Done';
    } catch (e) {
        const errorMsg = `Error: ${e}`;
        console.error(errorMsg, e);
        status.textContent = errorMsg;
        output.textContent += `Error: ${e.message || e}\n\n`;
    }
});

// Start the application
initialize();

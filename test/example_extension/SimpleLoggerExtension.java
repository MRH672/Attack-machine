/**
 * Simple Logger Extension for Burp Suite
 * This extension logs all HTTP requests and responses to the Output tab
 * 
 * To compile:
 * javac -cp "../burpsuite_community.jar" SimpleLoggerExtension.java
 * jar cf SimpleLoggerExtension.jar SimpleLoggerExtension.class
 */

import burp.*;

public class SimpleLoggerExtension implements IBurpExtender, IHttpListener {
    private IBurpExtenderCallbacks callbacks;
    private IExtensionHelpers helpers;
    
    @Override
    public void registerExtenderCallbacks(IBurpExtenderCallbacks callbacks) {
        // Store callbacks and helpers
        this.callbacks = callbacks;
        this.helpers = callbacks.getHelpers();
        
        // Set extension name
        callbacks.setExtensionName("Simple Logger Extension");
        
        // Register HTTP listener
        callbacks.registerHttpListener(this);
        
        // Print success message
        callbacks.printOutput("Simple Logger Extension loaded successfully!");
        callbacks.printOutput("All HTTP requests and responses will be logged.");
    }
    
    @Override
    public void processHttpMessage(int toolFlag, boolean messageIsRequest, IHttpRequestResponse messageInfo) {
        // Only process requests (not responses)
        if (messageIsRequest) {
            // Get request details
            IRequestInfo requestInfo = helpers.analyzeRequest(messageInfo);
            String method = requestInfo.getMethod();
            String url = requestInfo.getUrl().toString();
            
            // Log the request
            callbacks.printOutput("========================================");
            callbacks.printOutput("Request intercepted:");
            callbacks.printOutput("Method: " + method);
            callbacks.printOutput("URL: " + url);
            callbacks.printOutput("Tool: " + getToolName(toolFlag));
            callbacks.printOutput("========================================");
        }
    }
    
    /**
     * Convert tool flag to readable name
     */
    private String getToolName(int toolFlag) {
        switch (toolFlag) {
            case IBurpExtenderCallbacks.TOOL_PROXY:
                return "Proxy";
            case IBurpExtenderCallbacks.TOOL_SPIDER:
                return "Spider";
            case IBurpExtenderCallbacks.TOOL_SCANNER:
                return "Scanner";
            case IBurpExtenderCallbacks.TOOL_INTRUDER:
                return "Intruder";
            case IBurpExtenderCallbacks.TOOL_REPEATER:
                return "Repeater";
            case IBurpExtenderCallbacks.TOOL_SEQUENCER:
                return "Sequencer";
            case IBurpExtenderCallbacks.TOOL_DECODER:
                return "Decoder";
            case IBurpExtenderCallbacks.TOOL_COMPARER:
                return "Comparer";
            case IBurpExtenderCallbacks.TOOL_EXTENDER:
                return "Extender";
            default:
                return "Unknown";
        }
    }
}


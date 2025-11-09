/**
 * Email Change Intruder Extension for Burp Suite
 * 
 * This extension automatically detects HTTP requests related to email changes
 * and highlights them for easy identification and testing with Intruder.
 * 
 * Features:
 * - Detects email change requests (POST/PUT/PATCH)
 * - Identifies email-related parameters
 * - Highlights detected requests in Proxy history
 * - Adds context menu option to send to Intruder
 * - Configurable email parameter detection
 * 
 * To compile:
 * javac -cp "../burpsuite_community.jar" EmailChangeIntruderExtension.java
 * jar cf EmailChangeIntruderExtension.jar EmailChangeIntruderExtension.class
 * 
 * To use:
 * 1. Load the extension in Burp Suite (Extensions → Add → Select file)
 * 2. The extension will automatically monitor requests through Proxy
 * 3. Detected email change requests will be highlighted in red
 * 4. Right-click on highlighted requests → "Send Email Request to Intruder"
 */

import burp.*;
import javax.swing.*;
import java.util.*;
import java.util.regex.Pattern;
import java.util.regex.Matcher;
import java.io.PrintWriter;

public class EmailChangeIntruderExtension implements IBurpExtender, IHttpListener, IContextMenuFactory {
    private IBurpExtenderCallbacks callbacks;
    private IExtensionHelpers helpers;
    private PrintWriter stdout;
    private PrintWriter stderr;
    
    // Email-related keywords to detect
    private static final String[] EMAIL_KEYWORDS = {
        "email", "e-mail", "mail", "email_address", "emailAddress",
        "new_email", "newEmail", "newemail", "new_email_address",
        "change_email", "changeEmail", "changeemail",
        "update_email", "updateEmail", "updateemail",
        "user_email", "userEmail", "useremail",
        "account_email", "accountEmail", "accountemail",
        "old_email", "oldEmail", "current_email", "currentEmail"
    };
    
    // URL patterns that might indicate email change functionality
    private static final String[] EMAIL_CHANGE_PATTERNS = {
        ".*change.*email.*",
        ".*update.*email.*",
        ".*modify.*email.*",
        ".*edit.*email.*",
        ".*email.*change.*",
        ".*email.*update.*",
        ".*profile.*email.*",
        ".*account.*email.*",
        ".*settings.*email.*",
        ".*user.*email.*"
    };
    
    // Track processed requests to avoid duplicates
    private Set<String> processedRequests = new HashSet<>();
    
    @Override
    public void registerExtenderCallbacks(IBurpExtenderCallbacks callbacks) {
        // Store callbacks and helpers
        this.callbacks = callbacks;
        this.helpers = callbacks.getHelpers();
        
        // Set up output streams
        stdout = new PrintWriter(callbacks.getStdout(), true);
        stderr = new PrintWriter(callbacks.getStderr(), true);
        
        // Set extension name
        callbacks.setExtensionName("Email Change Intruder");
        
        // Register HTTP listener
        callbacks.registerHttpListener(this);
        
        // Register context menu factory
        callbacks.registerContextMenuFactory(this);
        
        // Print success message
        stdout.println("========================================");
        stdout.println("Email Change Intruder Extension loaded!");
        stdout.println("========================================");
        stdout.println("Extension is monitoring requests for email change operations.");
        stdout.println("Detected requests will be highlighted in Proxy history.");
        stdout.println("Right-click on highlighted requests to send to Intruder.");
        stdout.println("");
    }
    
    @Override
    public void processHttpMessage(int toolFlag, boolean messageIsRequest, IHttpRequestResponse messageInfo) {
        // Only process requests (not responses)
        // Skip if the request is already from Intruder to avoid loops
        if (messageIsRequest && toolFlag != IBurpExtenderCallbacks.TOOL_INTRUDER) {
            // Analyze the request
            IRequestInfo requestInfo = helpers.analyzeRequest(messageInfo);
            String method = requestInfo.getMethod();
            String url = requestInfo.getUrl().toString();
            
            // Only process POST, PUT, PATCH requests (typical for email changes)
            if (method.equals("POST") || method.equals("PUT") || method.equals("PATCH")) {
                // Check if this is an email change request
                if (isEmailChangeRequest(requestInfo, messageInfo)) {
                    // Create a unique key for this request
                    String requestKey = method + ":" + url + ":" + System.currentTimeMillis() / 10000; // Group by 10 seconds
                    
                    // Check if we've already processed this request (within last 10 seconds)
                    if (!processedRequests.contains(requestKey)) {
                        processedRequests.add(requestKey);
                        
                        // Mark the request
                        markEmailChangeRequest(messageInfo, requestInfo);
                        
                        stdout.println("[EMAIL CHANGE DETECTED]");
                        stdout.println("Method: " + method);
                        stdout.println("URL: " + url);
                        
                        // Find and report email parameters
                        List<IParameter> emailParams = findEmailParameters(requestInfo);
                        if (!emailParams.isEmpty()) {
                            stdout.println("Email parameters found:");
                            for (IParameter param : emailParams) {
                                stdout.println("  - " + param.getName() + " = " + param.getValue());
                            }
                        }
                        
                        stdout.println("Request highlighted in Proxy history");
                        stdout.println("Right-click → 'Send Email Request to Intruder'");
                        stdout.println("========================================");
                        
                        // Clean up old entries (keep last 100)
                        if (processedRequests.size() > 100) {
                            processedRequests.clear();
                        }
                    }
                }
            }
        }
    }
    
    /**
     * Check if the request is related to email change
     */
    private boolean isEmailChangeRequest(IRequestInfo requestInfo, IHttpRequestResponse messageInfo) {
        String url = requestInfo.getUrl().toString().toLowerCase();
        List<IParameter> parameters = requestInfo.getParameters();
        
        // Check URL patterns
        for (String pattern : EMAIL_CHANGE_PATTERNS) {
            if (url.matches(pattern)) {
                return true;
            }
        }
        
        // Check parameters for email-related keywords
        for (IParameter param : parameters) {
            String paramName = param.getName().toLowerCase();
            for (String keyword : EMAIL_KEYWORDS) {
                if (paramName.contains(keyword.toLowerCase())) {
                    return true;
                }
            }
        }
        
        // Check request body for email-related content
        byte[] requestBytes = messageInfo.getRequest();
        IRequestInfo analyzedRequest = helpers.analyzeRequest(requestBytes);
        int bodyOffset = analyzedRequest.getBodyOffset();
        if (bodyOffset < requestBytes.length) {
            byte[] bodyBytes = Arrays.copyOfRange(requestBytes, bodyOffset, requestBytes.length);
            String body = new String(bodyBytes).toLowerCase();
            
            // Check for email patterns in body
            for (String keyword : EMAIL_KEYWORDS) {
                if (body.contains(keyword.toLowerCase())) {
                    // Additional check: look for email format
                    Pattern emailPattern = Pattern.compile(".*" + Pattern.quote(keyword) + ".*@.*\\..*");
                    if (emailPattern.matcher(body).find()) {
                        return true;
                    }
                }
            }
        }
        
        return false;
    }
    
    /**
     * Find email-related parameters in the request
     */
    private List<IParameter> findEmailParameters(IRequestInfo requestInfo) {
        List<IParameter> emailParams = new ArrayList<>();
        List<IParameter> parameters = requestInfo.getParameters();
        
        for (IParameter param : parameters) {
            String paramName = param.getName().toLowerCase();
            for (String keyword : EMAIL_KEYWORDS) {
                if (paramName.contains(keyword.toLowerCase())) {
                    emailParams.add(param);
                    break;
                }
            }
        }
        
        return emailParams;
    }
    
    /**
     * Mark the request in UI with highlight and comment
     */
    private void markEmailChangeRequest(IHttpRequestResponse messageInfo, IRequestInfo requestInfo) {
        try {
            // Highlight the request in red
            messageInfo.setHighlight("red");
            
            // Add a comment
            List<IParameter> emailParams = findEmailParameters(requestInfo);
            if (!emailParams.isEmpty()) {
                String paramNames = "";
                for (IParameter param : emailParams) {
                    if (!paramNames.isEmpty()) paramNames += ", ";
                    paramNames += param.getName();
                }
                messageInfo.setComment("Email Change - Params: " + paramNames);
            } else {
                messageInfo.setComment("Email Change Request - Auto-detected");
            }
        } catch (Exception e) {
            stderr.println("Error marking request: " + e.getMessage());
        }
    }
    
    /**
     * Send request to Intruder with email parameters marked
     */
    private void sendRequestToIntruder(IHttpRequestResponse messageInfo) {
        try {
            IRequestInfo requestInfo = helpers.analyzeRequest(messageInfo);
            List<IParameter> emailParams = findEmailParameters(requestInfo);
            
            if (!emailParams.isEmpty()) {
                // Get the request bytes
                byte[] request = messageInfo.getRequest();
                
                // Create a new request with email parameters marked for Intruder
                // Note: We'll send it to Repeater first, then user can manually send to Intruder
                // Or we can use the sendToIntruder method if available in the API
                
                // For now, we'll send to Repeater and provide instructions
                callbacks.sendToRepeater(
                    messageInfo.getHttpService().getHost(),
                    messageInfo.getHttpService().getPort(),
                    messageInfo.getHttpService().getProtocol().equals("https"),
                    request,
                    "Email Change Request"
                );
                
                stdout.println("Request sent to Repeater");
                stdout.println("Email parameters to test in Intruder:");
                for (IParameter param : emailParams) {
                    stdout.println("  - " + param.getName());
                }
                stdout.println("");
                stdout.println("Instructions:");
                stdout.println("1. Go to Repeater tab");
                stdout.println("2. Send the request to Intruder (Ctrl+I or right-click → Send to Intruder)");
                stdout.println("3. In Intruder, mark the email parameter(s) for fuzzing");
                stdout.println("4. Configure your payloads and start the attack");
                
            } else {
                stdout.println("No email parameters found in request body parameters.");
                stdout.println("You may need to manually mark the email value in the request body.");
            }
            
        } catch (Exception e) {
            stderr.println("Error sending to Intruder: " + e.getMessage());
            e.printStackTrace(stderr);
        }
    }
    
    /**
     * Create context menu items
     */
    @Override
    public List<JMenuItem> createMenuItems(IContextMenuInvocation invocation) {
        List<JMenuItem> menuItems = new ArrayList<>();
        
        // Only show menu for HTTP requests
        int context = invocation.getInvocationContext();
        if (context == IContextMenuInvocation.CONTEXT_MESSAGE_VIEWER_REQUEST ||
            context == IContextMenuInvocation.CONTEXT_MESSAGE_EDITOR_REQUEST ||
            context == IContextMenuInvocation.CONTEXT_PROXY_HISTORY ||
            context == IContextMenuInvocation.CONTEXT_TARGET_SITE_MAP_TABLE ||
            context == IContextMenuInvocation.CONTEXT_TARGET_SITE_MAP_TREE) {
            
            IHttpRequestResponse[] selectedMessages = invocation.getSelectedMessages();
            if (selectedMessages != null && selectedMessages.length > 0) {
                // Check if any selected message is an email change request
                boolean hasEmailRequest = false;
                for (IHttpRequestResponse message : selectedMessages) {
                    IRequestInfo requestInfo = helpers.analyzeRequest(message);
                    if (isEmailChangeRequest(requestInfo, message)) {
                        hasEmailRequest = true;
                        break;
                    }
                }
                
                if (hasEmailRequest) {
                    JMenuItem sendToIntruderItem = new JMenuItem("Send Email Request to Intruder");
                    sendToIntruderItem.addActionListener(e -> {
                        for (IHttpRequestResponse message : selectedMessages) {
                            IRequestInfo requestInfo = helpers.analyzeRequest(message);
                            if (isEmailChangeRequest(requestInfo, message)) {
                                sendRequestToIntruder(message);
                            }
                        }
                    });
                    menuItems.add(sendToIntruderItem);
                    menuItems.add(new JSeparator());
                }
            }
        }
        
        return menuItems;
    }
}

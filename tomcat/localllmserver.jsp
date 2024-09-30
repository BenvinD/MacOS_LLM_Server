<%@ page import="java.io.*, java.net.*, org.json.*" %>
<%
    String responseMessage = "";
    int responseCode = -1;
    String userInput = "";
    String selectedModel = "llama"; 
    long responseTime = 0;

    userInput = request.getParameter("query");
    selectedModel = request.getParameter("model"); // Get the selected model from the dropdown
    String apiUrl = "http://localhost:8080/v1/chat/completions"; 

    if ("gpt2".equals(selectedModel)) {
        apiUrl = "http://localhost:8081/v1/chat/completions"; 
    } else if ("mistral".equals(selectedModel)) {
        apiUrl = "http://localhost:8082/v1/chat/completions"; 
    } else if ("gemma2".equals(selectedModel)) {
        apiUrl = "http://localhost:8083/v1/chat/completions"; 
    }

    HttpURLConnection connection = null;

    if (userInput != null && !userInput.equals("")) {
        try {
            long startTime = System.currentTimeMillis(); // Start time before 
            URL url = new URL(apiUrl);
            connection = (HttpURLConnection) url.openConnection();
            
            connection.setRequestMethod("POST");
            connection.setRequestProperty("Content-Type", "application/json");
            connection.setDoOutput(true);
            
            JSONObject jsonPayload = new JSONObject();
            JSONArray messagesArray = new JSONArray();
            JSONObject message = new JSONObject();
            message.put("role", "user");
            message.put("content", userInput); 
            messagesArray.put(message);
            jsonPayload.put("messages", messagesArray);
            
            try (OutputStream os = connection.getOutputStream()) {
                byte[] input = jsonPayload.toString().getBytes("utf-8");
                os.write(input, 0, input.length);
            }

            responseCode = connection.getResponseCode();
            
            try (BufferedReader br = new BufferedReader(
                new InputStreamReader(responseCode >= 400 ? connection.getErrorStream() : connection.getInputStream(), "utf-8"))) {
                StringBuilder apiResponse = new StringBuilder();
                String responseLine;
                while ((responseLine = br.readLine()) != null) {
                    apiResponse.append(responseLine.trim());
                }
                responseMessage = apiResponse.toString();
            }
            long endTime = System.currentTimeMillis(); 
            responseTime = endTime - startTime; 

            if (responseCode == HttpURLConnection.HTTP_OK) {
                JSONObject jsonResponse = new JSONObject(responseMessage);
                JSONArray choices = jsonResponse.getJSONArray("choices");
                if (choices.length() > 0) {
                    JSONObject firstChoice = choices.getJSONObject(0);
                    JSONObject messageObj = firstChoice.getJSONObject("message");
                    responseMessage = messageObj.getString("content");
                }
            }
        } catch (Exception e) {
            StringWriter sw = new StringWriter();
            e.printStackTrace(new PrintWriter(sw));
            responseMessage = "Exception: " + e.getMessage() + "\n" + sw.toString();
        } finally {
            if (connection != null) {
                connection.disconnect();
            }
        }
    }
%>


<!DOCTYPE html>
<html>
<head>
    <title>API Input Form</title>
    <style>
        #loader {
            display: none; 
            position: fixed;
            left: 50%;
            top: 50%;
            transform: translate(-50%, -50%);
            z-index: 1000;
            border: 16px solid #f3f3f3; 
            border-top: 16px solid #3498db; 
            border-radius: 50%;
            width: 60px;
            height: 60px;
            animation: spin 2s linear infinite;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
    </style>
    <script>
        function showLoader() {
            document.getElementById("loader").style.display = "block"; r
        }
    </script>
</head>
<body>
    <h1>Submit Your Query</h1>
    <form action="/jsp/common/localllmcall.jsp">
        <textarea name="query" rows="5" cols="70" required><%= userInput %></textarea>
        <br>
        <label for="model">Select Model:</label>
        <select name="model" id="model">
            <option value="llama" <%= "llama".equals(selectedModel) ? "selected" : "" %>>Meta-Llama-3-8B-Instruct</option>
            <option value="mistral" <%= "mistral".equals(selectedModel) ? "selected" : "" %>>Mistral-7B-Instruct-v0.2</option>
            <option value="gemma2" <%= "gemma2".equals(selectedModel) ? "selected" : "" %>>Gemma-2-9b</option>
            <option value="gpt2" <%= "gpt2".equals(selectedModel) ? "selected" : "" %>>OpenAI-GPT-2</option>
        </select>
        <br>
        <input type="submit" value="Submit" onclick="showLoader()"/>
    </form>

    <div id="loader"></div> 

    <h2>Response from API:</h2>
    <pre><%= responseMessage %></pre>
    
    <h2>Debugging Information:</h2>
    <p>Response Code: <%= responseCode %></p>
    <p>User Input: <%= userInput %></p>
    <p>Selected Model: <%= selectedModel %></p>
    <p>Time Taken for Response: <%= responseTime %> ms</p> 
</body>
</html>

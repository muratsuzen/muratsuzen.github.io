---
title: Fetch - HTTP POST Request Examples
author: Murat Süzen
date: 2025-04-15 09:00:00
categories: [JavaScript, Web Development]
tags: [fetch api, http post, javascript, frontend, api integration]
math: false
mermaid: false
---

The Fetch API is a modern, promise-based approach to making HTTP requests in JavaScript. One of the most common tasks developers face is sending HTTP POST requests to APIs — whether for submitting forms, sending JSON data, or interacting with backend services.

This guide provides **practical examples** for using Fetch to make POST requests, helping you confidently integrate APIs into your applications.

## What is the Fetch API?

The Fetch API provides a simple interface for fetching resources over the network. Unlike the older `XMLHttpRequest`, it uses Promises, making the code cleaner and easier to work with.

## Basic POST Request Example

Here’s how to send a simple POST request with JSON data:

```js
fetch('https://example.com/api/data', {
    method: 'POST',
    headers: {
        'Content-Type': 'application/json'
    },
    body: JSON.stringify({
        name: 'John Doe',
        email: 'john@example.com'
    })
})
.then(response => response.json())
.then(data => console.log('Success:', data))
.catch(error => console.error('Error:', error));
```

### Breakdown:
- `method`: Specifies the HTTP method (POST).
- `headers`: Defines content type (usually `application/json`).
- `body`: Contains the request payload (JSON.stringify converts the object).
- `.then()`: Handles the response.
- `.catch()`: Catches any network or parsing errors.

## Posting Form Data

Sometimes you need to send data as form-encoded, like when submitting HTML forms:

```js
const formData = new URLSearchParams();
formData.append('username', 'johndoe');
formData.append('password', 'mypassword');

fetch('https://example.com/login', {
    method: 'POST',
    headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: formData.toString()
})
.then(response => response.json())
.then(data => console.log('Logged in:', data))
.catch(error => console.error('Error:', error));
```

## Handling HTTP Status Codes

You should always check if the response was successful:

```js
fetch('https://example.com/api', options)
    .then(response => {
        if (!response.ok) {
            throw new Error(`HTTP error! Status: ${response.status}`);
        }
        return response.json();
    })
    .then(data => console.log(data))
    .catch(error => console.error('Request failed:', error));
```

## Sending Custom Headers

If the API requires authentication (like a bearer token):

```js
fetch('https://example.com/api/secure', {
    method: 'POST',
    headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer your-token-here'
    },
    body: JSON.stringify({ message: 'Hello' })
})
.then(response => response.json())
.then(data => console.log('Secure response:', data))
.catch(error => console.error('Error:', error));
```

## Best Practices

✅ Always handle `.catch()` to avoid unhandled promise rejections.  
✅ Check `.ok` or `response.status` before assuming success.  
✅ Sanitize user inputs before sending them.  
✅ Keep sensitive keys or tokens out of client-side code when possible.

## Summary

The Fetch API makes it straightforward to send HTTP POST requests, whether you’re sending JSON, form data, or authenticated requests. Mastering it helps you build powerful integrations between your frontend and backend systems.

For more advanced use cases (like file uploads or streaming responses), explore the full Fetch documentation.

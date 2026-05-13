---
layout: default
title: Contact
permalink: /contact/
---

<div class="contact-container">
    <h1 class="contact-title">Get in Touch</h1>
    <p class="contact-intro">
        Have a question about a project, a technical challenge, or just want to say hi? Feel free to send me a message.
    </p>

    <form action="https://formspree.io/f/xyybdzld" method="POST" class="contact-form">
        <div class="form-group">
            <label for="name">Name</label>
            <input type="text" id="name" name="name" placeholder="Your Name" required>
        </div>

        <div class="form-group">
            <label for="email">Email</label>
            <input type="email" id="email" name="_replyto" placeholder="your.email@example.com" required>
        </div>

        <div class="form-group">
            <label for="subject">Subject</label>
            <input type="text" id="subject" name="subject" placeholder="What is this about?">
        </div>

        <div class="form-group">
            <label for="message">Message</label>
            <textarea id="message" name="message" rows="6" placeholder="Your message here..." required></textarea>
        </div>

        <button type="submit" class="submit-btn">Send Message</button>
    </form>
</div>

<style>
.contact-container {
    max-width: 600px;
}

.contact-title {
    font-size: 2.5rem;
    color: #343C4B;
    margin-bottom: 1rem;
}

.contact-intro {
    color: #4a5568;
    margin-bottom: 2.5rem;
    line-height: 1.6;
}

.contact-form {
    display: flex;
    flex-direction: column;
    gap: 1.5rem;
}

.form-group {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
}

.form-group label {
    font-weight: 600;
    color: rgb(61, 54, 49);
    font-size: 0.95rem;
}

.form-group input, 
.form-group textarea {
    padding: 0.75rem 1rem;
    border: 1px solid #e2e8f0;
    border-radius: 4px;
    font-family: inherit;
    font-size: 1rem;
    background-color: white;
    transition: border-color 0.2s;
}

.form-group input:focus, 
.form-group textarea:focus {
    outline: none;
    border-color: #343C4B;
}

.submit-btn {
    background-color: #343C4B;
    color: white;
    padding: 1rem;
    border: none;
    border-radius: 4px;
    font-weight: 600;
    font-size: 1rem;
    cursor: pointer;
    transition: background-color 0.2s;
    margin-top: 1rem;
}

.submit-btn:hover {
    background-color: rgb(61, 54, 49);
}
</style>

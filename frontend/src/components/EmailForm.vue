<script setup>
import { ref } from 'vue';

const recipients = ref('');
const subject = ref('');
const message = ref('');
const htmlMessage = ref('');
const status = ref('');
const error = ref('');

const sendEmail = async () => {
  status.value = 'Sending...';
  error.value = '';

  const recipientList = recipients.value
    .split(',')
    .map(e => e.trim())
    .filter(e => e);

  try {
    const response = await fetch('http://localhost:8000/api/v1/emails/send', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        subject: subject.value,
        message: message.value,
        recipients: recipientList,
        html_message: htmlMessage.value || undefined
      })
    });

    const contentType = response.headers.get('content-type');
    if (!contentType || !contentType.includes('application/json')) {
      if (response.ok) {
        status.value = 'Email sent successfully!';
        recipients.value = '';
        subject.value = '';
        message.value = '';
        htmlMessage.value = '';
      } else {
        error.value = 'Server error occurred';
        status.value = '';
      }
      return;
    }

    const result = await response.json();

    if (response.ok) {
      status.value = 'Email sent successfully!';
      recipients.value = '';
      subject.value = '';
      message.value = '';
      htmlMessage.value = '';
    } else {
      error.value = JSON.stringify(result);
      status.value = '';
    }
  } catch (err) {
    error.value = err.message;
    status.value = '';
  }
};
</script>

<template>
  <div class="email-form">
    <h1>Send Email</h1>
    <form @submit.prevent="sendEmail">
      <label>
        Recipients (comma-separated)
        <input 
          v-model="recipients" 
          type="text" 
          placeholder="email1@example.com, email2@example.com" 
          required 
        />
      </label>

      <label>
        Subject
        <input v-model="subject" type="text" required />
      </label>

      <label>
        Message
        <textarea v-model="message" required></textarea>
      </label>

      <label>
        HTML Message (optional)
        <textarea v-model="htmlMessage" placeholder="<p>HTML content</p>"></textarea>
      </label>

      <button type="submit">Send Email</button>
    </form>

    <p v-if="status" class="success">{{ status }}</p>
    <p v-if="error" class="error">{{ error }}</p>
  </div>
</template>

<style scoped>
.email-form {
  max-width: 600px;
  margin: 0 auto;
  padding: 20px;
}

h1 {
  margin-bottom: 20px;
}

label {
  display: block;
  margin-bottom: 15px;
  font-weight: bold;
}

input, textarea {
  width: 100%;
  padding: 8px;
  margin-top: 5px;
  border: 1px solid #ccc;
  border-radius: 4px;
  box-sizing: border-box;
}

textarea {
  height: 100px;
}

button {
  padding: 10px 20px;
  background-color: #007bff;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

button:hover {
  background-color: #0056b3;
}

.success {
  margin-top: 15px;
  padding: 10px;
  background-color: #d4edda;
  color: #155724;
  border-radius: 4px;
}

.error {
  margin-top: 15px;
  padding: 10px;
  background-color: #f8d7da;
  color: #721c24;
  border-radius: 4px;
}
</style>

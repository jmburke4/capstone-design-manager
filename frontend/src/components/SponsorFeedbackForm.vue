<script setup>
import { FormKit } from '@formkit/vue';
import apiService from '../services/api';
import { ref, onMounted } from 'vue';
import axios from 'axios';

const projectOptions = ref([]);
const sponsorId = ref(null);

onMounted(async () => {
  try {
    const profileResponse = await apiService.getProfile();
    sponsorId.value = profileResponse.data.id;

    const sponsorsProjectsResponse = await axios.get(`http://localhost:8000/api/v1/projects/?sponsor=${sponsorId.value}`);

    projectOptions.value = sponsorsProjectsResponse.data.map(project => ({
      label: project.name,
      value: project.id
    }));

  } catch (error) {
    console.error("Error loading projects:", error);
  }
});

async function handleSubmission(data) {

  try {

    const feedbackPayload = {
      text: data.sponsor_info.feedback,
      sponsor: sponsorId.value,
      project: data.project
    }

    const feedbackResponse = await fetch(
      "http://localhost:8000/api/v1/feedback/",
      {
        method: "POST",
        headers: { 
            "Content-Type": "application/json",
            "Accept": "application/json" 
        },
        body: JSON.stringify(feedbackPayload)
      }
    )
    
    if (!feedbackResponse.ok) {
        let errorText;
        try {
            const json = await feedbackResponse.json(); // parse JSON if the server sent it
            errorText = JSON.stringify(json, null, 2);
        } catch {
            errorText = await feedbackResponse.text(); // fallback for plain text/HTML
        }
        console.error("Feedback API returned:", errorText);
        throw new Error("Feedback submission failed");
    }

    alert("Feedback submitted successfully!")

  } catch (error) {
    console.error("Submission failed:", error)
    if (error instanceof Error) {
      alert(error.message); // e.g. "You have reached the maximum number of allowed projects."
    } else {
      // fallback for unexpected errors
      alert("Submission failed.");
    }
  }
}

</script>

<template>
    <div class="container">
    <h1>Sponsor Feedback</h1>
    <div class="card">
    <div class="form-container">
        <FormKit 
        type="form" 
        id="sponsor-form"
        submit-label="Submit Sponsor Feedback"
        @submit="handleSubmission"
        >

        <!-- Project Selection -->
        <FormKit
            type="radio"
            name="project"
            label="Select a Project"
            :options="projectOptions"
            validation="required"
            outer-class="bubble-group"
            input-class="hidden-radio"
            option-class="bubble-option"
            />

        <FormKit type="group" name="sponsor_info">
            <FormKit
            type="textarea"
            name="feedback"
            validation="required"
            />
        </FormKit>
        </FormKit>
    </div>
    </div>
    </div>
</template>

<style scoped>
hr {
    margin-top: 2rem;
}
.container {
  text-align: left;
  max-width: var(--max-content-width);
  margin: 0 auto;
}

/* Layout for the options */
.bubble-group .formkit-options {
  display: flex;
  gap: 10px;
  margin: 1rem 0;
}

/* Hide default radio buttons */
.hidden-radio input {
  display: none;
}

/* Each bubble */
.bubble-option {
  padding: 10px 16px;
  border: 2px solid #ccc;
  border-radius: 999px;
  cursor: pointer;
  transition: all 0.2s ease;
  user-select: none;
}

/* Hover effect */
.bubble-option:hover {
  border-color: #888;
}

/* Selected state (this is the key part) */
.bubble-option[data-checked="true"] {
  background-color: #007bff;
  color: white;
  border-color: #007bff;
}

.bubble-option:active {
  transform: scale(0.97);
}
</style>
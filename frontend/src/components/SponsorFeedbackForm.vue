<script setup>
import { FormKit } from '@formkit/vue';
import apiService from '../services/api';
import { ref, onMounted } from 'vue';
import { useAuth0 } from '@auth0/auth0-vue';

const { getAccessTokenSilently } = useAuth0()

const projectOptions = ref([]);
const sponsorId = ref(null);
const semesterId = ref(null);

onMounted(async () => {
  try {
    const token = await getAccessTokenSilently();
    apiService.setToken(token);

    const profile = await apiService.getProfile();
    sponsorId.value = profile?.data?.id ?? null;

    const semester = await apiService.getCurrentSemester();
    semesterId.value = semester?.id ?? null;

    if (!sponsorId.value || !semesterId.value) {
      projectOptions.value = [];
      return;
    }

    const sponsorProjects = await apiService.getProjectsBySponsor(sponsorId.value);

    projectOptions.value = sponsorProjects.map(project => ({
      label: project.name,
      value: project.id
    }));

  } catch (error) {
    console.error("Error loading projects:", error);
  }
});

async function handleSubmission(data) {

  try {
    const token = await getAccessTokenSilently();
    apiService.setToken(token);
    
    const feedbackPayload = {
      text: data.sponsor_info.feedback,
      sponsor: sponsorId.value,
      project: data.project,
      semester: semesterId.value
    }

    await apiService.createFeedback(feedbackPayload);

    alert("Feedback submitted successfully!")

  } catch (error) {
    console.error("Submission failed:", error)
    const errorMessage = error?.response?.data
      ? JSON.stringify(error.response.data)
      : (error?.message || "Submission failed.");

    if (error instanceof Error) {
      alert(errorMessage);
    } else {
      alert("Submission failed.");
    }
  }
}

</script>

<template>
    <div class="container">
    <h1>Feedback Submission</h1>
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
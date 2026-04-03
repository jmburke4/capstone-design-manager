<script setup>
import { FormKit } from '@formkit/vue';
import apiService from '../services/api';
import axios from 'axios';

async function handleSubmission(data) {

  try {

    const profileResponse = await apiService.getProfile();

    const sponsorId = profileResponse.data.id;
    const currentProjectsResponse = await axios.get(`http://localhost:8000/api/v1/projects/?sponsor=${sponsorId}`);
    const currentProjects = currentProjectsResponse.data;
    const projectCount = currentProjects.length;
    const projectNumLimit = Number(profileResponse.data.projects_allowed);

    if (projectCount >= projectNumLimit) {
      throw new Error("You have reached the maximum number of allowed projects.");
    }

    const projectPayload = {
      name: data.project_details.name,
      description: data.project_details.description,
      website: data.project_details.website || null,
      sponsor: sponsorId
    }

    const projectResponse = await fetch(
      "http://localhost:8000/api/v1/projects/",
      {
        method: "POST",
        headers: { 
            "Content-Type": "application/json",
            "Accept": "application/json" 
        },
        body: JSON.stringify(projectPayload)
      }
    )
    
    if (!projectResponse.ok) {
    const text = await projectResponse.text()
    console.error("Project API returned HTML/text:", text)
    throw new Error("Project creation failed")
    }

    alert("Project submitted successfully!")

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
    <h1>Sponsor Project Submission</h1>
    <div class="card">
    <div class="form-container">
        <FormKit 
        type="form" 
        id="sponsor-form"
        submit-label="Submit Project Proposal"
        @submit="handleSubmission"
        >

        <FormKit type="group" name="sponsor_info">
            <h3>Contact Information</h3>
            <FormKit
            type="text"
            name="company_name"
            label="Company/Organization"
            validation="required"
            />
            <FormKit
            type="email"
            name="contact_email"
            label="Primary Contact Email"
            validation="required|email"
            />
        </FormKit>

        <hr />

        <FormKit type="group" name="project_details">
            <h3>Project Details</h3>
            <FormKit
            type="text"
            name="name"
            label="Project Name"
            validation="required|length:5,100"
            />
            
            <FormKit
            type="url"
            name="website"
            label="Project/Company Website"
            placeholder="https://..."
            validation="url"
            />

            <FormKit
            type="textarea"
            name="description"
            label="Project Description"
            validation="required|length:20,2000"
            help="Describe the premise of the project and expected outcomes alongside any technical details."
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
</style>
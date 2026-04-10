<script setup>
import { FormKit } from '@formkit/vue';
import apiService from '../services/api';
import { useAuth0 } from '@auth0/auth0-vue';

const { getAccessTokenSilently } = useAuth0();

async function handleSubmission(data) {

  try {
    const token = await getAccessTokenSilently();
    apiService.setToken(token);

    const profileResponse = await apiService.getProfile();

    const sponsorId = profileResponse.data.id;
    const currentProjects = await apiService.getProjectsBySponsor(sponsorId);
    const projectCount = currentProjects.length;
    const projectNumLimit = Number(profileResponse.data.projects_allowed);

    if (projectCount >= projectNumLimit) {
      throw new Error("You have reached the maximum number of allowed projects.");
    }

    const projectPayload = {
      name: data.project_details.name,
      description: data.project_details.description,
      website: data.project_details.website || null,
      sponsor: sponsorId,
      sponsor_availability: data.sponsor_info.availability
    }

    await apiService.createProject(projectPayload);

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
    <h1>Project Submission</h1>
    <div class="card">
    <div class="form-container">
        <FormKit 
        type="form" 
        id="sponsor-form"
        submit-label="Submit Project Proposal"
        @submit="handleSubmission"
        >

        <div class="form-intro">
          <p>
            Thank you for your interest in sponsoring a computer science capstone projects. Our students have 
            spent 4 years aquiring skills. The opportunity to have a culminating experience that incorporates
            everything they have learned is invaluable. your willingness to be a part of that experience 
            appreciated. At the same time, we are honored to contribute to the university community.
          </p>
          <p>
            When presenting your project, students will want to know the purpose of the system, who will be 
            using it, and what users should be able to do. It is helpful to provide information on how the 
            users will access the systems and how many users you expect.
          </p>
          <p><strong>External Sponsor/Student Agreement</strong></p>
          <p>Project sponsors will: </p>
          <ul>
            <li>Provide students with a list of user interactions and functionality (what the software should do).</li>
            <li>Meet with students weekly to prioritize feature implementation.</li>
            <li>Provide frequent feedback on how well the software meets the business requirements.</li>
            <li>Provide timely answers to questions.</li>
          </ul>
          <p>
            Students will:
          </p>
          <ul>
            <li>Choose tools, language and platforms that are appropriate for the requirements.</li>
            <li>Use Agile Software Development Practices.</li>
            <li>Document non-functional requirements.</li>
            <li>Incorporate feedback from project sponsors.</li>
            <li>Keep accurate records of all meetings and interactions.</li>
        </ul>
        </div>

        <hr />

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

            <FormKit
            type="textarea"
            name="availability"
            label="Sponsor Availability"
            validation="required"
            help="State days of the week and the respective times of day you are available (Morning/Afternoon)"
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
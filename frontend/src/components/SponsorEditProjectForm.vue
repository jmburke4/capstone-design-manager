<script setup>
import { FormKit } from '@formkit/vue';
import apiService from '../services/api';
import { ref, onMounted, watch } from 'vue';
import { useAuth0 } from '@auth0/auth0-vue';

const { getAccessTokenSilently } = useAuth0();
const sponsorId = ref(null);
const sponsorProjects = ref([]);
const projectOptions = ref([]);
const formData = ref({
  sponsor_info: {
    company_name: '',
    contact_email: '',
    availability: ''
  },
  project_details: {
    name: '',
    website: '',
    description: ''
  }
})

onMounted(async () => {
    const token = await getAccessTokenSilently();
    apiService.setToken(token);
    const profileResponse = await apiService.getProfile();
    sponsorId.value = profileResponse.data.id ?? null;

        if (!sponsorId.value) {
            sponsorProjects.value = [];
            return;
        }

    if (sponsorId.value) {
      sponsorProjects.value = await apiService.getProjectsBySponsor(sponsorId.value);
      projectOptions.value = sponsorProjects.value.map(project => ({
        label: project.name,
        value: project.id
      }));
      formData.value.project = sponsorProjects.value?.[0]?.id ?? null;
    }
});

function loadProject(projectId) {
  const project = sponsorProjects.value.find(p => p.id === projectId)
  if (!project) return

  formData.value.sponsor_info.company_name = project.company_name ?? ''
  formData.value.sponsor_info.contact_email = project.contact_email ?? ''
  formData.value.sponsor_info.availability = project.sponsor_availability ?? ''

  formData.value.project_details.name = project.name ?? ''
  formData.value.project_details.website = project.website ?? ''
  formData.value.project_details.description = project.description ?? ''
}

watch(
  () => formData.value.project,
  (id) => {
    if (id) loadProject(id)
  }
)

async function handleSubmission(data) {

  try {
    console.log('SUBMIT FIRED', data)
    const projectPayload = {
      name: data.project_details.name,
      description: data.project_details.description,
      website: data.project_details.website || null,
      sponsor: sponsorId,
      sponsor_availability: data.sponsor_info.availability
    }

    await apiService.editProject(projectPayload);

    alert("Project edited successfully!")

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
    <h1>Edit Project</h1>
    <div class="card">
    <div class="form-container">
        <FormKit 
        type="form" 
        id="sponsor-form"
        v-model="formData"
        submit-label="Edit Your Project"
        @submit="handleSubmission"
        >

        <FormKit
            type="select"
            name="project"
            label="Select a Project"
            :options="projectOptions"
            validation="required"
            />

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

.card {
  padding: 1.5rem;
}

.form-container :deep(.formkit-outer) {
  margin-bottom: 1rem;
}
</style>
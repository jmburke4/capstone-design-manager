<script setup>
import { FormKit } from '@formkit/vue';

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
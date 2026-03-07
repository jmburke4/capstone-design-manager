<script setup>
import { FormKit } from '@formkit/vue';

async function handleSubmission(data) {

  try {

    const sponsorPayload = {
      first_name: "Sponsor",
      last_name: "Contact",
      organization: data.sponsor_info.company_name,
      email: data.sponsor_info.contact_email
    }

    const sponsorResponse = await fetch(
        "http://localhost:8000/api/v1/sponsors/", 
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json"
          },
          body: JSON.stringify(sponsorPayload)
        }
    )
    
    if (!sponsorResponse.ok) {
        const text = await sponsorResponse.text() // read raw HTML/text
        console.error("Sponsor API returned HTML/text:", text)
        throw new Error("Sponsor creation failed")
    }

    const sponsor = await sponsorResponse.json()

    const projectPayload = {
      name: data.project_details.name,
      description: data.project_details.description,
      website: data.project_details.website || null,
      sponsor: sponsor.id
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
    alert("Submission failed.")
  }
}

</script>

<template>
    <div class="form-container">
        <FormKit 
        type="form" 
        id="sponsor-form"
        submit-label="Submit Project Proposal"
        @submit="handleSubmission"
        >
        <h1>Sponsor Project Submission</h1>

        <FormKit type="group" name="sponsor_info">
            <h2>Contact Information</h2>
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
            <h2>Project Details</h2>
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
</template>

<style scoped>

.form-container {
  text-align: left;
  max-width: var(--max-content-width);
  margin: 0 auto;
}
</style>
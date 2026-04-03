<!-- Sponsor Landing Page -->
<!-- Roles:
        View project
        Submit project
        Submit feedback
        View assigned student contact info (?)
-->
<script setup>
    import ProjectTable from './ProjectTable.vue'
    import apiService from '../services/api';
    import { ref, onMounted } from 'vue';

    const currentSponsorId = ref(null); // will hold the sponsor ID
    const error = ref(null);             // optional error handling

    onMounted(async () => {
        try{
            const profileResponse = await apiService.getProfile();

            if (profileResponse && profileResponse.data.id) {
                currentSponsorId.value = String(profileResponse.data.id);
            }
            else {
                console.warn('No ID found in profile response');
                currentSponsorId.value = null;
            }
        } catch (err) {
            console.error('Failed to fetch user profile:', err);
            error.value = err;
            currentSponsorId.value = null;
        }
    });
</script>

<template>
    <h1>Sponsor Page</h1>
    <div class="table-wrapper">
        <ProjectTable :sponsor-id="currentSponsorId" />
    </div>
</template>

<style scoped>
.table-wrapper {
  margin-bottom: 2rem; /* Adjust this value to increase/decrease space */
}
.wrapper {
    margin: 0 auto;
    max-width: var(--max-content-width);
    display: flex;
    flex-direction: column;
    gap: 1rem;
}
button {
    width: 100%;
}
</style>
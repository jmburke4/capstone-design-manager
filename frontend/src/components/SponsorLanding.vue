<script setup>
import SponsorProjectCard from './SponsorProjectCard.vue';
import apiService from '../services/api';
import { ref, onMounted } from 'vue';
import { useAuth0 } from '@auth0/auth0-vue';

const { getAccessTokenSilently } = useAuth0();

const currentSponsorId = ref(null);
const projects = ref([]);
const loading = ref(true);
const error = ref(null);

onMounted(async () => {
    try {
        const token = await getAccessTokenSilently();
        apiService.setToken(token);

        const profileResponse = await apiService.getProfile();
        currentSponsorId.value = profileResponse?.data?.id ?? null;

        if (!currentSponsorId.value) {
            projects.value = [];
            return;
        }

        const sponsorProjects = await apiService.getProjectsBySponsor(currentSponsorId.value);
        projects.value = Array.isArray(sponsorProjects) ? sponsorProjects : [];
    } catch (err) {
        console.error('Failed to fetch sponsor projects:', err);
        error.value = err;
        projects.value = [];
    } finally {
        loading.value = false;
    }
});
</script>

<template>
    <div class="inside-wrapper">
        <h1>Sponsor Dashboard</h1>
        <h2>Projects</h2>
        <p v-if="loading">Loading projects...</p>
        <p v-else-if="error">Unable to load projects.</p>

        <div v-else-if="projects.length" class="cards-list">
            <div v-for="project in projects" :key="project.id" class="card-item">
                <SponsorProjectCard :project="project" />
            </div>
    </div>
        <p v-else>No projects submitted yet.</p>
    </div>
</template>

<style scoped>
h2 {
    margin: 0;
}
.inside-wrapper {
    margin: 0 auto;
    max-width: var(--max-content-width);
    display: flex;
    flex-direction: column;
    gap: 1rem;
}

.cards-list {
    display: flex;
    flex-direction: column;
    gap: 1.5rem;
    margin-bottom: 2rem;
}

button {
    width: 100%;
}
</style>
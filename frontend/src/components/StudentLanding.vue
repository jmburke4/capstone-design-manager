<!-- Student Landing Page -->
<!-- Roles:
        Submit project ranking
        View project descriptions
-->

<script setup>
import { ref, onMounted } from 'vue';
import { useAuth0 } from '@auth0/auth0-vue';
import apiService from '../services/api';

const { getAccessTokenSilently } = useAuth0();

const topPreferences = ref([]);
const hasRanked = ref(false);
const loading = ref(true);

onMounted(async () => {
  try {
    const token = await getAccessTokenSilently();
    apiService.setToken(token);

    const profileRes = await apiService.getProfile();
    const profile = profileRes?.data ?? profileRes;
    const studentId = profile?.id;
    if (!studentId){
        loading.value = false;
        return;
    } 

    const prefsRes = await apiService.client.get('/preferences/');
    const prefs = Array.isArray(prefsRes.data) ? prefsRes.data : [];

    const studentPrefs = prefs.filter(pref => {
      let prefStudent = pref.student;
      if (prefStudent && typeof prefStudent === 'object') prefStudent = prefStudent.id;
      return String(prefStudent) === String(studentId);
    });

    if (!studentPrefs.length) {
        loading.value = false;
        return;
    } 

    hasRanked.value = true;

    // Ensure we have project names: fetch all projects once and map by id
    const projectsRes = await apiService.client.get('/projects/');
    const projectById = Object.fromEntries(projectsRes.data.map(p => [String(p.id), p]));

    // sort by rank (ascending) and take top 5
    studentPrefs.sort((a, b) => (a.rank || 999) - (b.rank || 999));
    topPreferences.value = studentPrefs.slice(0, 5).map(pref => {
      const projId = pref.project && typeof pref.project === 'object' ? pref.project.id : pref.project;
      const proj = projectById[String(projId)];
      return {
        id: projId,
        name: proj?.name ?? (pref.project?.name ?? 'Unknown'),
        description: proj?.description ?? ''
      };
    });
  } catch (e) {
    console.error('Failed to load top preferences', e);
  } finally {
    loading.value = false;
  }
});
</script>

<template>

<!-- TODO: implement logic for deadline countdown, assignment -->
<div class="inside-wrapper">
    <h1>Student Dashboard</h1>
    <div class="card">
        <h2>Submission Deadline Countdown</h2>
        <span>14 days, 4 hours</span>
    </div>
    <div class="card">
        <h2>Top 5 Rankings</h2>
        <div v-if="loading"><p>Loading...</p></div>
        <div v-else-if="hasRanked && topPreferences.length">
            <ul class="preference-list">
                <li v-for="p in topPreferences" :key="p.id">
                <p>{{ p.name }}</p>
                </li>
            </ul>
            <span><router-link class="redirect" to="/student/submit">Edit your preferences →</router-link></span>
        </div>
        <div v-else>
            <span>You don't have any rankings yet. <router-link class="redirect" to="/student/submit">Submit rankings now →</router-link></span>
        </div>
    </div>
    
    <div class="card">
        <h2>Project Assignment</h2>
        <span>Due date has not passed yet.</span>
    </div>
</div>
</template>

<style scoped>
h2 {
    margin-top: 0em;
    margin-bottom: 0.5em;
}
.redirect {
    color: var(--text-link)
}
.inside-wrapper {
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
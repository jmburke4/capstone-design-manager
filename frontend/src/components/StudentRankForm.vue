<script setup>
import { ref, onMounted, computed } from 'vue';
import axios from 'axios';
import { useRouter } from 'vue-router';
import { useAuth0 } from '@auth0/auth0-vue';
import apiService from '../services/api';
import ConfirmationModal from './ConfirmationModal.vue';
import { FormKit } from '@formkit/vue';

const { getAccessTokenSilently } = useAuth0()

const router = useRouter();

const showConfirm = ref(false);

const hasRanked = ref(false);
const projects = ref([]);
const loading = ref(true);
const error = ref(null);
const isSubmitting = ref(false);

const studentProfile = ref(null);

const fetchProfileAndProjects = async () => {
  try {
    loading.value = true;
    const token = await getAccessTokenSilently();
    apiService.setToken(token);

    // load projects + profile in parallel
    const [projectsRes, profileRes] = await Promise.all([
      apiService.client.get('/projects/'),
      apiService.getProfile()
    ]);

    projects.value = projectsRes.data.map(p => ({ ...p, selection: null }));
    studentProfile.value = profileRes?.data ?? profileRes;

    // if we have a student id, fetch preferences and apply them to the projects
    const studentId = studentProfile.value?.id;
    if (studentId) {
      const prefsRes = await apiService.client.get('/preferences/');
      const prefs = Array.isArray(prefsRes.data) ? prefsRes.data : [];
      hasRanked.value = prefs.some(pref => {
        let prefStudent = pref.student;
        if (prefStudent && typeof prefStudent === 'object') prefStudent = prefStudent.id;
        return String(prefStudent) === String(studentId);
      });

      const rankToSelection = { 1: 'high', 2: 'medium', 3: 'low' };

      prefs.forEach(pref => {
        // normalize student id on preference (pref.student might be an id or object)
        let prefStudent = pref.student;
        if (prefStudent && typeof prefStudent === 'object') prefStudent = prefStudent.id;
        if (String(prefStudent) !== String(studentId)) return;

        // normalize project id (pref.project might be an id or object)
        const prefProjectId = pref.project && typeof pref.project === 'object'
          ? pref.project.id
          : pref.project;

        const project = projects.value.find(p => String(p.id) === String(prefProjectId));
        if (project) {
          project.selection = rankToSelection[pref.rank] ?? null;
        }
      });
    }
  } catch (err) {
    error.value = "Identity verification failed. Please log in again.";
    console.error(err);
  } finally {
    loading.value = false;
  }
}

onMounted(fetchProfileAndProjects);

// const fetchProjects = async () => {
//     try {
//         const { data } = await axios.get('/api/v1/projects/');
//         // Initialize each project with no selection
//         projects.value = data.map(p => ({ ...p, selection: null }));
//     } catch (err) {
//         error.value = "Failed to load projects. Is the backend running?";
//         console.error(err);
//     } finally {
//         loading.value = false;
//     }
// };

// onMounted(fetchProjects);

const togglePreference = (index, rank) => {
    if (projects.value[index].selection === rank) {
        projects.value[index].selection = null; // Deselect if clicking the same button
    } else {
        projects.value[index].selection = rank; // Switch to new selection
    }
};

// Calculate counts for validation
const counts = computed(() => {
    return {
        high: projects.value.filter(p => p.selection === 'high').length,
        medium: projects.value.filter(p => p.selection === 'medium').length,
        low: projects.value.filter(p => p.selection === 'low').length,
    };
});

const isFormValid = computed(() => {
    return counts.value.high === 5 && 
            counts.value.medium === 5 && 
            counts.value.low === 5;
});

// Map UI strings to IntegerChoices from model
const rankMap = {
    high: 1,
    medium: 2,
    low: 3
}

// Compute payload to match preference model fields
const rankingPayload = computed(() => {
    if (!studentProfile.value) return [];

    return projects.value
        .filter(p => p.selection !== null)
        .map(p => ({
            // Matches the "1-2" format: studentID-projectID
            id: `${studentProfile.value.id}-${p.id}`, 
            student: studentProfile.value.id,
            project: p.id,
            rank: rankMap[p.selection]
        }));
});

const openConfirm = () => { showConfirm.value = true; };

const onConfirm = async () => {
  showConfirm.value = false;
  await submitRankings();
}


const submitRankings = async () => {
  if (!isFormValid.value) return;
  isSubmitting.value = true;
  try {
    const token = await getAccessTokenSilently();
    apiService.setToken(token);

    if (hasRanked.value) {
      await apiService.client.patch('/preferences/', rankingPayload.value);
    } else {
      await apiService.client.post('/preferences/', rankingPayload.value);
      hasRanked.value = true;
    }

    // Refresh local view of preferences so UI shows updates
    await fetchProfileAndProjects();

    router.push({
      path: '/student',
      query: { flash: 'success', message: 'Your preferences have been saved.' }
    });
    
  } catch (err) {
    const errorDetail = err.response?.data?.detail || JSON.stringify(err.response?.data) || 'Check console for details';
    console.error('Submission Error:', err.response?.data ?? err);
    router.push({
      path: '/student',
      query: { flash: 'failure', message: `Submission failed: ${errorDetail}` }
    });
  } finally {
    isSubmitting.value = false;
  }
};
</script>

<template>
<div class="ranking-container">
    <h1>Project Preference Rankings</h1>

    <div class="card">
    <p>Select exactly 5 projects for each priority level.</p>

    <div v-if="loading" class="status-msg">Loading projects...</div>
    <div v-else-if="error" class="status-msg error">{{ error }}</div>

    <div v-else>
      <table class="ranking-grid">
        <thead>
          <tr>
            <th style="text-align: left;">Project Name</th>
            <th>High</th>
            <th>Medium</th>
            <th>Low</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(project, index) in projects" :key="project.id">
            <td class="project-name">{{ project.name }}</td>
            
            <td v-for="rank in ['high', 'medium', 'low']" :key="rank">
              <button 
                type="button"
                :class="['rank-btn', rank, { active: project.selection === rank }]"
                @click="togglePreference(index, rank)"
              >
                <!-- {{ rank.charAt(0).toUpperCase() }} -->
              </button>
            </td>
          </tr>
        </tbody>
      </table>

      <!-- <p v-if="!isFormValid" class="helper-text">
        You must select exactly 5 of each before submitting.
      </p> -->

      <footer class="submission-area">
        <div class="counters">
          <div :class="['counter-box', { complete: counts.high === 5 }]">
            <span>High {{ counts.high }}/5</span>
          </div>
          <div :class="['counter-box', { complete: counts.medium === 5 }]">
            <span>Med {{ counts.medium }}/5</span>
          </div>
          <div :class="['counter-box', { complete: counts.low === 5 }]">
            <span>Low {{ counts.low }}/5</span>
          </div>
        </div>

        <div class="comment-area">
          <p>Provide any additional information. We will not be able to accommodate all requests.</p>
          <FormKit
            type="textarea"
            name="comment"
            validation="length:0,2000"
            />
        </div>

        <button 
          class="submit-button" 
          :disabled="!isFormValid || isSubmitting"
          @click="openConfirm"
        >
          {{ isSubmitting ? 'Saving...' : (hasRanked ? 'Update Project Rankings' : 'Submit Project Rankings') }}
        </button>
        <ConfirmationModal :show="showConfirm" title="Submit rankings?" message="These changes can be updated any amount of times before the deadline." @confirm="onConfirm" @cancel="() => showConfirm = false" />
        
      </footer>
    </div>
    </div>
  </div>
</template>

<style scoped>
.ranking-container {
  max-width: var(--max-content-width);
  margin: 0 auto;
  /* font-family: sans-serif; */
}

.ranking-grid {
  width: 100%;
  border-collapse: collapse;
}

.ranking-grid th, .ranking-grid td {
  padding: 15px;
  border-bottom: 1px solid var(--border-subtle);
  text-align: center;
}

.project-name {
  text-align: left !important;
  font-weight: 600;
  width: 60%;
}

.rank-btn {
  width: 25px;
  height: 25px;
  border-radius: 50%;
  padding: 0;
  border: 2px solid #ddd;
  background: transparent;
  cursor: pointer;
  transition: all 0.2s ease;
}

.rank-btn.high.active { background: var(--accent-primary); border-color: var(--accent-dark); color: white; }
.rank-btn.medium.active { background: var(--accent-primary); border-color: var(--accent-dark); color: white; }
.rank-btn.low.active { background: var(--accent-primary); border-color: var(--accent-dark); color: white; }

.rank-btn:hover:not(.active) {
  border-color: #999;
}

/* FOOTER & COUNTERS */
.submission-area {
  margin-top: 20px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 15px;
}

.counters {
  width: 100%;
  display: flex;
  gap: 20px;
}

.counter-box {
  width: 100%;
  padding: 10px 20px;
  border-radius: 8px;
  color: var(--text-negative);
  background: var(--background-negative);
  border: 1px solid var(--accent-negative);
  text-align: center;
}

.counter-box.complete {
  border-color: var(--accent-positive);
  background: var(--background-positive);
  color: var(--text-positive);
}

.comment-area {
  width: 100%;
}

.submit-button {
  padding: 1rem 2rem;
  width: 100%;
  color: white;
  cursor: pointer;
}

.submit-button:disabled {
  background: var(--accent-neutral);
  cursor: not-allowed;
}

.helper-text {
  color: #dc2626;
  font-size: 0.9rem;
}

.status-msg.error { color: #dc2626; font-weight: bold; }
</style>
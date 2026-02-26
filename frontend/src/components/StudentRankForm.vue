<script setup>
import { ref, onMounted, computed } from 'vue';
import axios from 'axios';
import { useRouter } from 'vue-router';

const router = useRouter();

const projects = ref([]);
const loading = ref(true);
const error = ref(null);
const isSubmitting = ref(false);

const fetchProjects = async () => {
    try {
        const { data } = await axios.get('/api/v1/projects/');
        // Initialize each project with no selection
        projects.value = data.map(p => ({ ...p, selection: null }));
    } catch (err) {
        error.value = "Failed to load projects. Is the backend running?";
        console.error(err);
    } finally {
        loading.value = false;
    }
};

onMounted(fetchProjects);

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
    return projects.value
        .filter(p => p.selection !== null)
        .map(p => ({
            student: 1, // TODO: replace with current student's ID from auth/store
            project: p.id,
            rank: rankMap[p.selection]
        }));
});


const submitRankings = async () => {
    if (!isFormValid.value) return;

    isSubmitting.value = true;
    try {
        // TODO: implement post of preferences
        alert('Submission successful.');
        router.push('/student');
    } catch (err) {
        console.error('One or more requests failed:', err.response?.data);
        alert('Error: Submission failed.');
    } finally {
        isSubmitting.value = false;
    }
};
</script>

<template>
<div class="ranking-container">
    <header>
      <h1>Project Preference Rankings</h1>
      <p>Select exactly 5 projects for each priority level.</p>
    </header>

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

        <button 
          class="submit-button" 
          :disabled="!isFormValid || isSubmitting"
          @click="submitRankings"
        >
          {{ isSubmitting ? 'Saving...' : 'Submit Project Rankings' }}
        </button>

        
      </footer>
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
  border-bottom: 1px solid #565656;
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

.rank-btn.high.active { background: #ef4444; border-color: #b91c1c; color: white; }
.rank-btn.medium.active { background: #f59e0b; border-color: #b45309; color: white; }
.rank-btn.low.active { background: #3b82f6; border-color: #1d4ed8; color: white; }

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
  color: var(--text-muted);
  border: 1px solid var(--text-muted);
  text-align: center;
}

.counter-box.complete {
  border-color: #10b981;
  /* background: #ecfdf5; */
  color: #10b981;
}

.submit-button {
  padding: 1rem 2rem;
  width: 100%;
  font-weight: bold;
  color: white;
  cursor: pointer;
}

.submit-button:disabled {
  background: var(--text-muted);
  cursor: not-allowed;
}

.helper-text {
  color: #dc2626;
  font-size: 0.9rem;
}

.status-msg.error { color: #dc2626; font-weight: bold; }
</style>
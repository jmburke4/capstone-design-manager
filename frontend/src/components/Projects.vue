<script setup>
import { ref, onMounted } from 'vue';
import axios from 'axios';
import { useRouter } from 'vue-router';
import StudentProjectCard from './StudentProjectCard.vue';

const router = useRouter();

// 1. Reactive State
const posts = ref([]); // Initialize as empty array to avoid v-for errors
const loading = ref(true);
const error = ref(null);

// 2. Fetch Logic
const fetchData = async () => {
  try {
    loading.value = true; // Reset loading state if called again
    const response = await axios.get('http://localhost:8000/api/v1/projects/?format=json');
    posts.value = response.data; 
  } catch (err) {
    error.value = err;
    console.error("Fetch Error:", err);
  } finally {
    loading.value = false;
  }
};

// 3. Navigation Logic (Missing from your snippet)
const handleNavigate = (project) => {
  router.push({
    name: 'ProjectDescription',
    params: { id: project.id },
    state: { project: JSON.parse(JSON.stringify(project)) }
  });
};

// 4. Trigger the fetch on mount
onMounted(() => {
  fetchData();
});
</script>

<template>
  <div>
    <h1>Project Gallery</h1>
    <!-- <h5 v-if="loading">Fetching data...</h5>
    <div v-if="error">Error: {{ error.message }}</div>
    <div ref="tableContainer"></div> -->
    
    <div v-if="loading" class="status-msg">Fetching projects...</div>
    <div v-else-if="error" class="status-msg error">Error: {{ error.message }}</div>
    
    <div v-else class="project-grid">
      <StudentProjectCard 
        v-for="project in posts" 
        :key="project.id" 
        :project="project"
        @view-details="handleNavigate"
      />
    </div>
  </div>
</template>

<style scoped>
.project-grid {
  display: grid;
  /* Creates a responsive grid that fits as many 300px cards as possible */
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 1.5rem;
}

.status-msg {
  text-align: center;
  padding: 3rem;
  font-size: 1.2rem;
  color: #666;
}
</style>
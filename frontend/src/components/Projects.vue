<script setup>
import { ref, onMounted } from 'vue';
import axios from 'axios';
import { useRouter } from 'vue-router';
import StudentProjectCard from './StudentProjectCard.vue';
import ProjectDetailsSidebar from './ProjectDetailsSidebar.vue';

const router = useRouter();

// Reactive State
const posts = ref([]); // Initialize as empty array to avoid v-for errors
const loading = ref(true);
const error = ref(null);
const selectedProject = ref(null); // For sidebar details

// Fetch Logic
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

// Toggle sidebar
const openDetails = (project) => {
  selectedProject.value = project;
}

const closeDetails = () => {
  selectedProject.value = null;
}

// Trigger the fetch on mount
onMounted(fetchData);
</script>

<template>
  <div>

    <div class="gallery-layout">

      <div class="grid-container" :class="{ 'pane-open': selectedProject}">
        <h1>Project Gallery</h1>
        
        <div v-if="loading" class="status-msg">Fetching projects...</div>
        <div v-else-if="error" class="status-msg error">Error: {{ error.message }}</div>
        <div v-else class="project-grid">
          <StudentProjectCard 
            v-for="project in posts" 
            :key="project.id" 
            :project="project"
            @click="openDetails(project)"
          />
        </div>
      </div>

      <transition name="slide-fade">
        <aside v-if="selectedProject" class="card-details">
          <ProjectDetailsSidebar
            :project="selectedProject"
            @close="closeDetails"
          />
        </aside>
      </transition>
    </div>
  </div>
</template>

<style scoped>
.project-grid {
  display: grid;
  /* Creates a responsive grid that fits as many 350px cards as possible */
  grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
  gap: 1.5rem;
}

.gallery-layout {
  display: flex;
  gap: 2rem;
  align-items: flex-start;
  min-height: 80vh;
}

.grid-container {
  flex: 1; /* Takes all space when pane is closed */
  display: flex;
  flex-direction: column;
  transition: all 0.3s ease;
}

/* When pane is open, force grid to fewer cols */
.grid-container.pane-open .project-grid {
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
}

.card-details {
  width: 450px;
  /* padding: 2rem; */
  border-radius: 16px;
  height: calc(100vh - 4rem);
  background: var(--background-element);
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
  position: sticky;
  top: 2rem;
  overflow-y: scroll;
}

/* Smooth transition for opening the pane */
.slide-fade-enter-active, .slide-fade-leave-active {
  transition: all 0.3s ease;
}
.slide-fade-enter-from, .slide-fade-leave-to {
  transform: translateX(20px);
  opacity: 0;
}

.status-msg {
  text-align: center;
  padding: 3rem;
  font-size: 1.2rem;
  color: var(--text-muted);
}
</style>
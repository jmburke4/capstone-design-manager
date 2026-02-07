<template>
  <div>
    <h5 v-if="loading">Fetching data...</h5>
    <div v-if="error">Error: {{ error.message }}</div>
    <ul v-if="posts">
      <li v-for="post in posts" :key="post.id">
        {{ post.name }} {{ post.description }}
      </li>
    </ul>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import axios from 'axios';

// 1. Define reactive state for data, loading, and errors
const posts = ref(null);
const loading = ref(true);
const error = ref(null);

// 2. Define the asynchronous fetching function
const fetchData = async () => {
  try {
    const response = await axios.get('http://localhost:8000/api/v1/projects/?format=json'); // Example API endpoint
    posts.value = response.data; // Axios automatically parses JSON into the .data property
  } catch (err) {
    error.value = err;
    console.error(err);
  } finally {
    loading.value = false;
  }
};

// 3. Call the fetch function when the component mounts
onMounted(() => {
  fetchData();
});
</script>

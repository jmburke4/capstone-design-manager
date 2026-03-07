<template>
  <div :key="$route.fullPath" class="project-page">
    <h1>Projects</h1>
    <ProjectTable />
  </div>
</template>

<script setup>
import ProjectTable from './ProjectTable.vue'
</script>

<script setup>
import HelloWorld from './components/HelloWorld.vue'
import Projects from './components/Projects.vue'
import Sponsors from './components/Sponsors.vue'
</script>

<template>
  <div class="app-container">
    <nav class="navbar">
      <router-link to="/">Home</router-link>
      <router-link to="/projects">Projects</router-link>
      <router-link to="/sponsors">Sponsors</router-link>
      <router-link to="/students">Students</router-link>
    </nav>
    <main class="content">
      <router-view />
    </main>
  </div>
</template>

<style scoped>
.app-container {
  margin: 0;
  padding: 0;
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  width: 100%;
}
.content {
  padding: 2rem;
}
.navbar {
  left: 0;
  width: 100%;
  padding: 1rem;
  background: #9e1b32;
  display: flex;
  gap: 20px;
}
.navbar a {
  color: white;
  text-decoration: none;
}
.router-link-active {
  font-weight: bold;
  border-bottom: 2px solid white;
}
</style>

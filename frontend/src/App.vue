<script setup>
import HelloWorld from './components/HelloWorld.vue'
import Projects from './components/Projects.vue'
import Sidebar from './components/Sidebar.vue';
import Sponsors from './components/Sponsors.vue'
</script>

<template>
  <div class="app-container">
    <nav class="sidebar">
      <Sidebar />
    </nav>
    <div class="wrapper">
      <header class="header">
        <router-link to="/">Home</router-link>
      </header>
      <div class="content">
        <router-view />
      </div> 
    </div>
  </div>
</template>

<style scoped>
* {
  box-sizing: border-box;
}
.app-container {
  margin: 0;
  padding: 0;
  display: flex;
  flex-direction: row;
  min-height: 100vh;
  width: 100%;
}
.wrapper {
  margin-top: 0;
  margin-bottom: 0;
  margin-right: auto;
  margin-left: 240px;
  display: flex;
  flex-direction: column;
  width: calc(100% - 240px);
  z-index: 10;
  box-shadow: -4px 0 15px rgba(0, 0, 0, 0.4);

  height: 100vh;
  position: fixed;
  top: 0;
  right: 0;
  overflow-y: auto;
}
.sidebar {
  position: fixed;
  top: 0;
  left: 0;
  width: 240px;
}
.content {
  padding: 0rem 2rem 2rem 2rem;
  margin: 0 auto;
  width: 100%;
}
.header {
  /* left: 0; */
  width: 100%;
  /* position: fixed; */
  padding: 1rem;
  background: #ffffff;
  display: flex;
  gap: 20px;
  display: none;
}
.navbar a {
  color: white;
  text-decoration: none;
}
</style>
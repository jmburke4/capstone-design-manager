import { createRouter, createWebHistory } from 'vue-router';
import Projects from '../components/Projects.vue';
import Sponsors from '../components/Sponsors.vue';
import Homepage from '../components/Homepage.vue';

const routes = [
  { path: '/', name: 'Home', component: Homepage },
  { path: '/projects', name: 'Projects', component: Projects },
  { path: '/sponsors', name: 'Sponsors', component: Sponsors}
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;
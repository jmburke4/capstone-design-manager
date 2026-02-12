import { createRouter, createWebHistory } from 'vue-router';
import Projects from '../components/Projects.vue';
import Sponsors from '../components/Sponsors.vue';
import Homepage from '../components/Homepage.vue';
import Students from '../components/Students.vue';

const routes = [
  { path: '/', name: 'Home', component: Homepage },
  { path: '/projects', name: 'Projects', component: Projects },
  { path: '/sponsors', name: 'Sponsors', component: Sponsors },
  { path: '/students', name: 'Students', component: Students }
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;

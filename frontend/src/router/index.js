import { createRouter, createWebHistory } from 'vue-router';
import Projects from '../components/Projects.vue';
import Homepage from '../components/Homepage.vue';
import SponsorLanding from '../components/SponsorLanding.vue';
import AdminLanding from '../components/AdminLanding.vue';
import StudentLanding from '../components/StudentLanding.vue';
import ProjectDescription from '../components/ProjectDescription.vue';

const routes = [
  { path: '/', name: 'Home', component: Homepage },
  { path: '/projects', name: 'Projects', component: Projects },
  { path: '/sponsor', name: 'Sponsor', component: SponsorLanding},
  { path: '/admin', name: 'Admin', component: AdminLanding},
  { path: '/student', name: 'Student', component: StudentLanding},
  { path: '/projects/:id', name: 'ProjectDescription', component: ProjectDescription, props: true},
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;
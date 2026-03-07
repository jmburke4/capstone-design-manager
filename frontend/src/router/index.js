import { createRouter, createWebHistory } from 'vue-router';
import Projects from '../components/Projects.vue';
import Homepage from '../components/Homepage.vue';
import SponsorLanding from '../components/SponsorLanding.vue';
import AdminLanding from '../components/AdminLanding.vue';
import StudentLanding from '../components/StudentLanding.vue';
import ProjectDescription from '../components/ProjectDescription.vue';
import SponsorProjectForm from '../components/SponsorProjectForm.vue';
import StudentRankForm from '../components/StudentRankForm.vue';

const routes = [
  { path: '/', name: 'Home', component: Homepage },
  { path: '/sponsor', name: 'Sponsor', component: SponsorLanding},
  { path: '/admin', name: 'Admin', component: AdminLanding},
  { path: '/student', name: 'Student', component: StudentLanding},
  { path: '/student/projects', name: 'Projects', component: Projects },
  { path: '/student/submit', name: 'StudentSubmit', component: StudentRankForm},
  { path: '/projects/:id', name: 'ProjectDescription', component: ProjectDescription, props: true},
  { path: '/sponsor/submit', name: 'SponsorSubmit', component: SponsorProjectForm}
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;
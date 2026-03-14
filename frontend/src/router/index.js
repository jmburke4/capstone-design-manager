import { createRouter, createWebHistory } from 'vue-router';
import AdminLanding from '../components/AdminLanding.vue';
import EmailForm from '../components/EmailForm.vue';
import Homepage from '../components/Homepage.vue';
import ProjectDescription from '../components/ProjectDescription.vue';
import ProjectPresentation from '../components/ProjectPresentation.vue';
import Projects from '../components/Projects.vue';
import SponsorLanding from '../components/SponsorLanding.vue';
import SponsorOutreach from '../components/SponsorOutreach.vue';
import SponsorProjectForm from '../components/SponsorProjectForm.vue';
import StudentLanding from '../components/StudentLanding.vue';
import StudentRankForm from '../components/StudentRankForm.vue';

const routes = [
  { path: '/', name: 'Home', component: Homepage },
  { path: '/sponsor', name: 'Sponsor', component: SponsorLanding },
  { path: '/admin', name: 'Admin', component: AdminLanding },
  { path: '/student', name: 'Student', component: StudentLanding },
  { path: '/student/projects', name: 'Projects', component: Projects },
  { path: '/student/submit', name: 'StudentSubmit', component: StudentRankForm },
  { path: '/projects/:id', name: 'ProjectDescription', component: ProjectDescription, props: true },
  { path: '/email', name: 'Email', component: EmailForm },
  { path: '/sponsor-outreach', name: 'SponsorOutreach', component: SponsorOutreach },
  { path: '/project-presentation', name: 'ProjectPresentation', component: ProjectPresentation },
  { path: '/sponsor/submit', name: 'SponsorSubmit', component: SponsorProjectForm }
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;
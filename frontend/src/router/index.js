import { createRouter, createWebHistory } from 'vue-router';
import { auth0 } from '../main';
import Login from '../components/Login.vue';
import SponsorLanding from '../components/SponsorLanding.vue';
import StudentLanding from '../components/StudentLanding.vue';
import ProjectDescription from '../components/ProjectDescription.vue';
import SponsorProjectForm from '../components/SponsorProjectForm.vue';
import StudentRankForm from '../components/StudentRankForm.vue';
import ProfileCreate from '../components/ProfileCreate.vue';
import ProfileEdit from '../components/ProfileEdit.vue';
import apiService from '../services/api';
import StudentAssignment from '../components/StudentAssignment.vue';
import StudentProjectView from '../components/StudentProjectView.vue';

const ROLE_KEY = 'https://backend-api-capstone/roles';

function getUserRole(user) {
  if (!user) return null;
  const roles = user[ROLE_KEY];
  if (Array.isArray(roles) && roles.length > 0) {
    return roles[0].toLowerCase();
  }
  if (typeof roles === 'string') {
    return roles.toLowerCase();
  }
  return null;
}

function getDefaultRoute(user) {
  const role = getUserRole(user);
  if (role === 'student') return '/student';
  if (role === 'sponsor') return '/sponsor';
  return '/';
}

const routes = [
  { path: '/', name: 'Login', component: Login },
  { path: '/sponsor', name: 'Sponsor', component: SponsorLanding, meta: { roles: ['sponsor'], requiresProfile: true }},
  { path: '/student', name: 'Student', component: StudentLanding, meta: { roles: ['student'], requiresProfile: true }},
  { path: '/student/projects', name: 'StudentProjectView', component: StudentProjectView, meta: { roles: ['student'], requiresProfile: true }},
  { path: '/student/submit', name: 'StudentSubmit', component: StudentRankForm, meta: { roles: ['student'], requiresProfile: true }},
  { path: '/student/assignment', name: 'StudentAssignment', component: StudentAssignment, meta: { roles: ['student'], requiresProfile: true }},
  { path: '/projects/:id', name: 'ProjectDescription', component: ProjectDescription, props: true},
  { path: '/sponsor/submit', name: 'SponsorSubmit', component: SponsorProjectForm, meta: { roles: ['sponsor'], requiresProfile: true }},
  { path: '/profile/create', name: 'ProfileCreate', component: ProfileCreate },
  { path: '/profile/edit', name: 'ProfileEdit', component: ProfileEdit }
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

async function checkProfileAndRedirect(next) {
  const { user, getAccessTokenSilently } = auth0;
  
  try {
    const token = await getAccessTokenSilently();
    apiService.setToken(token);
    const profileResponse = await apiService.getProfile();
    
    if (!profileResponse.type) {
      next({ path: `/profile/create?role=${getUserRole(user.value)}` });
      return true;
    }
  } catch (err) {
    next({ path: `/profile/create?role=${getUserRole(user.value)}` });
    return true;
  }
  
  return false;
}

router.beforeEach(async (to, from, next) => {
  const { isAuthenticated, isLoading, user, loginWithRedirect } = auth0;

  // Handle login page
  if (to.path === '/' || to.name === 'Login') {
    if (isAuthenticated.value) {
      const userRole = getUserRole(user.value);
      
      if (!userRole) {
        next({ path: '/?error=no_role' });
        return;
      }
      
      const shouldRedirect = await checkProfileAndRedirect(next);
      if (shouldRedirect) return;
      
      next({ path: getDefaultRoute(user.value) });
      return;
    }
    
    next();
    return;
  }

  // Handle profile routes
  if (to.path === '/profile/create' || to.path === '/profile/edit') {
    if (!isAuthenticated.value) {
      next({ path: '/' });
      return;
    }
    next();
    return;
  }

  // Wait for auth to finish loading
  while (isLoading.value) {
    await new Promise(resolve => setTimeout(resolve, 100));
  }

  // Check authentication
  if (!isAuthenticated.value) {
    await loginWithRedirect({ appState: { target: to.fullPath } });
    return;
  }

  // Check role
  const userRole = getUserRole(user.value);
  
  if (!userRole) {
    next({ path: '/?error=no_role' });
    return;
  }

  // Check role permissions
  const requiredRoles = to.meta.roles;
  if (requiredRoles && requiredRoles.length > 0) {
    if (!requiredRoles.includes(userRole)) {
      next({ path: getDefaultRoute(user.value) });
      return;
    }
  }

  // Check profile for routes that require it
  if (to.meta.requiresProfile && isAuthenticated.value) {
    const shouldRedirect = await checkProfileAndRedirect(next);
    if (shouldRedirect) return;
  }

  next();
});

export default router;

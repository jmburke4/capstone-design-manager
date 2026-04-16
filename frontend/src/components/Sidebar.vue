<script setup>
import { computed, onMounted, ref } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { useAuth0 } from '@auth0/auth0-vue';
import apiService from '../services/api';
import { useStudentStore } from '../stores/studentStore';

const props = defineProps({
  userRole: { type: String, default: '' },
  userName: { type: String, default: '' }
});
const emit = defineEmits(['logout']);

const router = useRouter();
const route = useRoute();

const { getAccessTokenSilently } = useAuth0();
const studentStore = useStudentStore();
const hasRanked = ref(false);
const isDeadlinePast = false;
const isAssigned = false;
const isAdmin = ref(false);

onMounted(async () => {
  try {
    const token = await getAccessTokenSilently();
    apiService.setToken(token);

    // Check if user has admin role
    try {
      const adminCheck = await apiService.checkAdminAccess();
      isAdmin.value = adminCheck.isAdmin || false;
    } catch (e) {
      console.error('Sidebar: failed to check admin access', e);
      isAdmin.value = false;
    }

    // Student-specific checks
    if (props.userRole === 'student') {
      // profile endpoint returns { type, data } — normalize to the inner data
      const profileResp = await apiService.getProfile();
      const profile = profileResp?.data ?? profileResp;
      const studentId = profile?.id;

      if (!studentId) return;

      const prefsResp = await apiService.client.get('/preferences/');
      hasRanked.value = Array.isArray(prefsResp.data) && prefsResp.data.some(p => p.student === studentId);
    }
  } catch (e) {
    console.error('Sidebar: failed to initialize', e);
  }
});

const menuItems = computed(() => {
  const items = [];

  if (props.userRole === 'student') {
    items.push({ name: 'Dashboard', path: '/student' });
    items.push({ name: 'Project Gallery', path: '/student/projects' });

        if (!isDeadlinePast.value) {
            const rankLabel = studentStore.hasRanked ? 'Edit Rankings' : 'Submit Rankings';
      items.push({ name: rankLabel, path: '/student/submit' });
    }
        if (isDeadlinePast.value && studentStore.isAssigned) {
            items.push({ name: 'View Assignment', path: '/student/assignment' });
        }
  } else if (props.userRole === 'sponsor') {
    items.push({ name: 'Dashboard', path: '/sponsor' });
    items.push({ name: 'Submit Project', path: '/sponsor/submit' });
    items.push({ name: 'Edit Project', path: '/sponsor/edit' });
    items.push({ name: 'Submit Feedback', path: '/sponsor/feedback' });
  }

  return items;
});

const isActive = (path) => route.path === path;
const handleLogout = () => emit('logout');

const handleAdminClick = async () => {
  try {
    const token = await getAccessTokenSilently();
    apiService.setToken(token);
    
    // Create 5-minute authorization session
    await apiService.authorizeAdmin();
    
    // Navigate to admin panel
    window.location.href = '/admin/';
  } catch (error) {
    console.error('Admin authorization failed:', error);
    alert('Failed to access admin panel. Please ensure you have admin privileges.');
  }
};
</script>

<template>
    <aside class="sidebar">
        <div class="sidebar-header">
            <span class="header">Capstone Project Manager</span>
        </div>

        <nav class="nav-links">
            <div
                v-for="item in menuItems"
                :key="item.path"
                class="nav-item"
                :class="{ active: isActive(item.path) }"
                @click="router.push(item.path)"
            >
                <span class="nav-text">{{ item.name }}</span>
            </div>
        </nav>
        
        <div class="admin-section" v-if="isAdmin">
            <div
                class="nav-item"
                @click="handleAdminClick"
            >
                <span class="nav-text">Admin Panel</span>
            </div>
        </div>
        
        <div class="profile-section" v-if="userRole === 'sponsor'">
            <div
                class="nav-item"
                :class="{ active: isActive('/profile/edit') }"
                @click="router.push('/profile/edit')"
            >
                <span class="nav-text">Edit Profile</span>
            </div>
        </div>
        
        <footer class="user-info">
            <span>{{ userName || 'User' }}</span>
            <span class="logout-link" @click="handleLogout">Logout</span>
        </footer>
    </aside>
</template>

<style scoped>
.sidebar {
    height: 100%;
    background: var(--accent-primary);
    display: flex;
    flex-direction: column;
    padding: 1rem;
    box-shadow: none;
    color: white;
}
.sidebar-header {
    padding-bottom: 1rem;
}
.header {
    font-size: 1.5rem;
}
.nav-links {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
    flex: 1;
}

.admin-section {
    border-top: 1px solid rgba(255, 255, 255, 0.2);
    padding-top: 0.5rem;
    margin-top: 0.5rem;
}

.profile-section {
    border-top: 1px solid rgba(255, 255, 255, 0.2);
    padding-top: 0.5rem;
    margin-top: 0.5rem;
}

.nav-item {
    display: flex;
    align-items: center;
    padding: 1rem;
    cursor: pointer;
    font-weight: 400;
    transition: all 0.2s ease;
    border-radius: 16px;
}
.nav-item:hover, .nav-item.active {
    background: var(--accent-dark);
}
.user-info, .user-info span {
    font-weight: 400;
    font-size: 1rem;
    display: flex;
    justify-content: space-between;
    margin-top: auto;
}
.logout-link {
    cursor: pointer;
    text-decoration: underline;
}
.logout-link:hover {
    opacity: 0.8;
}
</style>

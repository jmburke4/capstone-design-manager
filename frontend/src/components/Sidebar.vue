<script setup>
import { computed } from 'vue';
import { useRouter, useRoute } from 'vue-router';

const props = defineProps({
    userRole: {
        type: String,
        default: ''
    },
    userName: {
        type: String,
        default: ''
    }
});

const emit = defineEmits(['logout']);

const router = useRouter();
const route = useRoute();

const hasRanked = false;
const isDeadlinePast = false;
const isAssigned = false;

const menuItems = computed(() => {
    const items = [];

    if (props.userRole === 'student') {
        items.push({ name: 'Dashboard', path: '/student' });
        items.push({ name: 'Project Gallery', path: '/student/projects' });

        if (!isDeadlinePast) {
            const rankLabel = hasRanked ? 'Edit Preferences' : 'Submit Rankings';
            items.push({ name: rankLabel, path: '/student/submit' });
        }
        if (isDeadlinePast && isAssigned) {
            items.push({ name: 'View Assignment', path: '/student/assignment' });
        }
    }
    else if (props.userRole === 'sponsor') {
        items.push({ name: 'Dashboard', path: '/sponsor' });
        items.push({ name: 'Submit Project', path: '/sponsor/submit' });
        items.push({ name: 'Submit Feedback', path: '/sponsor/feedback' });
    }

    return items;
});

const isActive = (path) => route.path === path;

const handleLogout = () => {
    emit('logout');
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
        
        <div class="profile-section">
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

<script setup>
import { computed } from 'vue';
import { useRouter, useRoute } from 'vue-router';

const router = useRouter();
const route = useRoute();

// const props = defineProps({
//     userRole: { type: String, required: true }// 'student' or 'sponsor',
//     // appStatus: { type: Object, required: true }
// });

// Hardcode state information for testing
const userRole = 'student';
const hasRanked = false;
const isDeadlinePast = false;
const isAssigned = false;

const menuItems = computed(() => {
    const items = [];

    // Student flow
    if (userRole === 'student') {
        items.push({ name: 'Dashboard', path: '/student', icon: '📊' });
        items.push({ name: 'Project Gallery', path: '/student/projects', icon: '🔍' });

        // State 1 - before deadline, show ranking
        if (!isDeadlinePast) {
            const rankLabel = hasRanked ? 'Edit Preferences' : 'Submit Rankings';
            items.push({ name: rankLabel, path: '/student/submit', icon: '🔢' });
        }
        // State 2 - after deadline, assignment made
        if (isDeadlinePast && isAssigned) {
            items.push({ name: 'View Assignment', path: '/student/assignment', icon: '🏆' });
        }
    }

    // Sponsor flow
    else if (userRole == 'sponsor') {
        items.push({ name: 'Dashboard', path: '/sponsor', icon: '📊' });
        items.push({ name: 'Submit Project', path: '/sponsor/submit', icon: '➕' });
        items.push({ name: 'Submit Feedback', path: '/sponsor/feedback', icon: '📝'});
    }

    return items;
});

/*
const menuItems = computed(() => {
    const items = [];

    // Student flow
    if (props.userRole === 'student') {
        items.push({ name: 'Dashboard', path: '/student', icon: '📊' });
        items.push({ name: 'Project Gallery', path: '/student/projects', icon: '🔍' });

        // State 1 - before deadline, show ranking
        if (!props.appStatus.isDeadlinePast) {
            const rankLabel = props.appStatus.hasRanked ? 'Edit Preferences' : 'Submit Rankings';
            items.push({ name: rankLabel, path: '/ranking', icon: '🔢' });
        }
        // State 2 - after deadline, assignment made
        if (props.appStatus.isDeadlinePast && props.appStatus.isAssigned) {
            items.push({ name: 'View Assignment', path: '/student/assignment', icon: '🏆' });
        }
    }

    // Sponsor flow
    else if (props.userRole == 'sponsor') {
        items.push({ name: 'Dashboard', path: '/sponsor', icon: '📊' });
        items.push({ name: 'Submit Project', path: '/sponsor/submit', icon: '➕' });
        items.push({ name: 'Submit Feedback', path: '/sponsor/feedback', icon: '📝'});
    }

    return items;
});
*/

const isActive = (path) => route.path === path;
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
                <!-- <span class="nav-icon">{{ item.icon }}</span> -->
                <span class="nav-text">{{ item.name }}</span>
            </div>
        </nav>
        <footer class="user-info">
            <span>First Last</span>
            <span style="text-decoration: underline;">Logout</span>
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
</style>
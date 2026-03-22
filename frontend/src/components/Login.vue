<script setup>
import { computed, onMounted, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useAuth0 } from '@auth0/auth0-vue';

const { loginWithRedirect, isLoading, isAuthenticated } = useAuth0();
const route = useRoute();
const router = useRouter();

const error = computed(() => route.query.error || null);

// Auto-redirect if already authenticated
onMounted(() => {
  setTimeout(() => {
    if (isAuthenticated.value && !isLoading.value) {
      router.push('/student');
    }
  }, 500);
});

// Also watch for auth state changes
watch(isAuthenticated, (newVal) => {
  if (newVal && !isLoading.value) {
    router.push('/student');
  }
});

const loginAsStudent = () => {
  loginWithRedirect({
    authorizationParams: {
      role: 'student'
    },
    appState: { target: '/student' }
  });
};

const loginAsSponsor = () => {
  loginWithRedirect({
    authorizationParams: {
      role: 'sponsor'
    },
    appState: { target: '/sponsor' }
  });
};
</script>

<template>
  <div class="login-container">
    <div class="login-card">
      <h1>Capstone Project Manager</h1>
      <p class="subtitle">Sign in to continue</p>
      
      <div v-if="error === 'no_role'" class="error-message">
        <strong>Authentication Error</strong>
        <p>No role found in your account. Please contact your administrator to be assigned a role (Student or Sponsor).</p>
      </div>
      
      <div v-if="isLoading" class="loading">Loading...</div>
      
      <div v-else class="login-buttons">
        <button @click="loginAsStudent" class="btn-student">
          I am a Student
        </button>
        <button @click="loginAsSponsor" class="btn-sponsor">
          I am a Sponsor
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>

.login-container {
  /* background-image: url(https://rolltide.com/images/2024/12/3/082723_ADMIN_ShelbyQuad_Campus_CLized.jpg); */
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: calc(100vh - 4rem);
  margin-top: 2rem;
  gap: 2rem;
  padding: 2rem;
}

.login-card {
  background: rgb(255, 255, 255);
  padding: 3rem;
  border-radius: 16px;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
  width: 100%;
  max-width: 500px;
  text-align: center;
}

h1 {
  font-size: 2.25rem;
  margin: 0 0 0.5rem 0;
  color: var(--text-default);
}

.subtitle {
  color: var(--text-subtle);
  margin: 0 0 2rem 0;
  font-size: 1rem;
}

.error-message {
  background: #fef2f2;
  border: 1px solid #fecaca;
  color: #991b1b;
  padding: 1rem;
  border-radius: 8px;
  margin-bottom: 1.5rem;
  text-align: left;
}

.error-message strong {
  display: block;
  margin-bottom: 0.5rem;
}

.error-message p {
  margin: 0;
  font-size: 0.9rem;
}

.login-buttons {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  width: 100%;
}

button {
  padding: 1rem 2rem;
  font-size: 1rem;
  font-weight: 600;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s ease;
}

button:hover {
  transform: scale(1.02);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.btn-student {
  background-color: var(--accent-primary);
  color: white;
}

.btn-student:hover {
  filter: brightness(.9);
}

.btn-sponsor {
  background-color: #757c88;
  color: white;
}

.btn-sponsor:hover {
  background-color: #5a5d66;
}

.loading {
  font-size: 1rem;
  color: var(--text-subtle);
}
</style>

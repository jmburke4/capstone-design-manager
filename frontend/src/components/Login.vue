<script setup>
import { computed, onMounted, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useAuth0 } from '@auth0/auth0-vue';

const { loginWithRedirect, isLoading, isAuthenticated, user } = useAuth0();
const route = useRoute();
const router = useRouter();

const error = computed(() => route.query.error || null);
const errorDescription = computed(() => route.query.error_description || null);

// Check if the error is specifically for unverified email
const isUnverifiedEmail = computed(() => {
  return error.value === 'access_denied' && 
         errorDescription.value?.toLowerCase().includes('unverified_email');
});

// Extract the email from the error description (e.g., "Please verify user@example.com before...")
const unverifiedEmailFromError = computed(() => {
  if (!errorDescription.value) return null;
  // Match email pattern in the error description
  const emailMatch = errorDescription.value.match(/[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/);
  return emailMatch ? emailMatch[0] : null;
});

// Get the user's email - prefer the one from error description, fallback to Auth0 user object
const userEmail = computed(() => {
  return unverifiedEmailFromError.value || user.value?.email || null;
});

// Clear the error and return to login view
const clearError = () => {
  router.replace({ path: '/', query: {} });
};

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

      <!-- Email Verification Required -->
      <div v-else-if="isUnverifiedEmail" class="verification-message">
        <div class="verification-icon">✉️</div>
        <h2>Verify Your Email</h2>
        <p>Please verify your email address before logging in.</p>
        <p v-if="userEmail" class="verification-email">
          <strong>Email:</strong> {{ userEmail }}
        </p>
        <p class="verification-hint">Check your inbox for a verification link. Don't forget to check your spam folder!</p>
        <button @click="clearError" class="btn-primary">
          Back to Login
        </button>
        <p class="verification-help">Once verified, click above to return to the login page.</p>
      </div>
      
      <div v-else-if="isLoading" class="loading">Loading...</div>
      
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

/* Email Verification Styles */
.verification-message {
  background: var(--background-info);
  border: 2px solid var(--accent-info);
  color: var(--text-info);
  padding: 2rem;
  border-radius: 12px;
  text-align: center;
  margin-bottom: 1.5rem;
}

.verification-icon {
  font-size: 3rem;
  margin-bottom: 1rem;
}

.verification-message h2 {
  font-size: 1.75rem;
  margin: 0 0 1rem 0;
  color: var(--text-info);
}

.verification-message p {
  font-size: 1rem;
  line-height: 1.6;
  margin: 0 0 1rem 0;
}

.verification-message .verification-hint {
  font-size: 0.9rem;
  color: var(--text-subtle);
  margin-bottom: 1.5rem;
}

.verification-message .verification-email {
  font-size: 1rem;
  color: var(--text-default);
  background: rgba(255, 255, 255, 0.5);
  padding: 0.75rem 1rem;
  border-radius: 8px;
  margin: 0 0 1rem 0;
  word-break: break-all;
}

.verification-message .verification-help {
  font-size: 0.8rem;
  color: var(--text-subtle);
  margin-top: 1rem;
  margin-bottom: 0;
}

.btn-primary {
  background-color: var(--accent-primary);
  color: white;
  padding: 0.75rem 2rem;
  font-size: 1rem;
  font-weight: 600;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.btn-primary:hover {
  filter: brightness(0.9);
  transform: scale(1.02);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}
</style>

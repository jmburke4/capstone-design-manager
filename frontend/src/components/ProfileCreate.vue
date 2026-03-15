<script setup>
import { ref, computed, onMounted } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { useAuth0 } from '@auth0/auth0-vue';
import apiService from '../services/api';
import ProfileForm from './ProfileForm.vue';

const router = useRouter();
const route = useRoute();
const { user, getAccessTokenSilently } = useAuth0();

const loading = ref(false);
const error = ref(null);
const profileType = ref(null);

const ROLE_KEY = 'https://backend-api-capstone/roles';

const role = computed(() => {
  // First try to get role from Auth0 token (more secure)
  if (user.value) {
    const roles = user.value[ROLE_KEY];
    if (Array.isArray(roles) && roles.length > 0) {
      return roles[0].toLowerCase();
    }
    if (typeof roles === 'string') {
      return roles.toLowerCase();
    }
  }
  // Fallback to URL query param
  const queryRole = route.query.role;
  if (queryRole) {
    return queryRole.toLowerCase();
  }
  // Default to student if no role found
  return 'student';
});

const handleSubmit = async (formData) => {
  loading.value = true;
  error.value = null;
  
  try {
    const token = await getAccessTokenSilently();
    apiService.setToken(token);
    
    await apiService.createProfile(formData);
    
    const redirectPath = role.value === 'sponsor' ? '/sponsor' : '/student';
    router.push(redirectPath);
  } catch (err) {
    const errorData = err.response?.data;
    error.value = errorData?.error || errorData?.message || JSON.stringify(errorData) || 'Failed to create profile. Please try again.';
  } finally {
    loading.value = false;
  }
};
</script>

<template>
  <div class="profile-create-container">
    <h1>Complete Your Profile</h1>
    <p class="subtitle">
      Please fill in your information to continue.
    </p>
    
    <div class="email-display">
      <strong>Email:</strong> {{ user?.email || 'Loading...' }}
    </div>
    
    <div v-if="error" class="error-message">
      {{ error }}
    </div>
    
    <div v-if="loading" class="loading">
      Creating profile...
    </div>
    
    <ProfileForm
      v-else
      :role="role"
      :initial-data="{}"
      :is-edit="false"
      @submit="handleSubmit"
    />
  </div>
</template>

<style scoped>
.profile-create-container {
  max-width: 800px;
  margin: 0 auto;
  padding: 2rem;
}

h1 {
  text-align: center;
  color: var(--accent-primary);
  margin-bottom: 0.5rem;
}

.subtitle {
  text-align: center;
  color: var(--text-subtle);
  margin-bottom: 1.5rem;
}

.email-display {
  background: #f3f4f6;
  padding: 1rem;
  border-radius: 8px;
  margin-bottom: 1.5rem;
  text-align: center;
  color: #374151;
}

.email-display strong {
  color: #111827;
  margin-right: 0.5rem;
}

.error-message {
  background: var(--background-negative);
  color: var(--text-negative);
  padding: 1rem;
  border-radius: 8px;
  margin-bottom: 1rem;
  text-align: center;
}

.loading {
  text-align: center;
  color: var(--text-subtle);
  padding: 2rem;
}
</style>

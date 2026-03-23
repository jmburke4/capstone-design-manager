<script setup>
import { ref, onMounted } from 'vue';
import axios from 'axios';
import { useRouter } from 'vue-router';
import StudentAssignmentCard from './StudentAssignmentCard.vue';

const router = useRouter();
const isAssigned = ref(false);

</script>

<template>
    <div class="assignment-wrapper">
        <h1>Assignment</h1>
        <div v-if="isAssigned">
            <StudentAssignmentCard />
        </div>
        <div v-else class="info error">
            <p>No assignment has been made.</p>
        </div>
    </div>
</template>

<style scoped>
.assignment-wrapper {
    max-width: var(--max-content-width);
}
</style>
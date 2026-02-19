<!-- Sponsor Landing Page -->
<!-- Roles:
        View project
        Submit project
        Submit feedback
        View assigned student contact info (?)
-->

<script setup>

</script>

<template>
    <h1>Sponsor Page</h1>
    <!-- TODO: assign proper router destinations for buttons -->
    <div class="wrapper">
        <router-link to="/sponsor">
            <button>View project</button>
        </router-link>
        <router-link to="/sponsor">
            <button>Submit project</button>
        </router-link>
        <router-link to="/sponsor">
            <button>Submit feedback</button>
        </router-link>
        <router-link to="/sponsor">
            <button>View assigned student contact information</button>
        </router-link>
    </div>
</template>

<style scoped>
.wrapper {
    display: flex;
    flex-direction: column;
    gap: 1rem;
}
button {
    width: 100%;
}
</style>
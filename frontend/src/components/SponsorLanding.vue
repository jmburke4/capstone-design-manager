<!-- Sponsor Landing Page -->
<!-- Roles:
        View project
        Submit project
        Submit feedback
        View assigned student contact info (?)
-->

<script setup>
    import ProjectTable from './ProjectTable.vue'
/*  <!-- Optional: filter table by current sponsor -->
    <!-- Uncomment and provide the current sponsor ID once available -->
    <!-- <ProjectTable:sponsor-id="currentSponsorId" /> -->*/
</script>

<template>
    <h1>Sponsor Page</h1>
    <div class="table-wrapper">
        <ProjectTable />
    </div>

    <!-- TODO: assign proper router destinations for buttons -->
    <div class="wrapper">
        <router-link to="/sponsor">
            <button>View project</button>
        </router-link>
        <router-link to="/sponsor/submit">
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
.table-wrapper {
  margin-bottom: 2rem; /* Adjust this value to increase/decrease space */
}
.wrapper {
    margin: 0 auto;
    max-width: var(--max-content-width);
    display: flex;
    flex-direction: column;
    gap: 1rem;
}
button {
    width: 100%;
}
</style>
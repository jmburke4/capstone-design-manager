<!-- Sponsor Landing Page -->
<!-- Roles:
        View project
        Submit project
        Submit feedback
        View assigned student contact info (?)
-->
<script setup>
    import ProjectTable from './ProjectTable.vue'
</script>

<template>
    <h1>Sponsor Page</h1>
    <div class="table-wrapper">
        <ProjectTable />
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
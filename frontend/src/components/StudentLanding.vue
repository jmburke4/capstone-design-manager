<!-- Student Landing Page -->
<!-- Roles:
        Submit project ranking
        View project descriptions
-->

<script setup>

</script>

<template>

<!-- TODO: implement logic for all cards -->
<div class="inside-wrapper">
    <h1>Student Page</h1>
    <div class="card">
        <h2>Countdown to Submission Deadline</h2>
        <span>14 days, 4 hours</span>
    </div>
    <div class="card">
        <h2>Top 5 Rankings</h2>
        <span>You don't have any rankings yet. <router-link class="redirect" to="/student/submit">Submit rankings now →</router-link></span>
    </div>
    <div class="card">
        <h2>Project Assignment</h2>
        <span>Due date has not passed yet.</span>
    </div>
</div>
</template>

<style scoped>
.redirect {
    color: var(--text-link)
}
.inside-wrapper {
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
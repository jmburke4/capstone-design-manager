<!-- Student Landing Page -->
<!-- Roles:
        Submit project ranking
        View project descriptions
-->

<script setup>

</script>

<template>
<h1>Student Page</h1>
<!-- TODO: assign proper router destinations for submit rankings button -->
<div class="wrapper">
    <router-link to="/student">
        <button>Submit project rankings</button>
    </router-link>
    <router-link to="/projects">
        <button>View project descriptions</button>
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
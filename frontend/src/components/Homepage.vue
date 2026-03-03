<script setup>

</script>

<template>
    <h1>Home</h1>
    <div class="wrapper">
        <router-link to="/admin">
            <button>Admin Page</button>
        </router-link>
        <router-link to="/student">
            <button>Student Page</button>
        </router-link>
        <router-link to="/sponsor">
            <button>Sponsor Page</button>
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
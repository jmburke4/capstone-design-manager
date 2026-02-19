<template>
  <div>
    <h1>Projects</h1>
    <h5 v-if="loading">Fetching data...</h5>
    <div v-if="error">Error: {{ error.message }}</div>
    <div ref="tableContainer"></div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue';
import axios from 'axios';
import { TabulatorFull as Tabulator } from 'tabulator-tables';
import 'tabulator-tables/dist/css/tabulator.min.css'; // Theme required for table to be visible, can use CSS overrides to adjust
import { useRouter } from 'vue-router';

const router = useRouter();
// 1. Define reactive state for data, loading, and errors
const posts = ref(null);
const loading = ref(true);
const error = ref(null);
const tableContainer = ref(null); // Reference to DOM element
let tabulator = null; // Hold Tabulator instance

// 2. Define the asynchronous fetching function
const fetchData = async () => {
  try {
    const response = await axios.get('http://localhost:8000/api/v1/projects/?format=json'); // Example API endpoint
    posts.value = response.data; // Axios automatically parses JSON into the .data property
  } catch (err) {
    error.value = err;
    console.error(err);
  } finally {
    loading.value = false;
  }
};

// 3. Call the fetch function when the component mounts
onMounted(() => {
  // Initialize Tabulator with no data
  tabulator = new Tabulator(tableContainer.value, {
    data: [], // Start empty
    layout: "fitColumns",
    responsiveLayout: "collapse",
    columns: [
      { title: "ID", field: "id", width: 50 },
      { title: "Name",
        field: "name",
        formatter: function(cell) {
            return `<span style="color: var(--crimson); text-decoration: underline; cursor: pointer;">${cell.getValue()}</span>`;
          },
        sorter: "string",
          cellClick: function (e, cell) {
            // get data from tabulator
            const proxyData = cell.getData();
            // strip proxy to make it a plain object
            const plainData = JSON.parse(JSON.stringify(proxyData));
            // navigate to description page
            router.push({
              name: 'ProjectDescription',
              params: { id: plainData.id },
              state: { project: plainData }
            });
          } },
      { title: "Description", field: "description", sorter: "string" },
      { title: "Sponsor", field: "sponsor" },
      { title: "Website", field: "website", sorter: "string" },
      { title: "Created", field: "created_at", sorter: "string" },
      { title: "Status", field: "status", sorter: "string" },
    ],
  });

  // Wait for table to be built, then fetch
  tabulator.on("tableBuilt", () => {
    fetchData();
  });
});

// Watch for data changes and update table automatically
watch(posts, (newData) => {
  if (tabulator) {
    tabulator.setData(newData);
  }
}, { deep: true });
</script>

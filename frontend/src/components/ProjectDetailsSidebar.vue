<script setup>
import { ref, onMounted, watch } from 'vue';
import { useAuth0 } from '@auth0/auth0-vue';
import apiService from '../services/api';

const props = defineProps({
  project: { type: Object, default: null },
  sponsorDisplay: { type: String, default: 'Unknown' }
});
defineEmits(['close']);

const { getAccessTokenSilently } = useAuth0();
const attachments = ref([]);
const loadingAttachments = ref(false);

async function loadAttachments() {
  if (!props.project?.id) {
    attachments.value = [];
    return;
  }
  
  loadingAttachments.value = true;
  try {
    const token = await getAccessTokenSilently();
    apiService.setToken(token);
    attachments.value = await apiService.getAttachments(props.project.id);
  } catch (err) {
    console.error('Failed to load attachments:', err);
    attachments.value = [];
  } finally {
    loadingAttachments.value = false;
  }
}

async function downloadAttachment(attachment) {
  try {
    const token = await getAccessTokenSilently();
    
    const response = await fetch(`/api/v1/attachments/${attachment.id}/download/`, {
      headers: {
        'Authorization': `Bearer ${token}`,
      },
    });
    
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }
    
    const blob = await response.blob();
    const url = window.URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = attachment.title || attachment.file?.split('/').pop() || 'download';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    window.URL.revokeObjectURL(url);
  } catch (err) {
    console.error('Download failed:', err);
    alert('Failed to download attachment.');
  }
}

function openLink(url) {
  window.open(url, '_blank');
}

onMounted(loadAttachments);
watch(() => props.project?.id, loadAttachments);
</script>

<template>
  <aside class="details-inner">
    <header class="sidebar-header">
      <button class="close-btn" @click="$emit('close')">✕</button>
      <div class="sponsor-brand">
        <h2>{{ sponsorDisplay }}</h2>
      </div>
      <hr />
    </header>

    <div class="sidebar-body">
      <!-- Hide status tag for now -->
      <!-- <span class="status-tag">{{ project.status }}</span> -->
      <h1 class="project-name">{{ project.name }}</h1>
      
      <section class="info-section">
        <h3>Description</h3>
        <p>{{ project.description }}</p>
      </section>

      <section class="info-section">
        <h3>Details</h3>
        <ul class="details-list">
          <li><strong>Website:</strong> <a :href="project.website" target="_blank">{{ project.website }}</a></li>
          <li><strong>Created:</strong> {{ project.created_at ? new Date(project.created_at).toLocaleDateString() : 'N/A' }}</li>
        </ul>
      </section>

      <section v-if="loadingAttachments" class="info-section">
        <h3>Attachments</h3>
        <p>Loading...</p>
      </section>

      <section v-else-if="attachments.length > 0" class="info-section">
        <h3>Attachments</h3>
        <div class="attachment-list">
          <div v-for="attachment in attachments" :key="attachment.id" class="attachment-item">
            <div class="attachment-info">
              <span class="attachment-title">{{ attachment.title || 'Untitled' }}</span>
              <span v-if="attachment.file" class="attachment-file">{{ attachment.file.split('/').pop() }}</span>
              <span v-if="attachment.link" class="attachment-link">{{ attachment.link }}</span>
            </div>
            <div class="attachment-actions">
              <button v-if="attachment.file" @click="downloadAttachment(attachment)" class="btn-download">
                Download
              </button>
              <button v-if="attachment.link" @click="openLink(attachment.link)" class="btn-link">
                Link
              </button>
            </div>
          </div>
        </div>
      </section>
    </div>
  </aside>
</template>

<style scoped>

.details-inner {
  display: flex;
  flex-direction: column;
  height: 100%; /* Fill the .details-pane parent */
  position: relative;
}

h2 {
    margin: 2rem 0 0 0 0;
    font-size: 1.25rem;
}

.sidebar-header {
  padding: 0;
}

.sidebar-body {
  flex: 1;
  overflow-y: auto;
  padding: 0 1.5rem 1rem;
}

.close-btn {
  position: absolute;
  top: 10px;
  right: 10px;
  background: transparent;
  border: none;
  cursor: pointer;
  font-size: 1.25rem;
  color: #666;
}

.close-btn:hover {
  color: #333;
}

h1 {
    margin: 0.5rem 0;
    font-size: 1.5rem;
    line-height: 1.25;
}

.info-section {
  margin-top: 1.5rem;
}

h3 {
  font-size: 0.9rem;
  font-weight: 600;
  margin: 0 0 0.5rem 0;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: #666;
}

.details-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.details-list li {
  padding: 0.25rem 0;
  font-size: 0.9rem;
}

.details-list a {
  color: #0066cc;
  text-decoration: none;
}

.details-list a:hover {
  text-decoration: underline;
}

.attachment-list {
  margin-top: 8px;
}

.attachment-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px;
  background: white;
  border: 1px solid #ddd;
  border-radius: 4px;
  margin-bottom: 6px;
}

.attachment-info {
  display: flex;
  flex-direction: column;
  flex: 1;
  min-width: 0;
}

.attachment-title {
  font-weight: bold;
  font-size: 0.85rem;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.attachment-file,
.attachment-link {
  font-size: 0.75rem;
  color: #666;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  display: block;
}

.attachment-actions {
  display: flex;
  gap: 4px;
  flex-shrink: 0;
  margin-left: 8px;
}

.btn-download,
.btn-link {
  padding: 4px 8px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.75rem;
  white-space: nowrap;
}

.btn-download {
  background: #007bff;
  color: white;
}

.btn-link {
  background: #28a745;
  color: white;
}
</style>
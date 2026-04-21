<script setup>
    import { computed, ref, onMounted } from 'vue';
    import { useRoute } from 'vue-router';
    import { useAuth0 } from '@auth0/auth0-vue';
    import apiService from '../services/api';

    const route = useRoute();
    const { getAccessTokenSilently } = useAuth0();

    const project = computed(() => window.history.state.project || {});
    const attachments = ref([]);
    const loadingAttachments = ref(false);

    const formatDate = (dateString) => {
        if (!dateString) return 'N/A';
        
        const date = new Date(dateString);
        
        return new Intl.DateTimeFormat('en-US', {
            year: 'numeric',
            month: 'long',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        }).format(date);
    };

    async function loadAttachments() {
        if (!project.value.id) return;
        
        loadingAttachments.value = true;
        try {
            const token = await getAccessTokenSilently();
            apiService.setToken(token);
            attachments.value = await apiService.getAttachments(project.value.id);
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
</script>

<template>
    <div v-if="project.id" class="description-wrapper">
        <h1> {{ project.name }}</h1>
        <p> Created on {{ formatDate(project.created_at) }}</p>
        <!-- TODO: Parse project.sponsor into a name, not the ID -->
        <p>Sponsor: {{ project.sponsor }}</p>
        <!-- TODO: Parse project.status into a readable string, not its shortened version -->
        <p>Status: {{ project.status }}</p>
        <p v-if="project.website">Website: <a :href="project.website" target="_blank" rel="noopener noreferrer">{{ project.website }}</a></p>
        <hr />
        <h2>Project Description</h2>
        <p> {{ project.description }}</p>
        
        <div v-if="loadingAttachments" class="loading">Loading attachments...</div>
        
        <div v-else-if="attachments.length > 0" class="attachments-section">
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
                            Open Link
                        </button>
                    </div>
                </div>
            </div>
        </div>
        
        <router-link to="/projects">Back to List</router-link>
    </div>
    <div v-else>
        <p>No project data found. <router-link to="/projects">Back to List</router-link></p>
    </div>
</template>

<style scoped>
.description-wrapper {
    text-align: left;
}

.attachments-section {
    margin-top: 20px;
    padding: 15px;
    background: #f9f9f9;
    border-radius: 8px;
}

.attachments-section h3 {
    margin-top: 0;
}

.attachment-list {
    margin-bottom: 10px;
}

.attachment-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 10px;
    background: white;
    border: 1px solid #ddd;
    border-radius: 4px;
    margin-bottom: 8px;
}

.attachment-info {
    display: flex;
    flex-direction: column;
}

.attachment-title {
    font-weight: bold;
}

.attachment-file,
.attachment-link {
    font-size: 0.85em;
    color: #666;
}

.attachment-actions {
    display: flex;
    gap: 8px;
}

.btn-download,
.btn-link {
    padding: 5px 10px;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-size: 0.85em;
}

.btn-download {
    background: #007bff;
    color: white;
}

.btn-link {
    background: #28a745;
    color: white;
}

.loading {
    padding: 10px;
    background: #e2e3e5;
    border-radius: 4px;
    margin-top: 10px;
}
</style>

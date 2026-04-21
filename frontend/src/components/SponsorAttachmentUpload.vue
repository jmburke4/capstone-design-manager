<script setup>
import { ref, onMounted, watch } from 'vue';
import { useAuth0 } from '@auth0/auth0-vue';
import apiService from '../services/api';

const props = defineProps({
  projectId: {
    type: Number,
    required: true
  }
});

const { getAccessTokenSilently } = useAuth0();
const attachments = ref([]);
const loading = ref(true);
const uploading = ref(false);
const error = ref(null);
const successMessage = ref(null);

const newAttachment = ref({
  title: '',
  file: null,
  link: ''
});
const uploadType = ref('file');

const ALLOWED_FILE_TYPES = ['application/pdf', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'application/vnd.openxmlformats-officedocument.presentationml.presentation', 'image/png', 'image/jpeg', 'application/zip'];
const MAX_FILE_SIZE = 25 * 1024 * 1024; // 25 MB

async function loadAttachments() {
  loading.value = true;
  error.value = null;
  try {
    const token = await getAccessTokenSilently();
    apiService.setToken(token);
    attachments.value = await apiService.getAttachments(props.projectId);
  } catch (err) {
    console.error('Failed to load attachments:', err);
    error.value = 'Failed to load attachments.';
  } finally {
    loading.value = false;
  }
}

function handleFileSelect(event) {
  const file = event.target.files[0];
  if (!file) return;
  
  if (!ALLOWED_FILE_TYPES.includes(file.type)) {
    error.value = 'Invalid file type. Allowed: PDF, DOCX, PPTX, PNG, JPG, ZIP';
    return;
  }
  
  if (file.size > MAX_FILE_SIZE) {
    error.value = 'File too large. Maximum size is 25 MB.';
    return;
  }
  
  newAttachment.value.file = file;
  error.value = null;
}

async function uploadAttachment() {
  if (uploadType.value === 'file' && !newAttachment.value.file) {
    error.value = 'Please select a file to upload.';
    return;
  }
  
  if (uploadType.value === 'link' && !newAttachment.value.link) {
    error.value = 'Please enter a URL.';
    return;
  }

  uploading.value = true;
  error.value = null;
  successMessage.value = null;

  try {
    const token = await getAccessTokenSilently();
    apiService.setToken(token);

    const formData = new FormData();
    formData.append('project', props.projectId);
    
    if (uploadType.value === 'file') {
      formData.append('file', newAttachment.value.file);
    } else {
      formData.append('link', newAttachment.value.link);
    }
    
    if (newAttachment.value.title) {
      formData.append('title', newAttachment.value.title);
    }

    await apiService.createAttachment(formData);
    
    successMessage.value = 'Attachment uploaded successfully!';
    newAttachment.value = { title: '', file: null, link: '' };
    document.getElementById('attachment-file-input').value = '';
    await loadAttachments();
    
    setTimeout(() => {
      successMessage.value = null;
    }, 3000);
  } catch (err) {
    console.error('Upload failed:', err);
    error.value = err.response?.data?.detail || 'Failed to upload attachment.';
  } finally {
    uploading.value = false;
  }
}

async function deleteAttachment(attachmentId) {
  if (!confirm('Are you sure you want to delete this attachment?')) {
    return;
  }
  
  try {
    const token = await getAccessTokenSilently();
    apiService.setToken(token);
    await apiService.deleteAttachment(attachmentId);
    await loadAttachments();
  } catch (err) {
    console.error('Delete failed:', err);
    error.value = 'Failed to delete attachment.';
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
    error.value = 'Failed to download attachment.';
  }
}

function openLink(url) {
  window.open(url, '_blank');
}

onMounted(loadAttachments);
watch(() => props.projectId, loadAttachments);
</script>

<template>
  <div class="attachment-upload">
    <h3>Attachments</h3>
    
    <div v-if="loading" class="loading">Loading attachments...</div>
    
    <div v-if="error" class="error-message">{{ error }}</div>
    <div v-if="successMessage" class="success-message">{{ successMessage }}</div>
    
    <div class="attachment-list">
      <div v-if="attachments.length === 0 && !loading" class="no-attachments">
        No attachments yet. Upload files or add links below.
      </div>
      
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
          <button @click="deleteAttachment(attachment.id)" class="btn-delete">
            Delete
          </button>
        </div>
      </div>
    </div>
    
    <div class="upload-form">
      <h4>Add New Attachment</h4>
      
      <div class="upload-type-toggle">
        <label>
          <input type="radio" v-model="uploadType" value="file" /> Upload File
        </label>
        <label>
          <input type="radio" v-model="uploadType" value="link" /> Add Link
        </label>
      </div>
      
      <div v-if="uploadType === 'file'" class="file-input">
        <input 
          type="file" 
          id="attachment-file-input"
          @change="handleFileSelect" 
          accept=".pdf,.docx,.pptx,.png,.jpg,.jpeg,.zip"
        />
        <p class="file-hint">Allowed: PDF, DOCX, PPTX, PNG, JPG, ZIP (max 25 MB)</p>
      </div>
      
      <div v-if="uploadType === 'link'" class="link-input">
        <input 
          type="url" 
          v-model="newAttachment.link" 
          placeholder="https://example.com/document.pdf"
        />
      </div>
      
      <div class="title-input">
        <input 
          type="text" 
          v-model="newAttachment.title" 
          placeholder="Title (optional)"
        />
      </div>
      
      <button @click="uploadAttachment" :disabled="uploading" class="btn-upload">
        {{ uploading ? 'Uploading...' : 'Upload Attachment' }}
      </button>
    </div>
  </div>
</template>

<style scoped>
.attachment-upload {
  margin-top: 20px;
  padding: 15px;
  background: #f9f9f9;
  border-radius: 8px;
}

.attachment-upload h3 {
  margin-top: 0;
}

.attachment-list {
  margin-bottom: 20px;
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
.btn-link,
.btn-delete {
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

.btn-delete {
  background: #dc3545;
  color: white;
}

.upload-form {
  border-top: 1px solid #ddd;
  padding-top: 15px;
}

.upload-type-toggle {
  margin-bottom: 10px;
}

.upload-type-toggle label {
  margin-right: 15px;
  cursor: pointer;
}

.file-input,
.link-input,
.title-input {
  margin-bottom: 10px;
}

.file-input input,
.link-input input,
.title-input input {
  width: 100%;
  padding: 8px;
  border: 1px solid #ddd;
  border-radius: 4px;
}

.file-hint {
  font-size: 0.8em;
  color: #666;
  margin: 5px 0 0 0;
}

.btn-upload {
  background: #007bff;
  color: white;
  padding: 10px 20px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.btn-upload:disabled {
  background: #ccc;
  cursor: not-allowed;
}

.loading,
.error-message,
.success-message,
.no-attachments {
  padding: 10px;
  margin-bottom: 10px;
  border-radius: 4px;
}

.error-message {
  background: #f8d7da;
  color: #721c24;
  border: 1px solid #f5c6cb;
}

.success-message {
  background: #d4edda;
  color: #155724;
  border: 1px solid #c3e6cb;
}

.loading {
  background: #e2e3e5;
}

.no-attachments {
  background: #e2e3e5;
  color: #383d41;
}
</style>

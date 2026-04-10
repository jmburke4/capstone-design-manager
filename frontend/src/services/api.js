import axios from 'axios';

const API_BASE_URL = '/api/v1';

class ApiService {
  constructor() {
    this.client = axios.create({
      baseURL: API_BASE_URL,
      headers: {
        'Content-Type': 'application/json',
      },
    });
  }

  setToken(token) {
    this.client.defaults.headers.common['Authorization'] = `Bearer ${token}`;
  }

  clearToken() {
    delete this.client.defaults.headers.common['Authorization'];
  }

  async getProfile() {
    const response = await this.client.get('/profile/');
    return response.data;
  }

  async createProfile(data) {
    const response = await this.client.post('/profile/', data);
    return response.data;
  }

  async updateProfile(data) {
    const response = await this.client.put('/profile/', data);
    return response.data;
  }

  async getProjectsBySponsor(sponsorId) {
    const response = await this.client.get(`/sponsors/${sponsorId}/projects/`);
    return response.data;
  }

  async createProject(data) {
    const response = await this.client.post('/projects/', data);
    return response.data;
  }

  async getCurrentSemester() {
    const response = await this.client.get('/semesters/');
    return response.data;
  }

  async createFeedback(data) {
    const response = await this.client.post('/feedback/', data);
    return response.data;
  }
}

export const apiService = new ApiService();
export default apiService;

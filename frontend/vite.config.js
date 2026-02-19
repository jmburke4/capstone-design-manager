import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// https://vite.dev/config/
export default defineConfig({
  plugins: [vue()],
  server: {
    host: true, // listen on all addresses (0.0.0.0) - needed for docker
    port: 5173,
    watch: {
      usePolling: true
    },
    proxy: {
      // forward any request starting with /api to the backend container
      '/api': {
        target: 'http://backend:8000',
        changeOrigin: true,
        secure: false,
      }
    }
  }
})

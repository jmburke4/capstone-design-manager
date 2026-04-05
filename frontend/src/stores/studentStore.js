import { defineStore } from 'pinia'
import apiService from '../services/api'

export const useStudentStore = defineStore('student', {
  state: () => ({
    profile: null,
    preferences: [],
    hasRanked: false,
    isAssigned: false,
    assignment: null,
    loading: false,
    error: null
  }),
  getters: {
    existingPrefProjectIds: (state) => state.preferences.map(pref => {
      const proj = pref.project && typeof pref.project === 'object' ? pref.project.id : pref.project
      return String(proj)
    })
    ,
    assignedProjectId: (state) => {
      if (!state.assignment) return null
      const proj = state.assignment.project
      return proj && typeof proj === 'object' ? String(proj.id) : String(proj)
    }
  },
  actions: {
    async fetchProfileAndPrefs() {
      this.loading = true
      this.error = null
      try {
        const profileResp = await apiService.getProfile()
        const profile = profileResp?.data ?? profileResp
        this.profile = profile
        const studentId = profile?.id
        if (!studentId) {
          this.preferences = []
          this.hasRanked = false
          this.isAssigned = false
          this.assignment = null
          return
        }

        const prefsResp = await apiService.client.get('/preferences/')
        const prefs = Array.isArray(prefsResp.data) ? prefsResp.data : []

        const studentPrefs = prefs.filter(pref => {
          let prefStudent = pref.student
          if (prefStudent && typeof prefStudent === 'object') prefStudent = prefStudent.id
          return String(prefStudent) === String(studentId)
        })

        this.preferences = studentPrefs
        this.hasRanked = studentPrefs.length > 0
        // Check assignment status (best-effort). We don't want assignment lookup to
        // fail the whole profile/prefs fetch, so handle errors locally.
        try {
          const assignmentsResp = await apiService.client.get('/assignments/')
          const assignments = Array.isArray(assignmentsResp.data) ? assignmentsResp.data : []
          const myAssignment = assignments.find(a => {
            let aStudent = a.student
            if (aStudent && typeof aStudent === 'object') aStudent = aStudent.id
            return String(aStudent) === String(studentId)
          })

          if (myAssignment) {
            this.assignment = myAssignment
            this.isAssigned = true
          } else {
            this.assignment = null
            this.isAssigned = false
          }
        } catch (assignErr) {
          console.warn('studentStore: failed to fetch assignments', assignErr)
          this.assignment = null
          this.isAssigned = false
        }
      } catch (e) {
        this.error = e
        console.error('studentStore.fetchProfileAndPrefs error', e)
        throw e
      } finally {
        this.loading = false
      }
    },
    setHasRanked(val = true) {
      this.hasRanked = val
    },
    setPreferences(prefs = []) {
      this.preferences = prefs
      this.hasRanked = prefs.length > 0
    },
    clear() {
      this.profile = null
      this.preferences = []
      this.hasRanked = false
      this.isAssigned = false
      this.assignment = null
      this.loading = false
      this.error = null
    }
  }
})

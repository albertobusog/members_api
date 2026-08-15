import { describe, expect, it, beforeEach } from 'vitest'
import { clearSession, readSession, writeSession, TOKEN_KEY, USER_KEY } from './session'

const user = { id: '1', email: 'a@example.com', role: 'client' as const }

describe('session storage', () => {
  beforeEach(() => window.localStorage.clear())

  it('returns an empty session when nothing is stored', () => {
    expect(readSession()).toEqual({ token: null, user: null })
  })

  it('persists token and user', () => {
    writeSession('jwt-token', user)

    expect(window.localStorage.getItem(TOKEN_KEY)).toBe('jwt-token')
    expect(JSON.parse(window.localStorage.getItem(USER_KEY) as string)).toEqual(user)
    expect(readSession()).toEqual({ token: 'jwt-token', user })
  })

  it('clears the session', () => {
    writeSession('jwt-token', user)
    clearSession()

    expect(readSession()).toEqual({ token: null, user: null })
  })

  it('ignores a corrupted stored user', () => {
    window.localStorage.setItem(TOKEN_KEY, 'jwt-token')
    window.localStorage.setItem(USER_KEY, 'not-json')

    expect(readSession()).toEqual({ token: null, user: null })
  })
})

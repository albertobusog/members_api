import type { User } from '../types'

export const TOKEN_KEY = 'members.token'
export const USER_KEY = 'members.user'

export interface Session {
  token: string | null
  user: User | null
}

export const EMPTY_SESSION: Session = { token: null, user: null }

export function readToken(): string | null {
  return window.localStorage.getItem(TOKEN_KEY)
}

export function readSession(): Session {
  const token = readToken()
  const rawUser = window.localStorage.getItem(USER_KEY)
  if (!token || !rawUser) return EMPTY_SESSION

  try {
    return { token, user: JSON.parse(rawUser) as User }
  } catch {
    return EMPTY_SESSION
  }
}

export function writeSession(token: string, user: User): void {
  window.localStorage.setItem(TOKEN_KEY, token)
  window.localStorage.setItem(USER_KEY, JSON.stringify(user))
}

export function clearSession(): void {
  window.localStorage.removeItem(TOKEN_KEY)
  window.localStorage.removeItem(USER_KEY)
}

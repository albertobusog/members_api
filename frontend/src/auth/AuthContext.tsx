import { createContext, useCallback, useContext, useMemo, useState } from 'react'
import type { ReactNode } from 'react'
import type { Role, User } from '../types'
import { clearSession, readSession, writeSession } from './session'

interface AuthContextValue {
  user: User | null
  token: string | null
  isAuthenticated: boolean
  hasRole: (role: Role) => boolean
  signIn: (token: string, user: User) => void
  signOut: () => void
}

const AuthContext = createContext<AuthContextValue | undefined>(undefined)

export function AuthProvider({ children }: { children: ReactNode }) {
  const [session, setSession] = useState(() => readSession())

  const signIn = useCallback((token: string, user: User) => {
    writeSession(token, user)
    setSession({ token, user })
  }, [])

  const signOut = useCallback(() => {
    clearSession()
    setSession({ token: null, user: null })
  }, [])

  const value = useMemo<AuthContextValue>(
    () => ({
      user: session.user,
      token: session.token,
      isAuthenticated: Boolean(session.token && session.user),
      hasRole: (role: Role) => session.user?.role === role,
      signIn,
      signOut,
    }),
    [session, signIn, signOut],
  )

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

export function useAuth(): AuthContextValue {
  const context = useContext(AuthContext)
  if (!context) throw new Error('useAuth must be used inside an AuthProvider')
  return context
}

export function homePathFor(user: User | null): string {
  if (!user) return '/signin'
  return user.role === 'admin' ? '/admin/cuponeras' : '/cliente/cuponeras'
}

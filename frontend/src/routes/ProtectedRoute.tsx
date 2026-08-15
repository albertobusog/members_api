import { Navigate, Outlet, useLocation } from 'react-router-dom'
import type { Role } from '../types'
import { homePathFor, useAuth } from '../auth/AuthContext'

export function ProtectedRoute({ role }: { role?: Role }) {
  const { isAuthenticated, user } = useAuth()
  const location = useLocation()

  if (!isAuthenticated) {
    return <Navigate to="/signin" replace state={{ from: location.pathname }} />
  }

  if (role && user?.role !== role) {
    return <Navigate to={homePathFor(user)} replace />
  }

  return <Outlet />
}

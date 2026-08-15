import type { ReactNode } from 'react'
import { NavLink, useNavigate } from 'react-router-dom'
import { useAuth } from '../auth/AuthContext'

export function AppLayout({ children }: { children: ReactNode }) {
  const { user, isAuthenticated, signOut } = useAuth()
  const navigate = useNavigate()

  function handleSignOut() {
    signOut()
    navigate('/signin', { replace: true })
  }

  return (
    <div className="app">
      <header className="app-header">
        <strong>Members</strong>

        <nav>
          {user?.role === 'client' && (
            <>
              <NavLink to="/cliente/cuponeras">Cuponeras disponibles</NavLink>
              <NavLink to="/cliente/mis-cuponeras">Mis cuponeras</NavLink>
            </>
          )}
          {user?.role === 'admin' && (
            <>
              <NavLink to="/admin/cuponeras">Cuponeras</NavLink>
              <NavLink to="/admin/adquisiciones">Clientes por cuponera</NavLink>
            </>
          )}
          {!isAuthenticated && (
            <>
              <NavLink to="/signin">Iniciar sesión</NavLink>
              <NavLink to="/signup">Crear cuenta</NavLink>
            </>
          )}
        </nav>

        {isAuthenticated && (
          <div className="session">
            <span>{user?.email}</span>
            <button type="button" onClick={handleSignOut}>
              Salir
            </button>
          </div>
        )}
      </header>

      <main>{children}</main>
    </div>
  )
}

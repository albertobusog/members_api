import { describe, expect, it } from 'vitest'
import { screen } from '@testing-library/react'
import { Route, Routes } from 'react-router-dom'
import { renderWithProviders, adminUser, clientUser } from '../test/utils'
import { ProtectedRoute } from './ProtectedRoute'

function routes() {
  return (
    <Routes>
      <Route path="/signin" element={<h1>Iniciar sesión</h1>} />
      <Route element={<ProtectedRoute role="client" />}>
        <Route path="/cliente" element={<h1>Zona cliente</h1>} />
      </Route>
      <Route element={<ProtectedRoute role="admin" />}>
        <Route path="/admin" element={<h1>Zona admin</h1>} />
      </Route>
    </Routes>
  )
}

describe('ProtectedRoute', () => {
  it('redirects anonymous visitors to the sign in page', () => {
    renderWithProviders(routes(), { route: '/cliente' })

    expect(screen.getByRole('heading', { name: /iniciar sesión/i })).toBeInTheDocument()
  })

  it('renders the route when the role matches', () => {
    renderWithProviders(routes(), { route: '/cliente', session: { token: 't', user: clientUser } })

    expect(screen.getByRole('heading', { name: /zona cliente/i })).toBeInTheDocument()
  })

  it('sends a client away from admin routes', () => {
    renderWithProviders(routes(), { route: '/admin', session: { token: 't', user: clientUser } })

    expect(screen.queryByRole('heading', { name: /zona admin/i })).not.toBeInTheDocument()
  })

  it('renders admin routes for admins', () => {
    renderWithProviders(routes(), { route: '/admin', session: { token: 't', user: adminUser } })

    expect(screen.getByRole('heading', { name: /zona admin/i })).toBeInTheDocument()
  })
})

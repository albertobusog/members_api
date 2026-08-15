import { describe, expect, it } from 'vitest'
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { MemoryRouter } from 'react-router-dom'
import { AuthProvider, useAuth } from './AuthContext'
import { readSession, writeSession } from './session'
import { clientUser } from '../test/utils'

function Probe() {
  const { user, signIn, signOut } = useAuth()

  return (
    <div>
      <span data-testid="user">{user ? `${user.email} (${user.role})` : 'anonymous'}</span>
      <button onClick={() => signIn('t0k3n', clientUser)}>entrar</button>
      <button onClick={signOut}>salir</button>
    </div>
  )
}

function renderProbe() {
  return render(
    <MemoryRouter>
      <AuthProvider>
        <Probe />
      </AuthProvider>
    </MemoryRouter>,
  )
}

describe('AuthProvider', () => {
  it('starts anonymous', () => {
    renderProbe()

    expect(screen.getByTestId('user')).toHaveTextContent('anonymous')
  })

  it('restores the session stored in localStorage', () => {
    writeSession('stored-token', clientUser)

    renderProbe()

    expect(screen.getByTestId('user')).toHaveTextContent('client@example.com (client)')
  })

  it('stores the session on sign in and clears it on sign out', async () => {
    const user = userEvent.setup()
    renderProbe()

    await user.click(screen.getByRole('button', { name: 'entrar' }))
    expect(screen.getByTestId('user')).toHaveTextContent('client@example.com')
    expect(readSession().token).toBe('t0k3n')

    await user.click(screen.getByRole('button', { name: 'salir' }))
    expect(screen.getByTestId('user')).toHaveTextContent('anonymous')
    expect(readSession().token).toBeNull()
  })
})

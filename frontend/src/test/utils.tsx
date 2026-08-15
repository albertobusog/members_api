import type { ReactElement, ReactNode } from 'react'
import { render } from '@testing-library/react'
import type { RenderOptions } from '@testing-library/react'
import { MemoryRouter } from 'react-router-dom'
import { MockedProvider } from '@apollo/client/testing/react'
import type { MockedResponse } from '@apollo/client/testing'
import { AuthProvider } from '../auth/AuthContext'
import type { User } from '../types'
import { writeSession } from '../auth/session'

interface Options extends Omit<RenderOptions, 'wrapper'> {
  mocks?: readonly MockedResponse[]
  route?: string
  session?: { token: string; user: User }
}

export function renderWithProviders(ui: ReactElement, options: Options = {}) {
  const { mocks = [], route = '/', session } = options

  if (session) writeSession(session.token, session.user)

  function Wrapper({ children }: { children: ReactNode }) {
    return (
      <MockedProvider mocks={mocks}>
        <MemoryRouter initialEntries={[route]}>
          <AuthProvider>{children}</AuthProvider>
        </MemoryRouter>
      </MockedProvider>
    )
  }

  return render(ui, { wrapper: Wrapper, ...options })
}

export const clientUser: User = { id: '1', email: 'client@example.com', role: 'client' }
export const adminUser: User = { id: '2', email: 'admin@example.com', role: 'admin' }

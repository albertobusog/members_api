import { describe, expect, it } from 'vitest'
import { screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import type { MockedResponse } from '@apollo/client/testing'
import { SIGN_IN } from '../graphql/operations'
import { readSession } from '../auth/session'
import { renderWithProviders } from '../test/utils'
import { SignInPage } from './SignInPage'

const variables = { email: 'client@example.com', password: 'password123' }

const successMock: MockedResponse = {
  request: { query: SIGN_IN, variables },
  result: {
    data: {
      signIn: {
        __typename: 'SignInPayload',
        token: 'jwt-token',
        user: { __typename: 'User', id: '1', email: 'client@example.com', role: 'client' },
        errors: [],
      },
    },
  },
}

const failureMock: MockedResponse = {
  request: { query: SIGN_IN, variables },
  result: {
    data: {
      signIn: {
        __typename: 'SignInPayload',
        token: null,
        user: null,
        errors: ['Invalid credentials'],
      },
    },
  },
}

async function fillAndSubmit() {
  const user = userEvent.setup()
  await user.type(screen.getByLabelText(/email/i), variables.email)
  await user.type(screen.getByLabelText(/contraseña/i), variables.password)
  await user.click(screen.getByRole('button', { name: /iniciar sesión/i }))
}

describe('SignInPage', () => {
  it('renders the sign in form', () => {
    renderWithProviders(<SignInPage />)

    expect(screen.getByRole('heading', { name: /iniciar sesión/i })).toBeInTheDocument()
    expect(screen.getByLabelText(/email/i)).toBeInTheDocument()
    expect(screen.getByLabelText(/contraseña/i)).toBeInTheDocument()
  })

  it('stores the token returned by the API', async () => {
    renderWithProviders(<SignInPage />, { mocks: [successMock] })

    await fillAndSubmit()

    await waitFor(() => expect(readSession().token).toBe('jwt-token'))
    expect(readSession().user).toMatchObject({ email: 'client@example.com', role: 'client' })
  })

  it('shows the business error returned by the API', async () => {
    renderWithProviders(<SignInPage />, { mocks: [failureMock] })

    await fillAndSubmit()

    expect(await screen.findByRole('alert')).toHaveTextContent('Invalid credentials')
    expect(readSession().token).toBeNull()
  })
})

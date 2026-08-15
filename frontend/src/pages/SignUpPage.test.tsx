import { describe, expect, it } from 'vitest'
import { screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import type { MockedResponse } from '@apollo/client/testing'
import { SIGN_UP } from '../graphql/operations'
import { readSession } from '../auth/session'
import { renderWithProviders } from '../test/utils'
import { SignUpPage } from './SignUpPage'

const variables = { email: 'new@example.com', password: 'password123', role: 'client' }

const successMock: MockedResponse = {
  request: { query: SIGN_UP, variables },
  result: {
    data: {
      signUp: {
        __typename: 'SignUpPayload',
        token: 'new-token',
        user: { __typename: 'User', id: '9', email: 'new@example.com', role: 'client' },
        errors: null,
      },
    },
  },
}

const failureMock: MockedResponse = {
  request: { query: SIGN_UP, variables },
  result: {
    data: {
      signUp: {
        __typename: 'SignUpPayload',
        token: null,
        user: null,
        errors: ['Email has already been taken'],
      },
    },
  },
}

async function fillAndSubmit() {
  const user = userEvent.setup()
  await user.type(screen.getByLabelText(/email/i), variables.email)
  await user.type(screen.getByLabelText(/contraseña/i), variables.password)
  await user.click(screen.getByRole('button', { name: /crear cuenta/i }))
}

describe('SignUpPage', () => {
  it('registers a client and stores the session', async () => {
    renderWithProviders(<SignUpPage />, { mocks: [successMock] })

    await fillAndSubmit()

    await waitFor(() => expect(readSession().token).toBe('new-token'))
  })

  it('shows validation errors from the API', async () => {
    renderWithProviders(<SignUpPage />, { mocks: [failureMock] })

    await fillAndSubmit()

    expect(await screen.findByRole('alert')).toHaveTextContent('Email has already been taken')
  })
})

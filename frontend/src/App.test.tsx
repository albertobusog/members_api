import { describe, expect, it } from 'vitest'
import { screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import type { MockedResponse } from '@apollo/client/testing'
import { ALL_PASSES, AVAILABLE_PASSES } from './graphql/operations'
import { renderWithProviders, adminUser, clientUser } from './test/utils'
import { App } from './App'

const availablePassesMock: MockedResponse = {
  request: { query: AVAILABLE_PASSES, variables: {} },
  result: { data: { availablePasses: [] } },
}

const allPassesMock: MockedResponse = {
  request: { query: ALL_PASSES, variables: {} },
  result: { data: { allPasses: [] } },
}

describe('App', () => {
  it('shows the sign in page to anonymous visitors', async () => {
    renderWithProviders(<App />, { route: '/' })

    expect(await screen.findByRole('heading', { name: /iniciar sesión/i })).toBeInTheDocument()
  })

  it('lands a client on the available passes page', async () => {
    renderWithProviders(<App />, {
      route: '/',
      mocks: [availablePassesMock],
      session: { token: 'jwt', user: clientUser },
    })

    expect(await screen.findByRole('heading', { name: /cuponeras disponibles/i })).toBeInTheDocument()
  })

  it('lands an admin on the passes administration page', async () => {
    renderWithProviders(<App />, {
      route: '/',
      mocks: [allPassesMock],
      session: { token: 'jwt', user: adminUser },
    })

    expect(await screen.findByRole('heading', { name: /^cuponeras$/i })).toBeInTheDocument()
  })

  it('keeps clients out of the admin area', async () => {
    renderWithProviders(<App />, {
      route: '/admin/cuponeras',
      mocks: [availablePassesMock],
      session: { token: 'jwt', user: clientUser },
    })

    expect(await screen.findByRole('heading', { name: /cuponeras disponibles/i })).toBeInTheDocument()
  })

  it('signs the user out', async () => {
    const user = userEvent.setup()
    renderWithProviders(<App />, {
      route: '/',
      mocks: [availablePassesMock],
      session: { token: 'jwt', user: clientUser },
    })

    await screen.findByRole('heading', { name: /cuponeras disponibles/i })
    await user.click(screen.getByRole('button', { name: /salir/i }))

    expect(await screen.findByRole('heading', { name: /iniciar sesión/i })).toBeInTheDocument()
  })
})

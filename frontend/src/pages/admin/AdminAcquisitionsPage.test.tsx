import { describe, expect, it } from 'vitest'
import { screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import type { MockedResponse } from '@apollo/client/testing'
import { ADMIN_PASS_ACQUISITIONS } from '../../graphql/operations'
import { renderWithProviders, adminUser } from '../../test/utils'
import { AdminAcquisitionsPage } from './AdminAcquisitionsPage'

const yoga = {
  __typename: 'Pass',
  id: '1',
  name: 'Yoga 10 visitas',
  visits: 10,
  price: 100,
  purchases: [
    {
      __typename: 'Purchase',
      id: '77',
      remainingVisits: 4,
      validUntil: '2026-09-30',
      purchaseDate: '2026-08-01',
      user: { __typename: 'User', id: '5', email: 'ana@example.com' },
    },
  ],
}

const crossfit = {
  __typename: 'Pass',
  id: '2',
  name: 'Crossfit 5 visitas',
  visits: 5,
  price: 250,
  purchases: [],
}

const acquisitionsMock = (
  adminPassAcquisitions: unknown[],
  variables: Record<string, unknown> = {},
): MockedResponse => ({
  request: { query: ADMIN_PASS_ACQUISITIONS, variables },
  result: { data: { adminPassAcquisitions } },
})

const session = { token: 'jwt', user: adminUser }

describe('AdminAcquisitionsPage', () => {
  it('shows the clients of each pass with their usage state', async () => {
    renderWithProviders(<AdminAcquisitionsPage />, {
      mocks: [acquisitionsMock([yoga, crossfit])],
      session,
    })

    expect(await screen.findByText('Yoga 10 visitas')).toBeInTheDocument()
    expect(screen.getByText('ana@example.com')).toBeInTheDocument()
    expect(screen.getByText(/4 visitas restantes/i)).toBeInTheDocument()
    expect(screen.getByText(/sin clientes/i)).toBeInTheDocument()
  })

  it('filters by pass', async () => {
    const user = userEvent.setup()
    renderWithProviders(<AdminAcquisitionsPage />, {
      mocks: [acquisitionsMock([yoga, crossfit]), acquisitionsMock([yoga], { passId: '1' })],
      session,
    })

    await screen.findByText('Crossfit 5 visitas')
    await user.type(screen.getByLabelText(/id de cuponera/i), '1')
    await user.click(screen.getByRole('button', { name: /filtrar/i }))

    expect(await screen.findByText('Yoga 10 visitas')).toBeInTheDocument()
    expect(screen.queryByText('Crossfit 5 visitas')).not.toBeInTheDocument()
  })

  it('reports authorization errors coming from the API', async () => {
    const errorMock: MockedResponse = {
      request: { query: ADMIN_PASS_ACQUISITIONS, variables: {} },
      result: { errors: [{ message: 'Not authorized' }] },
    }

    renderWithProviders(<AdminAcquisitionsPage />, { mocks: [errorMock], session })

    expect(await screen.findByRole('alert')).toHaveTextContent('Not authorized')
  })
})

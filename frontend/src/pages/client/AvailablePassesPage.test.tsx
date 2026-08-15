import { describe, expect, it } from 'vitest'
import { screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import type { MockedResponse } from '@apollo/client/testing'
import { ACQUIRE_PASS, AVAILABLE_PASSES } from '../../graphql/operations'
import { renderWithProviders, clientUser } from '../../test/utils'
import { AvailablePassesPage } from './AvailablePassesPage'

const yoga = {
  __typename: 'Pass',
  id: '1',
  name: 'Yoga 10 visitas',
  visits: 10,
  price: 100.0,
  expiresAt: '2026-12-31',
}

const crossfit = {
  __typename: 'Pass',
  id: '2',
  name: 'Crossfit 5 visitas',
  visits: 5,
  price: 250.0,
  expiresAt: '2026-10-31',
}

const listMock = (passes: unknown[], variables: Record<string, unknown> = {}): MockedResponse => ({
  request: { query: AVAILABLE_PASSES, variables },
  result: { data: { availablePasses: passes } },
})

const session = { token: 'jwt', user: clientUser }

describe('AvailablePassesPage', () => {
  it('lists the passes the client can buy', async () => {
    renderWithProviders(<AvailablePassesPage />, { mocks: [listMock([yoga, crossfit])], session })

    expect(await screen.findByText('Yoga 10 visitas')).toBeInTheDocument()
    expect(screen.getByText('Crossfit 5 visitas')).toBeInTheDocument()
  })

  it('shows an empty state', async () => {
    renderWithProviders(<AvailablePassesPage />, { mocks: [listMock([])], session })

    expect(await screen.findByText(/no hay cuponeras disponibles/i)).toBeInTheDocument()
  })

  it('filters by name and price', async () => {
    const user = userEvent.setup()
    renderWithProviders(<AvailablePassesPage />, {
      mocks: [
        listMock([yoga, crossfit]),
        listMock([yoga], { nameContains: 'yoga', minPrice: 50, maxPrice: 150 }),
      ],
      session,
    })

    await screen.findByText('Crossfit 5 visitas')

    await user.type(screen.getByLabelText(/nombre/i), 'yoga')
    await user.type(screen.getByLabelText(/precio mínimo/i), '50')
    await user.type(screen.getByLabelText(/precio máximo/i), '150')
    await user.click(screen.getByRole('button', { name: /filtrar/i }))

    await waitFor(() => expect(screen.queryByText('Crossfit 5 visitas')).not.toBeInTheDocument())
    expect(await screen.findByText('Yoga 10 visitas')).toBeInTheDocument()
  })

  it('acquires a pass and confirms it', async () => {
    const user = userEvent.setup()
    const acquireMock: MockedResponse = {
      request: { query: ACQUIRE_PASS, variables: { passId: '1' } },
      result: {
        data: {
          acquirePass: {
            __typename: 'AcquirePassPayload',
            purchase: {
              __typename: 'Purchase',
              id: '77',
              remainingVisits: 10,
              validUntil: '2026-09-30',
              purchaseDate: '2026-08-31',
              price: 100.0,
              pass: { __typename: 'Pass', id: '1', name: 'Yoga 10 visitas' },
            },
            errors: null,
          },
        },
      },
    }

    renderWithProviders(<AvailablePassesPage />, {
      mocks: [listMock([yoga]), acquireMock, listMock([])],
      session,
    })

    const row = await screen.findByRole('listitem')
    await user.click(within(row).getByRole('button', { name: /adquirir/i }))

    expect(await screen.findByRole('status')).toHaveTextContent(/adquirida/i)
  })

  it('shows business errors when the pass cannot be acquired', async () => {
    const user = userEvent.setup()
    const acquireMock: MockedResponse = {
      request: { query: ACQUIRE_PASS, variables: { passId: '1' } },
      result: {
        data: {
          acquirePass: {
            __typename: 'AcquirePassPayload',
            purchase: null,
            errors: ['Pass already acquired'],
          },
        },
      },
    }

    renderWithProviders(<AvailablePassesPage />, {
      mocks: [listMock([yoga]), acquireMock],
      session,
    })

    const row = await screen.findByRole('listitem')
    await user.click(within(row).getByRole('button', { name: /adquirir/i }))

    expect(await screen.findByRole('alert')).toHaveTextContent('Pass already acquired')
  })
})

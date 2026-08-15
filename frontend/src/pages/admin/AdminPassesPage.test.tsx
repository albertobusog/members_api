import { describe, expect, it } from 'vitest'
import { screen, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import type { MockedResponse } from '@apollo/client/testing'
import { ALL_PASSES, CREATE_PASS, DELETE_PASS, UPDATE_PASS } from '../../graphql/operations'
import { renderWithProviders, adminUser } from '../../test/utils'
import { AdminPassesPage } from './AdminPassesPage'

const yoga = {
  __typename: 'Pass',
  id: '1',
  name: 'Yoga 10 visitas',
  visits: 10,
  price: 100,
  expiresAt: '2026-12-31',
}

const allPassesMock = (allPasses: unknown[]): MockedResponse => ({
  request: { query: ALL_PASSES, variables: {} },
  result: { data: { allPasses } },
})

const session = { token: 'jwt', user: adminUser }

describe('AdminPassesPage', () => {
  it('lists every pass', async () => {
    renderWithProviders(<AdminPassesPage />, { mocks: [allPassesMock([yoga])], session })

    expect(await screen.findByText('Yoga 10 visitas')).toBeInTheDocument()
    expect(screen.getByText(/^10 visitas$/i)).toBeInTheDocument()
  })

  it('creates a pass', async () => {
    const user = userEvent.setup()
    const created = {
      __typename: 'Pass',
      id: '2',
      name: 'Pilates',
      visits: 5,
      price: 300,
      expiresAt: '2026-11-30',
    }
    const createMock: MockedResponse = {
      request: {
        query: CREATE_PASS,
        variables: { name: 'Pilates', visits: 5, price: 300, expiresAt: '2026-11-30' },
      },
      result: { data: { createPass: { __typename: 'CreatePassPayload', pass: created, errors: null } } },
    }

    renderWithProviders(<AdminPassesPage />, {
      mocks: [allPassesMock([yoga]), createMock, allPassesMock([yoga, created])],
      session,
    })

    await screen.findByText('Yoga 10 visitas')
    const form = screen.getByRole('form', { name: /nueva cuponera/i })
    await user.type(within(form).getByLabelText(/nombre/i), 'Pilates')
    await user.type(within(form).getByLabelText(/visitas/i), '5')
    await user.type(within(form).getByLabelText(/precio/i), '300')
    await user.type(within(form).getByLabelText(/vence/i), '2026-11-30')
    await user.click(within(form).getByRole('button', { name: /crear/i }))

    expect(await screen.findByText('Pilates')).toBeInTheDocument()
  })

  it('shows validation errors when creating a pass fails', async () => {
    const user = userEvent.setup()
    const createMock: MockedResponse = {
      request: {
        query: CREATE_PASS,
        variables: { name: 'Pilates', visits: 5, price: 300, expiresAt: '2026-11-30' },
      },
      result: {
        data: { createPass: { __typename: 'CreatePassPayload', pass: null, errors: ['Not authorized'] } },
      },
    }

    renderWithProviders(<AdminPassesPage />, { mocks: [allPassesMock([]), createMock], session })

    const form = await screen.findByRole('form', { name: /nueva cuponera/i })
    await user.type(within(form).getByLabelText(/nombre/i), 'Pilates')
    await user.type(within(form).getByLabelText(/visitas/i), '5')
    await user.type(within(form).getByLabelText(/precio/i), '300')
    await user.type(within(form).getByLabelText(/vence/i), '2026-11-30')
    await user.click(within(form).getByRole('button', { name: /crear/i }))

    expect(await screen.findByRole('alert')).toHaveTextContent('Not authorized')
  })

  it('updates a pass', async () => {
    const user = userEvent.setup()
    const updated = { ...yoga, name: 'Yoga renovada' }
    const updateMock: MockedResponse = {
      request: {
        query: UPDATE_PASS,
        variables: { id: '1', name: 'Yoga renovada', visits: 10, price: 100, expiresAt: '2026-12-31' },
      },
      result: { data: { updatePass: { __typename: 'UpdatePassPayload', pass: updated, errors: null } } },
    }

    renderWithProviders(<AdminPassesPage />, {
      mocks: [allPassesMock([yoga]), updateMock, allPassesMock([updated])],
      session,
    })

    await screen.findByText('Yoga 10 visitas')
    await user.click(screen.getByRole('button', { name: /editar/i }))

    const form = screen.getByRole('form', { name: /editar cuponera/i })
    const nameInput = within(form).getByLabelText(/nombre/i)
    await user.clear(nameInput)
    await user.type(nameInput, 'Yoga renovada')
    await user.click(within(form).getByRole('button', { name: /guardar/i }))

    expect(await screen.findByText('Yoga renovada')).toBeInTheDocument()
  })

  it('surfaces the pending visits error when updating', async () => {
    const user = userEvent.setup()
    const updateMock: MockedResponse = {
      request: {
        query: UPDATE_PASS,
        variables: { id: '1', name: 'Yoga 10 visitas', visits: 10, price: 100, expiresAt: '2026-12-31' },
      },
      result: {
        data: {
          updatePass: {
            __typename: 'UpdatePassPayload',
            pass: null,
            errors: ['Cannot edit pass with clients having pending visits'],
          },
        },
      },
    }

    renderWithProviders(<AdminPassesPage />, { mocks: [allPassesMock([yoga]), updateMock], session })

    await screen.findByText('Yoga 10 visitas')
    await user.click(screen.getByRole('button', { name: /editar/i }))
    await user.click(screen.getByRole('button', { name: /guardar/i }))

    expect(await screen.findByRole('alert')).toHaveTextContent(
      'Cannot edit pass with clients having pending visits',
    )
  })

  it('deletes a pass', async () => {
    const user = userEvent.setup()
    const deleteMock: MockedResponse = {
      request: { query: DELETE_PASS, variables: { id: '1' } },
      result: { data: { deletePass: { __typename: 'DeletePassPayload', success: true, errors: null } } },
    }

    renderWithProviders(<AdminPassesPage />, {
      mocks: [allPassesMock([yoga]), deleteMock, allPassesMock([])],
      session,
    })

    await screen.findByText('Yoga 10 visitas')
    await user.click(screen.getByRole('button', { name: /eliminar/i }))

    expect(await screen.findByRole('status')).toHaveTextContent(/eliminada/i)
  })

  it('shows the error when a pass cannot be deleted', async () => {
    const user = userEvent.setup()
    const deleteMock: MockedResponse = {
      request: { query: DELETE_PASS, variables: { id: '1' } },
      result: {
        data: {
          deletePass: {
            __typename: 'DeletePassPayload',
            success: false,
            errors: ['Cannot delete pass with clients having pending visits'],
          },
        },
      },
    }

    renderWithProviders(<AdminPassesPage />, { mocks: [allPassesMock([yoga]), deleteMock], session })

    await screen.findByText('Yoga 10 visitas')
    await user.click(screen.getByRole('button', { name: /eliminar/i }))

    expect(await screen.findByRole('alert')).toHaveTextContent(
      'Cannot delete pass with clients having pending visits',
    )
  })
})

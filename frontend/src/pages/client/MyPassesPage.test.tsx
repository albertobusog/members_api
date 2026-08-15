import { describe, expect, it } from 'vitest'
import { screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import type { MockedResponse } from '@apollo/client/testing'
import { ATTENDANCE_HISTORY, REGISTER_ATTENDANCE } from '../../graphql/operations'
import { renderWithProviders, clientUser } from '../../test/utils'
import { MyPassesPage } from './MyPassesPage'

const purchase = {
  __typename: 'Purchase',
  id: '77',
  remainingVisits: 8,
  validUntil: '2026-09-30',
  purchaseDate: '2026-08-31',
  pass: { __typename: 'Pass', id: '1', name: 'Yoga 10 visitas', visits: 10 },
}

const visits = [
  { __typename: 'Visit', id: 'v1', visitedAt: '2026-08-31T10:00:00Z', purchase },
  { __typename: 'Visit', id: 'v2', visitedAt: '2026-09-01T10:00:00Z', purchase },
]

const historyMock = (attendanceHistory: unknown[]): MockedResponse => ({
  request: { query: ATTENDANCE_HISTORY, variables: {} },
  result: { data: { attendanceHistory } },
})

const session = { token: 'jwt', user: clientUser }

describe('MyPassesPage', () => {
  it('shows the acquired passes with their usage state', async () => {
    renderWithProviders(<MyPassesPage />, { mocks: [historyMock(visits)], session })

    expect(await screen.findByText('Yoga 10 visitas')).toBeInTheDocument()
    expect(screen.getByText(/8 de 10 visitas disponibles/i)).toBeInTheDocument()
    expect(screen.getAllByRole('listitem', { name: /visita/i })).toHaveLength(2)
  })

  it('shows an empty state when there is no attendance yet', async () => {
    renderWithProviders(<MyPassesPage />, { mocks: [historyMock([])], session })

    expect(await screen.findByText(/aún no registras asistencias/i)).toBeInTheDocument()
  })

  it('registers an attendance and reports the remaining visits', async () => {
    const user = userEvent.setup()
    const registerMock: MockedResponse = {
      request: { query: REGISTER_ATTENDANCE, variables: {} },
      result: {
        data: {
          registerAttendance: {
            __typename: 'RegisterAttendancePayload',
            success: true,
            errors: null,
            purchase: {
              __typename: 'Purchase',
              id: '77',
              remainingVisits: 7,
              validUntil: '2026-09-30',
              pass: { __typename: 'Pass', id: '1', name: 'Yoga 10 visitas' },
            },
          },
        },
      },
    }

    renderWithProviders(<MyPassesPage />, {
      mocks: [historyMock(visits), registerMock, historyMock(visits)],
      session,
    })

    await screen.findByText('Yoga 10 visitas')
    await user.click(screen.getByRole('button', { name: /registrar asistencia/i }))

    expect(await screen.findByRole('status')).toHaveTextContent(/te quedan 7 visitas/i)
  })

  it('shows the error when there is no active pass', async () => {
    const user = userEvent.setup()
    const registerMock: MockedResponse = {
      request: { query: REGISTER_ATTENDANCE, variables: {} },
      result: {
        data: {
          registerAttendance: {
            __typename: 'RegisterAttendancePayload',
            success: false,
            errors: ['No active pass available'],
            purchase: null,
          },
        },
      },
    }

    renderWithProviders(<MyPassesPage />, { mocks: [historyMock([]), registerMock], session })

    await screen.findByText(/aún no registras asistencias/i)
    await user.click(screen.getByRole('button', { name: /registrar asistencia/i }))

    expect(await screen.findByRole('alert')).toHaveTextContent('No active pass available')
  })
})

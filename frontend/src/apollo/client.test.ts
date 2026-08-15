import { describe, expect, it, vi, beforeEach } from 'vitest'
import { gql } from '@apollo/client'
import { createApolloClient } from './client'
import { writeSession } from '../auth/session'

const QUERY = gql`
  query Passes {
    passes {
      id
    }
  }
`

function fakeFetch(body: unknown, status = 200) {
  return vi.fn<typeof globalThis.fetch>(async () =>
    new Response(JSON.stringify(body), {
      status,
      headers: { 'content-type': 'application/json' },
    }),
  )
}

function headersFrom(fetchMock: ReturnType<typeof fakeFetch>): Record<string, string> {
  const init = fetchMock.mock.calls[0]?.[1] as RequestInit
  return init.headers as Record<string, string>
}

describe('apollo client', () => {
  beforeEach(() => window.localStorage.clear())

  it('posts to the configured GraphQL url without Authorization when there is no session', async () => {
    const fetchMock = fakeFetch({ data: { passes: [] } })
    const client = createApolloClient({ uri: 'http://api.test/graphql', fetch: fetchMock })

    await client.query({ query: QUERY })

    expect(fetchMock.mock.calls[0]?.[0]).toBe('http://api.test/graphql')
    expect(headersFrom(fetchMock).authorization).toBeUndefined()
  })

  it('sends the stored JWT as a Bearer token', async () => {
    writeSession('jwt-token', { id: '1', email: 'a@example.com', role: 'client' })
    const fetchMock = fakeFetch({ data: { passes: [] } })
    const client = createApolloClient({ uri: 'http://api.test/graphql', fetch: fetchMock })

    await client.query({ query: QUERY })

    expect(headersFrom(fetchMock).authorization).toBe('Bearer jwt-token')
  })

  it('notifies when the API answers 401 so the app can sign out', async () => {
    writeSession('expired', { id: '1', email: 'a@example.com', role: 'client' })
    const onUnauthenticated = vi.fn()
    const fetchMock = fakeFetch({ errors: [{ message: 'Not authorized' }] }, 401)
    const client = createApolloClient({
      uri: 'http://api.test/graphql',
      fetch: fetchMock,
      onUnauthenticated,
    })

    await expect(client.query({ query: QUERY })).rejects.toBeTruthy()
    expect(onUnauthenticated).toHaveBeenCalled()
  })
})

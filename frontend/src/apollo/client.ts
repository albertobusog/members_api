import { ApolloClient, ApolloLink, HttpLink, InMemoryCache } from '@apollo/client'
import { SetContextLink } from '@apollo/client/link/context'
import { ErrorLink } from '@apollo/client/link/error'
import { readToken } from '../auth/session'

export const UNAUTHENTICATED_MESSAGES = ['not authorized', 'unauthorized']

export function buildAuthLink(): ApolloLink {
  return new SetContextLink(({ headers }) => {
    const token = readToken()
    return {
      headers: {
        ...headers,
        ...(token ? { authorization: `Bearer ${token}` } : {}),
      },
    }
  })
}

export function buildErrorLink(onUnauthenticated: () => void): ApolloLink {
  return new ErrorLink(({ error }) => {
    const status = (error as { statusCode?: number } | undefined)?.statusCode
    const message = (error as { message?: string } | undefined)?.message?.toLowerCase() ?? ''

    if (status === 401 || UNAUTHENTICATED_MESSAGES.some((needle) => message.includes(needle))) {
      onUnauthenticated()
    }
  })
}

export interface ApolloClientOptions {
  uri: string
  onUnauthenticated?: () => void
  fetch?: typeof globalThis.fetch
}

export function createApolloClient({ uri, onUnauthenticated, fetch }: ApolloClientOptions) {
  return new ApolloClient({
    link: ApolloLink.from([
      buildErrorLink(onUnauthenticated ?? (() => undefined)),
      buildAuthLink(),
      new HttpLink({ uri, fetch }),
    ]),
    cache: new InMemoryCache(),
  })
}

export function graphqlUri(): string {
  return import.meta.env.VITE_GRAPHQL_URL ?? 'http://localhost:3000/graphql'
}

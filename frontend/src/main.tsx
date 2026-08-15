import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { ApolloProvider } from '@apollo/client/react'
import { BrowserRouter } from 'react-router-dom'
import { createApolloClient, graphqlUri } from './apollo/client'
import { AuthProvider } from './auth/AuthContext'
import { clearSession } from './auth/session'
import { App } from './App'
import './index.css'

const client = createApolloClient({
  uri: graphqlUri(),
  onUnauthenticated: () => clearSession(),
})

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <ApolloProvider client={client}>
      <BrowserRouter>
        <AuthProvider>
          <App />
        </AuthProvider>
      </BrowserRouter>
    </ApolloProvider>
  </StrictMode>,
)

import { useState } from 'react'
import type { FormEvent } from 'react'
import { useMutation } from '@apollo/client/react'
import { Link, useNavigate } from 'react-router-dom'
import { SIGN_IN } from '../graphql/operations'
import { homePathFor, useAuth } from '../auth/AuthContext'
import { ErrorMessages } from '../components/ErrorMessages'
import type { User } from '../types'

interface SignInData {
  signIn: { token: string | null; user: User | null; errors: string[] | null } | null
}

export function SignInPage() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [errors, setErrors] = useState<string[]>([])
  const { signIn } = useAuth()
  const navigate = useNavigate()

  const [runSignIn, { loading }] = useMutation<SignInData>(SIGN_IN, {
    onCompleted: (data) => {
      const payload = data?.signIn
      if (payload?.token && payload.user) {
        signIn(payload.token, payload.user)
        navigate(homePathFor(payload.user), { replace: true })
        return
      }
      setErrors(payload?.errors?.length ? payload.errors : ['No se pudo iniciar sesión'])
    },
    onError: (error) => setErrors([error.message]),
  })

  function handleSubmit(event: FormEvent) {
    event.preventDefault()
    setErrors([])
    void runSignIn({ variables: { email, password } })
  }

  return (
    <section className="card">
      <h1>Iniciar sesión</h1>
      <form onSubmit={handleSubmit}>
        <label htmlFor="email">Email</label>
        <input
          id="email"
          type="email"
          value={email}
          onChange={(event) => setEmail(event.target.value)}
          required
        />

        <label htmlFor="password">Contraseña</label>
        <input
          id="password"
          type="password"
          value={password}
          onChange={(event) => setPassword(event.target.value)}
          required
        />

        <ErrorMessages errors={errors} />

        <button type="submit" disabled={loading}>
          {loading ? 'Entrando…' : 'Iniciar sesión'}
        </button>
      </form>
      <p>
        ¿No tienes cuenta? <Link to="/signup">Crear cuenta</Link>
      </p>
    </section>
  )
}

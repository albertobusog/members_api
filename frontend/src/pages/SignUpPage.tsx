import { useState } from 'react'
import type { FormEvent } from 'react'
import { useMutation } from '@apollo/client/react'
import { Link, useNavigate } from 'react-router-dom'
import { SIGN_UP } from '../graphql/operations'
import { homePathFor, useAuth } from '../auth/AuthContext'
import { ErrorMessages } from '../components/ErrorMessages'
import type { Role, User } from '../types'

interface SignUpData {
  signUp: { token: string | null; user: User | null; errors: string[] | null } | null
}

export function SignUpPage() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [role, setRole] = useState<Role>('client')
  const [errors, setErrors] = useState<string[]>([])
  const { signIn } = useAuth()
  const navigate = useNavigate()

  const [runSignUp, { loading }] = useMutation<SignUpData>(SIGN_UP, {
    onCompleted: (data) => {
      const payload = data?.signUp
      if (payload?.token && payload.user) {
        signIn(payload.token, payload.user)
        navigate(homePathFor(payload.user), { replace: true })
        return
      }
      setErrors(payload?.errors?.length ? payload.errors : ['No se pudo crear la cuenta'])
    },
    onError: (error) => setErrors([error.message]),
  })

  function handleSubmit(event: FormEvent) {
    event.preventDefault()
    setErrors([])
    void runSignUp({ variables: { email, password, role } })
  }

  return (
    <section className="card">
      <h1>Crear cuenta</h1>
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

        <label htmlFor="role">Rol</label>
        <select id="role" value={role} onChange={(event) => setRole(event.target.value as Role)}>
          <option value="client">Cliente</option>
          <option value="admin">Administrador</option>
        </select>

        <ErrorMessages errors={errors} />

        <button type="submit" disabled={loading}>
          {loading ? 'Creando…' : 'Crear cuenta'}
        </button>
      </form>
      <p>
        ¿Ya tienes cuenta? <Link to="/signin">Iniciar sesión</Link>
      </p>
    </section>
  )
}

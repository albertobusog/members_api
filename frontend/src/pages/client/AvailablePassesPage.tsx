import { useState } from 'react'
import type { FormEvent } from 'react'
import { useMutation, useQuery } from '@apollo/client/react'
import { ACQUIRE_PASS, AVAILABLE_PASSES } from '../../graphql/operations'
import { ErrorMessages } from '../../components/ErrorMessages'
import { formatDate, formatMoney } from '../../components/Money'
import type { Pass, Purchase } from '../../types'

interface AvailablePassesData {
  availablePasses: Pass[]
}

interface AcquirePassData {
  acquirePass: { purchase: Purchase | null; errors: string[] | null } | null
}

interface Filters {
  nameContains?: string
  minPrice?: number
  maxPrice?: number
}

function buildFilters(name: string, min: string, max: string): Filters {
  const filters: Filters = {}
  if (name.trim()) filters.nameContains = name.trim()
  if (min.trim()) filters.minPrice = Number(min)
  if (max.trim()) filters.maxPrice = Number(max)
  return filters
}

export function AvailablePassesPage() {
  const [name, setName] = useState('')
  const [minPrice, setMinPrice] = useState('')
  const [maxPrice, setMaxPrice] = useState('')
  const [errors, setErrors] = useState<string[]>([])
  const [notice, setNotice] = useState('')

  const { data, loading, error, refetch } = useQuery<AvailablePassesData>(AVAILABLE_PASSES)

  const [acquirePass, { loading: acquiring }] = useMutation<AcquirePassData>(ACQUIRE_PASS, {
    onCompleted: (payload) => {
      const result = payload?.acquirePass
      if (result?.purchase) {
        setErrors([])
        setNotice(`Cuponera "${result.purchase.pass?.name ?? ''}" adquirida correctamente`)
        void refetch(buildFilters(name, minPrice, maxPrice))
        return
      }
      setNotice('')
      setErrors(result?.errors?.length ? result.errors : ['No se pudo adquirir la cuponera'])
    },
    onError: (mutationError) => {
      setNotice('')
      setErrors([mutationError.message])
    },
  })

  function handleFilter(event: FormEvent) {
    event.preventDefault()
    setNotice('')
    setErrors([])
    void refetch(buildFilters(name, minPrice, maxPrice))
  }

  const passes = data?.availablePasses ?? []

  return (
    <section>
      <h1>Cuponeras disponibles</h1>

      <form onSubmit={handleFilter} className="filters">
        <label htmlFor="nameContains">Nombre</label>
        <input id="nameContains" value={name} onChange={(e) => setName(e.target.value)} />

        <label htmlFor="minPrice">Precio mínimo</label>
        <input id="minPrice" type="number" value={minPrice} onChange={(e) => setMinPrice(e.target.value)} />

        <label htmlFor="maxPrice">Precio máximo</label>
        <input id="maxPrice" type="number" value={maxPrice} onChange={(e) => setMaxPrice(e.target.value)} />

        <button type="submit">Filtrar</button>
      </form>

      {notice && <p role="status">{notice}</p>}
      <ErrorMessages errors={error ? [error.message, ...errors] : errors} />

      {loading && <p>Cargando cuponeras…</p>}

      {!loading && passes.length === 0 && <p>No hay cuponeras disponibles</p>}

      <ul className="cards">
        {passes.map((pass) => (
          <li key={pass.id} className="card">
            <h2>{pass.name}</h2>
            <p>{pass.visits} visitas</p>
            <p>{formatMoney(pass.price)}</p>
            <p>Vence: {formatDate(pass.expiresAt)}</p>
            <button
              type="button"
              disabled={acquiring}
              onClick={() => void acquirePass({ variables: { passId: pass.id } })}
            >
              Adquirir
            </button>
          </li>
        ))}
      </ul>
    </section>
  )
}

import { useState } from 'react'
import type { FormEvent } from 'react'
import { useQuery } from '@apollo/client/react'
import { ADMIN_PASS_ACQUISITIONS } from '../../graphql/operations'
import { ErrorMessages } from '../../components/ErrorMessages'
import { formatDate } from '../../components/Money'
import type { Pass } from '../../types'

interface AdminPassAcquisitionsData {
  adminPassAcquisitions: Pass[]
}

export function AdminAcquisitionsPage() {
  const [passId, setPassId] = useState('')
  const { data, loading, error, refetch } = useQuery<AdminPassAcquisitionsData>(ADMIN_PASS_ACQUISITIONS)

  function handleFilter(event: FormEvent) {
    event.preventDefault()
    void refetch(passId.trim() ? { passId: passId.trim() } : {})
  }

  const passes = data?.adminPassAcquisitions ?? []

  return (
    <section>
      <h1>Clientes por cuponera</h1>

      <form onSubmit={handleFilter} className="filters">
        <label htmlFor="passId">ID de cuponera</label>
        <input id="passId" value={passId} onChange={(event) => setPassId(event.target.value)} />
        <button type="submit">Filtrar</button>
      </form>

      <ErrorMessages errors={error ? [error.message] : []} />

      {loading && <p>Cargando…</p>}

      {passes.map((pass) => (
        <article key={pass.id} className="card">
          <h2>{pass.name}</h2>
          {pass.purchases && pass.purchases.length > 0 ? (
            <table>
              <thead>
                <tr>
                  <th>Cliente</th>
                  <th>Estado de uso</th>
                  <th>Comprada</th>
                  <th>Válida hasta</th>
                </tr>
              </thead>
              <tbody>
                {pass.purchases.map((purchase) => (
                  <tr key={purchase.id}>
                    <td>{purchase.user?.email}</td>
                    <td>{purchase.remainingVisits} visitas restantes</td>
                    <td>{formatDate(purchase.purchaseDate)}</td>
                    <td>{formatDate(purchase.validUntil)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          ) : (
            <p>Sin clientes</p>
          )}
        </article>
      ))}
    </section>
  )
}

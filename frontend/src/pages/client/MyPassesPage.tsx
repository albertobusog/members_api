import { useState } from 'react'
import { useMutation, useQuery } from '@apollo/client/react'
import { ATTENDANCE_HISTORY, REGISTER_ATTENDANCE } from '../../graphql/operations'
import { ErrorMessages } from '../../components/ErrorMessages'
import { formatDate } from '../../components/Money'
import type { Purchase, Visit } from '../../types'

interface AttendanceHistoryData {
  attendanceHistory: Visit[]
}

interface RegisterAttendanceData {
  registerAttendance: {
    success: boolean
    errors: string[] | null
    purchase: Purchase | null
  } | null
}

interface PassUsage {
  purchase: Purchase
  visits: Visit[]
}

function groupByPurchase(visits: Visit[]): PassUsage[] {
  const groups = new Map<string, PassUsage>()

  visits.forEach((visit) => {
    const current = groups.get(visit.purchase.id)
    if (current) {
      current.visits.push(visit)
    } else {
      groups.set(visit.purchase.id, { purchase: visit.purchase, visits: [visit] })
    }
  })

  return [...groups.values()]
}

export function MyPassesPage() {
  const [errors, setErrors] = useState<string[]>([])
  const [notice, setNotice] = useState('')

  const { data, loading, error, refetch } = useQuery<AttendanceHistoryData>(ATTENDANCE_HISTORY)

  const [registerAttendance, { loading: registering }] = useMutation<RegisterAttendanceData>(
    REGISTER_ATTENDANCE,
    {
      onCompleted: (payload) => {
        const result = payload?.registerAttendance
        if (result?.success) {
          setErrors([])
          setNotice(`Asistencia registrada. Te quedan ${result.purchase?.remainingVisits ?? 0} visitas`)
          void refetch()
          return
        }
        setNotice('')
        setErrors(result?.errors?.length ? result.errors : ['No se pudo registrar la asistencia'])
      },
      onError: (mutationError) => {
        setNotice('')
        setErrors([mutationError.message])
      },
    },
  )

  const usages = groupByPurchase(data?.attendanceHistory ?? [])

  return (
    <section>
      <h1>Mis cuponeras</h1>

      <button type="button" disabled={registering} onClick={() => void registerAttendance()}>
        Registrar asistencia
      </button>

      {notice && <p role="status">{notice}</p>}
      <ErrorMessages errors={error ? [error.message, ...errors] : errors} />

      {loading && <p>Cargando historial…</p>}

      {!loading && usages.length === 0 && <p>Aún no registras asistencias</p>}

      {usages.map(({ purchase, visits }) => (
        <article key={purchase.id} className="card">
          <h2>{purchase.pass?.name}</h2>
          <p>
            {purchase.remainingVisits} de {purchase.pass?.visits} visitas disponibles
          </p>
          <p>Válida hasta: {formatDate(purchase.validUntil)}</p>
          <h3>Historial de asistencia</h3>
          <ul>
            {visits.map((visit) => (
              <li key={visit.id} aria-label={`Visita del ${formatDate(visit.visitedAt)}`}>
                {new Date(visit.visitedAt).toLocaleString('es-MX')}
              </li>
            ))}
          </ul>
        </article>
      ))}
    </section>
  )
}

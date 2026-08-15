import { useState } from 'react'
import { useMutation, useQuery } from '@apollo/client/react'
import { ALL_PASSES, CREATE_PASS, DELETE_PASS, UPDATE_PASS } from '../../graphql/operations'
import { ErrorMessages } from '../../components/ErrorMessages'
import { formatDate, formatMoney } from '../../components/Money'
import type { Pass } from '../../types'
import { PassForm } from './PassForm'
import type { PassFormValues } from './PassForm'

interface AllPassesData {
  allPasses: Pass[]
}

interface CreatePassData {
  createPass: { pass: Pass | null; errors: string[] | null } | null
}

interface UpdatePassData {
  updatePass: { pass: Pass | null; errors: string[] | null } | null
}

interface DeletePassData {
  deletePass: { success: boolean; errors: string[] | null } | null
}

export function AdminPassesPage() {
  const [errors, setErrors] = useState<string[]>([])
  const [notice, setNotice] = useState('')
  const [editing, setEditing] = useState<Pass | null>(null)

  const { data, loading, error, refetch } = useQuery<AllPassesData>(ALL_PASSES)

  function fail(messages: string[] | null | undefined, fallback: string) {
    setNotice('')
    setErrors(messages?.length ? messages : [fallback])
  }

  function succeed(message: string) {
    setErrors([])
    setNotice(message)
    void refetch()
  }

  const [createPass, { loading: creating }] = useMutation<CreatePassData>(CREATE_PASS, {
    onCompleted: (payload) =>
      payload?.createPass?.pass
        ? succeed(`Cuponera "${payload.createPass.pass.name}" creada`)
        : fail(payload?.createPass?.errors, 'No se pudo crear la cuponera'),
    onError: (mutationError) => fail([mutationError.message], mutationError.message),
  })

  const [updatePass, { loading: updating }] = useMutation<UpdatePassData>(UPDATE_PASS, {
    onCompleted: (payload) => {
      if (payload?.updatePass?.pass) {
        setEditing(null)
        succeed(`Cuponera "${payload.updatePass.pass.name}" actualizada`)
        return
      }
      fail(payload?.updatePass?.errors, 'No se pudo actualizar la cuponera')
    },
    onError: (mutationError) => fail([mutationError.message], mutationError.message),
  })

  const [deletePass, { loading: deleting }] = useMutation<DeletePassData>(DELETE_PASS, {
    onCompleted: (payload) =>
      payload?.deletePass?.success
        ? succeed('Cuponera eliminada')
        : fail(payload?.deletePass?.errors, 'No se pudo eliminar la cuponera'),
    onError: (mutationError) => fail([mutationError.message], mutationError.message),
  })

  function handleCreate(values: PassFormValues) {
    setErrors([])
    void createPass({ variables: values })
  }

  function handleUpdate(values: PassFormValues) {
    if (!editing) return
    setErrors([])
    void updatePass({ variables: { id: editing.id, ...values } })
  }

  const passes = data?.allPasses ?? []

  return (
    <section>
      <h1>Cuponeras</h1>

      {notice && <p role="status">{notice}</p>}
      <ErrorMessages errors={error ? [error.message, ...errors] : errors} />

      <PassForm
        title="Nueva cuponera"
        submitLabel="Crear cuponera"
        disabled={creating}
        onSubmit={handleCreate}
      />

      {loading && <p>Cargando cuponeras…</p>}
      {!loading && passes.length === 0 && <p>Todavía no hay cuponeras</p>}

      <ul className="cards">
        {passes.map((pass) => (
          <li key={pass.id} className="card">
            <h2>{pass.name}</h2>
            <p>{pass.visits} visitas</p>
            <p>{formatMoney(pass.price)}</p>
            <p>Vence: {formatDate(pass.expiresAt)}</p>
            <button type="button" onClick={() => setEditing(pass)}>
              Editar
            </button>
            <button
              type="button"
              disabled={deleting}
              onClick={() => void deletePass({ variables: { id: pass.id } })}
            >
              Eliminar
            </button>
            {editing?.id === pass.id && (
              <PassForm
                key={pass.id}
                title="Editar cuponera"
                submitLabel="Guardar cambios"
                pass={pass}
                disabled={updating}
                onSubmit={handleUpdate}
                onCancel={() => setEditing(null)}
              />
            )}
          </li>
        ))}
      </ul>
    </section>
  )
}

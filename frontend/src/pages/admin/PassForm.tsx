import { useState } from 'react'
import type { FormEvent } from 'react'
import type { Pass } from '../../types'

export interface PassFormValues {
  name: string
  visits: number
  price: number
  expiresAt: string
}

interface PassFormProps {
  title: string
  submitLabel: string
  pass?: Pass
  disabled?: boolean
  onSubmit: (values: PassFormValues) => void
  onCancel?: () => void
}

export function PassForm({ title, submitLabel, pass, disabled, onSubmit, onCancel }: PassFormProps) {
  const [name, setName] = useState(pass?.name ?? '')
  const [visits, setVisits] = useState(pass ? String(pass.visits) : '')
  const [price, setPrice] = useState(pass ? String(pass.price) : '')
  const [expiresAt, setExpiresAt] = useState(pass?.expiresAt ?? '')

  const fieldId = (field: string) => `${pass ? `edit-${pass.id}` : 'new'}-${field}`

  function handleSubmit(event: FormEvent) {
    event.preventDefault()
    onSubmit({ name, visits: Number(visits), price: Number(price), expiresAt })
  }

  return (
    <form aria-label={title} onSubmit={handleSubmit} className="card">
      <h2>{title}</h2>

      <label htmlFor={fieldId('name')}>Nombre</label>
      <input id={fieldId('name')} value={name} onChange={(e) => setName(e.target.value)} required />

      <label htmlFor={fieldId('visits')}>Visitas</label>
      <input
        id={fieldId('visits')}
        type="number"
        value={visits}
        onChange={(e) => setVisits(e.target.value)}
        required
      />

      <label htmlFor={fieldId('price')}>Precio</label>
      <input
        id={fieldId('price')}
        type="number"
        step="0.01"
        value={price}
        onChange={(e) => setPrice(e.target.value)}
        required
      />

      <label htmlFor={fieldId('expiresAt')}>Vence el</label>
      <input
        id={fieldId('expiresAt')}
        type="date"
        value={expiresAt}
        onChange={(e) => setExpiresAt(e.target.value)}
        required
      />

      <button type="submit" disabled={disabled}>
        {submitLabel}
      </button>
      {onCancel && (
        <button type="button" onClick={onCancel}>
          Cancelar
        </button>
      )}
    </form>
  )
}

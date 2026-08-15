export function ErrorMessages({ errors }: { errors: readonly string[] }) {
  if (errors.length === 0) return null

  return (
    <ul role="alert" className="errors">
      {errors.map((error) => (
        <li key={error}>{error}</li>
      ))}
    </ul>
  )
}

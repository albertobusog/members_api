export type Role = 'client' | 'admin'

export interface User {
  id: string
  email: string
  role: Role
}

export interface Pass {
  id: string
  name: string
  visits: number
  price: number
  expiresAt: string
  purchases?: Purchase[]
}

export interface Purchase {
  id: string
  remainingVisits: number
  validUntil: string
  purchaseDate: string
  price: number
  user?: User
  pass?: Pass
}

export interface Visit {
  id: string
  visitedAt: string
  purchase: Purchase
}

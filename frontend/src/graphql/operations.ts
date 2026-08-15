import { gql } from '@apollo/client'

// The backend only lets unauthenticated requests through when the operation is
// named SignIn / SignUp (see GraphqlController#public_operation?).
export const SIGN_IN = gql`
  mutation SignIn($email: String!, $password: String!) {
    signIn(input: { email: $email, password: $password }) {
      token
      user {
        id
        email
        role
      }
      errors
    }
  }
`

export const SIGN_UP = gql`
  mutation SignUp($email: String!, $password: String!, $role: String!) {
    signUp(input: { email: $email, password: $password, role: $role }) {
      token
      user {
        id
        email
        role
      }
      errors
    }
  }
`

export const AVAILABLE_PASSES = gql`
  query AvailablePasses($nameContains: String, $minPrice: Float, $maxPrice: Float) {
    availablePasses(nameContains: $nameContains, minPrice: $minPrice, maxPrice: $maxPrice) {
      id
      name
      visits
      price
      expiresAt
    }
  }
`

export const ACQUIRE_PASS = gql`
  mutation AcquirePass($passId: ID!) {
    acquirePass(input: { passId: $passId }) {
      purchase {
        id
        remainingVisits
        validUntil
        purchaseDate
        price
        pass {
          id
          name
        }
      }
      errors
    }
  }
`

export const ATTENDANCE_HISTORY = gql`
  query AttendanceHistory($userId: ID) {
    attendanceHistory(userId: $userId) {
      id
      visitedAt
      purchase {
        id
        remainingVisits
        validUntil
        purchaseDate
        pass {
          id
          name
          visits
        }
      }
    }
  }
`

export const REGISTER_ATTENDANCE = gql`
  mutation RegisterAttendance {
    registerAttendance(input: {}) {
      success
      errors
      purchase {
        id
        remainingVisits
        validUntil
        pass {
          id
          name
        }
      }
    }
  }
`

export const ALL_PASSES = gql`
  query AllPasses {
    allPasses {
      id
      name
      visits
      price
      expiresAt
    }
  }
`

export const CREATE_PASS = gql`
  mutation CreatePass($name: String!, $visits: Int!, $price: Float!, $expiresAt: ISO8601Date!) {
    createPass(input: { name: $name, visits: $visits, price: $price, expiresAt: $expiresAt }) {
      pass {
        id
        name
        visits
        price
        expiresAt
      }
      errors
    }
  }
`

export const UPDATE_PASS = gql`
  mutation UpdatePass($id: ID!, $name: String, $visits: Int, $price: Float, $expiresAt: ISO8601Date) {
    updatePass(input: { id: $id, name: $name, visits: $visits, price: $price, expiresAt: $expiresAt }) {
      pass {
        id
        name
        visits
        price
        expiresAt
      }
      errors
    }
  }
`

export const DELETE_PASS = gql`
  mutation DeletePass($id: ID!) {
    deletePass(input: { id: $id }) {
      success
      errors
    }
  }
`

export const ADMIN_PASS_ACQUISITIONS = gql`
  query AdminPassAcquisitions($passId: ID) {
    adminPassAcquisitions(passId: $passId) {
      id
      name
      visits
      price
      purchases {
        id
        remainingVisits
        validUntil
        purchaseDate
        user {
          id
          email
        }
      }
    }
  }
`

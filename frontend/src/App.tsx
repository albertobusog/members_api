import { Navigate, Route, Routes } from 'react-router-dom'
import { AppLayout } from './components/AppLayout'
import { homePathFor, useAuth } from './auth/AuthContext'
import { ProtectedRoute } from './routes/ProtectedRoute'
import { SignInPage } from './pages/SignInPage'
import { SignUpPage } from './pages/SignUpPage'
import { AvailablePassesPage } from './pages/client/AvailablePassesPage'
import { MyPassesPage } from './pages/client/MyPassesPage'
import { AdminPassesPage } from './pages/admin/AdminPassesPage'
import { AdminAcquisitionsPage } from './pages/admin/AdminAcquisitionsPage'

export function App() {
  const { user } = useAuth()

  return (
    <AppLayout>
      <Routes>
        <Route path="/signin" element={<SignInPage />} />
        <Route path="/signup" element={<SignUpPage />} />

        <Route element={<ProtectedRoute role="client" />}>
          <Route path="/cliente/cuponeras" element={<AvailablePassesPage />} />
          <Route path="/cliente/mis-cuponeras" element={<MyPassesPage />} />
        </Route>

        <Route element={<ProtectedRoute role="admin" />}>
          <Route path="/admin/cuponeras" element={<AdminPassesPage />} />
          <Route path="/admin/adquisiciones" element={<AdminAcquisitionsPage />} />
        </Route>

        <Route path="*" element={<Navigate to={homePathFor(user)} replace />} />
      </Routes>
    </AppLayout>
  )
}

export default App

import { Outlet, Navigate } from 'react-router-dom';
import { useAuthStore } from '@/store/auth';

const AuthLayout = () => {
  const { isAuthenticated } = useAuthStore();

  if (isAuthenticated) {
    return <Navigate to="/" replace />;
  }

  return (
    <div className="flex min-h-screen items-center justify-center bg-gray-100 p-4">
      <div className="w-full max-w-md bg-white p-8 shadow-lg rounded-lg">
        <Outlet />
      </div>
    </div>
  );
};

export default AuthLayout;

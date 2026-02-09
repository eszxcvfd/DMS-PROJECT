import { Outlet, Navigate } from 'react-router-dom';
import { useAuthStore } from '@/store/auth';

const DashboardLayout = () => {
  const { isAuthenticated, logout } = useAuthStore();

  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  return (
    <div className="flex h-screen bg-gray-100">
      <aside className="w-64 bg-white shadow-md p-4 flex flex-col">
        <h1 className="text-xl font-bold mb-6 text-blue-600">DMS VIPPro</h1>
        <nav className="flex-1 space-y-2">
          <a href="/" className="block p-2 rounded hover:bg-gray-100 text-gray-700">Dashboard</a>
          <a href="/orders" className="block p-2 rounded hover:bg-gray-100 text-gray-700">Orders</a>
          <a href="/map" className="block p-2 rounded hover:bg-gray-100 text-gray-700">Map</a>
          <a href="/admin" className="block p-2 rounded hover:bg-gray-100 text-gray-700">Admin</a>
        </nav>
        <button 
          onClick={logout} 
          className="mt-auto w-full p-2 bg-red-500 text-white rounded hover:bg-red-600 transition"
        >
          Logout
        </button>
      </aside>
      <main className="flex-1 p-8 overflow-auto">
        <Outlet />
      </main>
    </div>
  );
};

export default DashboardLayout;

import { createBrowserRouter, RouterProvider, Route, createRoutesFromElements } from 'react-router-dom';
import AuthLayout from '@/layouts/AuthLayout';
import DashboardLayout from '@/layouts/DashboardLayout';

import { LoginPage } from '@/features/auth/LoginPage';
import { DashboardPage } from '@/features/dashboard/DashboardPage';
import { OrdersPage } from '@/features/orders/OrdersPage';
import { MapPage } from '@/features/map/MapPage';
import { AdminPage } from '@/features/admin/AdminPage';

const router = createBrowserRouter(
  createRoutesFromElements(
    <>
      {/* Public Routes */}
      <Route element={<AuthLayout />}>
        <Route path="/login" element={<LoginPage />} />
      </Route>

      {/* Protected Routes */}
      <Route element={<DashboardLayout />}>
        <Route path="/" element={<DashboardPage />} />
        <Route path="/orders" element={<OrdersPage />} />
        <Route path="/map" element={<MapPage />} />
        <Route path="/admin" element={<AdminPage />} />
      </Route>

      {/* 404 Route */}
      <Route path="*" element={
        <div className="flex h-screen items-center justify-center text-red-500 text-2xl font-bold">
          404 - Page Not Found
        </div>
      } />
    </>
  )
);

export const AppRouter = () => <RouterProvider router={router} />;

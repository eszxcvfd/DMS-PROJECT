import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

const queryClient = new QueryClient();

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <Router>
        <div className="min-h-screen bg-gray-50 text-gray-900 flex items-center justify-center">
          <div className="text-center p-8 bg-white rounded-xl shadow-lg">
            <h1 className="text-3xl font-bold text-blue-600 mb-4">DMS VIPPro Web App</h1>
            <p className="text-lg text-gray-700">Welcome to the Distribution Management System.</p>
          </div>
        </div>
      </Router>
    </QueryClientProvider>
  );
}

export default App;

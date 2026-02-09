export const DashboardPage = () => {
  return (
    <div>
      <h1 className="text-2xl font-bold mb-4">Dashboard Overview</h1>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="bg-white p-4 shadow rounded">Total Orders: 120</div>
        <div className="bg-white p-4 shadow rounded">Active Routes: 15</div>
        <div className="bg-white p-4 shadow rounded">Revenue: $5,400</div>
      </div>
    </div>
  );
};

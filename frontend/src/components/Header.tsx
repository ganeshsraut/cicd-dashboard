import React from 'react';
import { Activity, Bell, Settings, User } from 'lucide-react';

const Header: React.FC = () => {
  return (
    <header className="bg-white shadow-sm border-b border-gray-200">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center h-16">
          {/* Logo */}
          <div className="flex items-center space-x-3">
            <div className="bg-blue-600 p-2 rounded-lg">
              <Activity className="w-6 h-6 text-white" />
            </div>
            <h1 className="text-xl font-bold text-gray-900">CI/CD Dashboard</h1>
          </div>

          {/* Navigation */}
          <nav className="hidden md:flex space-x-8">
            <a href="#" className="text-gray-900 hover:text-blue-600 px-3 py-2 text-sm font-medium">
              Dashboard
            </a>
            <a href="#" className="text-gray-500 hover:text-blue-600 px-3 py-2 text-sm font-medium">
              Pipelines
            </a>
            <a href="#" className="text-gray-500 hover:text-blue-600 px-3 py-2 text-sm font-medium">
              Alerts
            </a>
            <a href="#" className="text-gray-500 hover:text-blue-600 px-3 py-2 text-sm font-medium">
              Reports
            </a>
          </nav>

          {/* Right side actions */}
          <div className="flex items-center space-x-4">
            <button className="p-2 text-gray-400 hover:text-gray-500 relative">
              <Bell className="w-5 h-5" />
              <span className="absolute top-0 right-0 block h-2 w-2 rounded-full bg-red-400"></span>
            </button>
            <button className="p-2 text-gray-400 hover:text-gray-500">
              <Settings className="w-5 h-5" />
            </button>
            <button className="p-2 text-gray-400 hover:text-gray-500">
              <User className="w-5 h-5" />
            </button>
          </div>
        </div>
      </div>
    </header>
  );
};

export default Header;

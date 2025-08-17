import React from 'react';
import { Home, GitBranch, AlertTriangle, BarChart3, Settings, HelpCircle } from 'lucide-react';

const Sidebar: React.FC = () => {
  const navigation = [
    { name: 'Dashboard', href: '/', icon: Home, current: true },
    { name: 'Pipelines', href: '/pipelines', icon: GitBranch, current: false },
    { name: 'Alerts', href: '/alerts', icon: AlertTriangle, current: false },
    { name: 'Analytics', href: '/analytics', icon: BarChart3, current: false },
    { name: 'Settings', href: '/settings', icon: Settings, current: false },
    { name: 'Help', href: '/help', icon: HelpCircle, current: false },
  ];

  return (
    <div className="w-64 bg-white shadow-sm border-r border-gray-200 min-h-screen">
      <div className="p-6">
        <h2 className="text-lg font-semibold text-gray-900">Navigation</h2>
      </div>
      <nav className="px-3">
        <ul className="space-y-1">
          {navigation.map((item) => (
            <li key={item.name}>
              <a
                href={item.href}
                className={`group flex items-center px-3 py-2 text-sm font-medium rounded-md ${
                  item.current
                    ? 'bg-blue-100 text-blue-700'
                    : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
                }`}
              >
                <item.icon
                  className={`mr-3 h-5 w-5 ${
                    item.current ? 'text-blue-500' : 'text-gray-400 group-hover:text-gray-500'
                  }`}
                />
                {item.name}
              </a>
            </li>
          ))}
        </ul>
      </nav>
    </div>
  );
};

export default Sidebar;

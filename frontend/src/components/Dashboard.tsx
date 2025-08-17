import React, { useState, useEffect } from 'react';
import { io, Socket } from 'socket.io-client';
import MetricsCard from './MetricsCard';
import PipelineStatus from './PipelineStatus';
import { Activity, CheckCircle, Clock, XCircle } from 'lucide-react';

interface Metrics {
  total_pipelines: number;
  successful_pipelines: number;
  failed_pipelines: number;
  success_rate: number;
  avg_duration: number;
  last_updated: string;
}

const Dashboard: React.FC = () => {
  const [metrics, setMetrics] = useState<Metrics | null>(null);
  const [_socket, setSocket] = useState<Socket | null>(null);
  const [isConnected, setIsConnected] = useState(false);

  useEffect(() => {
    // Fetch initial metrics
    fetchMetrics();

    // Setup WebSocket connection
    const newSocket = io('http://localhost:8000');
    setSocket(newSocket);

    newSocket.on('connect', () => {
      setIsConnected(true);
      console.log('Connected to WebSocket server');
    });

    newSocket.on('disconnect', () => {
      setIsConnected(false);
      console.log('Disconnected from WebSocket server');
    });

    newSocket.on('pipeline:status', (data) => {
      console.log('Pipeline status update:', data);
      // Refresh metrics when pipeline status changes
      fetchMetrics();
    });

    return () => {
      newSocket.close();
    };
  }, []);

  const fetchMetrics = async () => {
    try {
      const response = await fetch('http://localhost:8000/api/metrics/summary');
      const data = await response.json();
      setMetrics(data);
    } catch (error) {
      console.error('Error fetching metrics:', error);
    }
  };

  if (!metrics) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">CI/CD Pipeline Dashboard</h1>
          <p className="text-gray-600 mt-2">
            Monitor your pipeline health and performance in real-time
          </p>
        </div>
        <div className="flex items-center space-x-2">
          <div className={`w-3 h-3 rounded-full ${isConnected ? 'bg-green-500' : 'bg-red-500'}`}></div>
          <span className="text-sm text-gray-600">
            {isConnected ? 'Connected' : 'Disconnected'}
          </span>
        </div>
      </div>

      {/* Metrics Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <MetricsCard
          title="Total Pipelines"
          value={metrics.total_pipelines}
          icon={Activity}
          color="blue"
        />
        <MetricsCard
          title="Success Rate"
          value={`${metrics.success_rate}%`}
          icon={CheckCircle}
          color="green"
        />
        <MetricsCard
          title="Failed Pipelines"
          value={metrics.failed_pipelines}
          icon={XCircle}
          color="red"
        />
        <MetricsCard
          title="Avg Duration"
          value={`${Math.round(metrics.avg_duration / 60)}m`}
          icon={Clock}
          color="yellow"
        />
      </div>

      {/* Pipeline Status */}
      <PipelineStatus />

      {/* Last Updated */}
      <div className="text-center text-sm text-gray-500">
        Last updated: {new Date(metrics.last_updated).toLocaleString()}
      </div>
    </div>
  );
};

export default Dashboard;

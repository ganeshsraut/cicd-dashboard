import React, { useState, useEffect } from 'react';
import { Play, CheckCircle, XCircle, Clock, AlertCircle } from 'lucide-react';

interface Pipeline {
  id: string;
  name: string;
  status: 'success' | 'failure' | 'running' | 'pending';
  started_at: string;
  completed_at?: string;
  duration: number;
}

const PipelineStatus: React.FC = () => {
  const [pipelines, setPipelines] = useState<Pipeline[]>([]);

  useEffect(() => {
    fetchPipelines();
  }, []);

  const fetchPipelines = async () => {
    try {
      const response = await fetch('http://localhost:8000/api/pipelines');
      const data = await response.json();
      setPipelines(data.pipelines);
    } catch (error) {
      console.error('Error fetching pipelines:', error);
    }
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'success':
        return <CheckCircle className="w-5 h-5 text-green-500" />;
      case 'failure':
        return <XCircle className="w-5 h-5 text-red-500" />;
      case 'running':
        return <Play className="w-5 h-5 text-blue-500" />;
      case 'pending':
        return <Clock className="w-5 h-5 text-yellow-500" />;
      default:
        return <AlertCircle className="w-5 h-5 text-gray-500" />;
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'success':
        return 'bg-green-100 text-green-800';
      case 'failure':
        return 'bg-red-100 text-red-800';
      case 'running':
        return 'bg-blue-100 text-blue-800';
      case 'pending':
        return 'bg-yellow-100 text-yellow-800';
      default:
        return 'bg-gray-100 text-gray-800';
    }
  };

  const formatDuration = (seconds: number) => {
    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = seconds % 60;
    return `${minutes}m ${remainingSeconds}s`;
  };

  return (
    <div className="bg-white rounded-lg shadow-md border border-gray-200">
      <div className="px-6 py-4 border-b border-gray-200">
        <h3 className="text-lg font-medium text-gray-900">Recent Pipelines</h3>
      </div>
      <div className="divide-y divide-gray-200">
        {pipelines.map((pipeline) => (
          <div key={pipeline.id} className="px-6 py-4">
            <div className="flex items-center justify-between">
              <div className="flex items-center space-x-3">
                {getStatusIcon(pipeline.status)}
                <div>
                  <h4 className="text-sm font-medium text-gray-900">{pipeline.name}</h4>
                  <p className="text-sm text-gray-500">
                    Started: {new Date(pipeline.started_at).toLocaleString()}
                  </p>
                </div>
              </div>
              <div className="flex items-center space-x-4">
                <span className={`px-2 py-1 text-xs font-medium rounded-full ${getStatusColor(pipeline.status)}`}>
                  {pipeline.status}
                </span>
                <span className="text-sm text-gray-500">
                  Duration: {formatDuration(pipeline.duration)}
                </span>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default PipelineStatus;

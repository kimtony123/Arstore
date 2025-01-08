import React, { useEffect, useRef } from "react";
import {
  Chart,
  BarController,
  BarElement,
  CategoryScale,
  LinearScale,
  Tooltip,
  Title,
} from "chart.js";

// ✅ Register necessary components
Chart.register(
  BarController,
  BarElement,
  CategoryScale,
  LinearScale,
  Tooltip,
  Title
);

interface RatingsBarChartProps {
  ratingsData: { [key: number]: number };
}

const RatingsBarChart: React.FC<RatingsBarChartProps> = ({ ratingsData }) => {
  const chartRef = useRef<HTMLCanvasElement>(null);
  let chartInstance: Chart | null = null;

  useEffect(() => {
    if (chartRef.current) {
      // ✅ Destroy any existing Chart instance before creating a new one
      if (chartInstance) {
        chartInstance.destroy();
      }

      chartInstance = new Chart(chartRef.current, {
        type: "bar",
        data: {
          labels: ["5", "4", "3", "2", "1"], // Ratings in descending order
          datasets: [
            {
              label: "Ratings Count",
              data: [
                ratingsData[5] || 0,
                ratingsData[4] || 0,
                ratingsData[3] || 0,
                ratingsData[2] || 0,
                ratingsData[1] || 0,
              ],
              backgroundColor: [
                "#73d13d",
                "#bae637",
                "#ffec3d",
                "#ffa940",
                "#ff4d4f",
              ],
            },
          ],
        },
        options: {
          responsive: true,
          indexAxis: "y", // ✅ This makes the bars horizontal, swapping the axes
          plugins: {},
          scales: {
            x: {
              beginAtZero: true,
            },
            y: {
              reverse: true, // ✅ Correct way to reverse the Y-axis
            },
          },
        },
      });
    }

    // ✅ Cleanup to avoid the "Canvas is already in use" error
    return () => {
      if (chartInstance) {
        chartInstance.destroy();
      }
    };
  }, [ratingsData]);

  return <canvas ref={chartRef} />;
};

export default RatingsBarChart;

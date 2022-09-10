
import Chart from 'chart.js/auto'
import resolveConfig from 'tailwindcss/resolveConfig'
import tailwindConfig from '../tailwind.config.js'
const fullConfig = resolveConfig(tailwindConfig)

export default {
  mounted() {
    const colors = fullConfig.theme.colors

    const data = {
      datasets: [{
        backgroundColor: `${colors.blue['600']}22`,
        borderColor: colors.blue['600'],
      }]
    };

    const config = {
      type: 'line',
      data: data,
      options: {
        elements: {
          point: { radius: 0 },
          line: {
            tension: 0.2,
            fill: true,
          },
        },
        scales: {
          x: {
            grid: {
              display: false
            },
            display: false,
          },
          y: {
            grid: {
              borderColor: colors.gray['50'],
              borderDash: [5, 3],
            },
            suggestedMin: 0,
            position: 'right',
            ticks: {
              stepSize: 10000,
            },
          },
        },
        plugins: {
          legend: { display: false },
          tooltip: { enabled: false },
        },
      },
    };

    this.chart = new Chart(this.el, config);

    this.handleEvent("data", ({ labels, data, max }) => {
      this.chart.data.labels = labels
      this.chart.data.datasets[0].data = data
      this.chart.options.scales.y.suggestedMax = max
      this.chart.update()
    })
  },
}
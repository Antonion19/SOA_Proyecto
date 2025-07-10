document.addEventListener('DOMContentLoaded', function() {
    // Actualizar hora actual
    function updateCurrentTime() {
        const now = new Date();
        const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric', hour: '2-digit', minute: '2-digit' };
        document.getElementById('current-time').textContent = now.toLocaleDateString('es-ES', options);
    }
    updateCurrentTime();
    setInterval(updateCurrentTime, 60000); // Actualizar cada minuto

    // Gráfico de horas pico
    const peakHoursCtx = document.getElementById('peakHoursChart').getContext('2d');
    const peakHoursChart = new Chart(peakHoursCtx, {
    type: 'bar',
    data: {
        labels: ['6-7', '7-8', '8-9', '9-10', '10-11', '11-12', '12-13', '13-14', '14-15', '15-16', '16-17', '17-18', '18-19', '19-20', '20-21'],
        datasets: [{
            label: 'Accesos por hora',
            data: [45, 120, 210, 180, 150, 130, 110, 95, 85, 90, 100, 115, 125, 110, 80],
            backgroundColor: [
                '#9AB0FF', '#9AB0FF', '#3F71FF', '#3F71FF', '#9AB0FF', 
                '#9AB0FF', '#9AB0FF', '#9AB0FF', '#9AB0FF', '#9AB0FF',
                '#9AB0FF', '#9AB0FF', '#3F71FF', '#9AB0FF', '#9AB0FF'
            ],
            borderWidth: 1
        }]
    },
    options: {
        indexAxis: 'y',
        responsive: true,
        plugins: {
            legend: {
                display: false
            }
        },
        scales: {
            x: {
                beginAtZero: true,
                ticks: {
                    font: {
                        size: 8 
                    },
                    color: '#666' 
                },
                grid: {
                    color: 'rgba(0, 0, 0, 0.05)' // Líneas suaves
                }
            },
            y: {
                ticks: {
                    font: {
                        size: 8 
                    },
                    color: '#333' 
                }
            }
        }
    }
});

    // Gráfico de flujo de ingresos
    const flowCtx = document.getElementById('accessFlowChart').getContext('2d');
    const flowChart = new Chart(flowCtx, {
        type: 'line',
        data: {
            labels: ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'],
            datasets: [
                {
                    label: 'Esta semana',
                    data: [320, 290, 350, 410, 380, 210, 180],
                    borderColor: '#3F71FF',
                    backgroundColor: 'rgba(63, 113, 255, 0.1)',
                    tension: 0.3,
                    fill: true
                },
                {
                    label: 'Promedio semanal',
                    data: [280, 280, 280, 280, 280, 280, 280],
                    borderColor: '#9AB0FF',
                    borderDash: [5, 5],
                    backgroundColor: 'transparent',
                    tension: 0
                }
            ]
        },
        options: {
            responsive: true,
            plugins: {
                legend: {
                    position: 'top',
                    labels: {
                        font: {
                            size: 11 
                        },
                        padding: 20 // Espaciado
                    }
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: {
                        font: {
                            size: 9 
                        },
                        color: '#666'
                    },
                    grid: {
                        color: 'rgba(0, 0, 0, 0.05)'
                    }
                },
                x: {
                    ticks: {
                        font: {
                            size: 9 
                        },
                        color: '#333'
                    }
                }
            }
        }
    });

    // Gráfico de distribución por facultad
    const facultyCtx = document.getElementById('facultyDistributionChart').getContext('2d');
    const facultyChart = new Chart(facultyCtx, {
        type: 'doughnut',
        data: {
            labels: ['Ingeniería', 'Ciencias Exactas', 'Arquitectura', 'Economía', 'Humanidades'],
            datasets: [{
                data: [35, 25, 20, 15, 5],
                backgroundColor: [
                    '#3F71FF',
                    '#9AB0FF',
                    '#0661FC',
                    '#030238',
                    '#EAEFFD'
                ],
                borderWidth: 0
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: {
                    position: 'right',
                }
            }
        }
    });

    // Manejo de botones de filtro
    document.querySelectorAll('.time-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            document.querySelectorAll('.time-btn').forEach(b => b.classList.remove('active'));
            this.classList.add('active');
            // lógica que nohay
        });
    });

    // Manejo de botones de rango de fecha
    document.querySelectorAll('.range-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            document.querySelectorAll('.range-btn').forEach(b => b.classList.remove('active'));
            this.classList.add('active');
            // lógica 
        });
    });
});
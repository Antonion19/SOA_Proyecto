
$(document).ready(function() {
    $(".menu-item").click(function() {
        window.location.href = "Historial.jsp";
    });
});

$(document).ready(function() {
    $(".menu-item").click(function() {
        window.location.href = "Registro_1.jsp";
    });
});

function toggleSidebar() {
    const sidebar = document.querySelector('.sidebar');
    const toggleIcon = document.querySelector('.toggle-btn i');

    sidebar.classList.toggle('collapsed');
    sidebar.classList.toggle('expanded');

    if (sidebar.classList.contains('expanded')) {
        toggleIcon.classList.remove('fa-chevron-right');
        toggleIcon.classList.add('fa-chevron-left');
    } else {
        toggleIcon.classList.remove('fa-chevron-left');
        toggleIcon.classList.add('fa-chevron-right');
    }
}


document.addEventListener('DOMContentLoaded', function() {
    const menuItems = document.querySelectorAll('.menu-item');

    menuItems.forEach(item => {
        item.addEventListener('click', function() {
            // Cambiar el estado al hacer clic
            const statusIcon = this.querySelector('.status-icon');
            if (statusIcon) {
                if (statusIcon.classList.contains('fa-check')) {
                    statusIcon.classList.remove('fa-check', 'status-checked');
                    statusIcon.classList.add('fa-times', 'status-partial');
                } else if (statusIcon.classList.contains('fa-times')) {
                    statusIcon.classList.remove('fa-times', 'status-partial');
                    statusIcon.classList.add('far', 'fa-square', 'status-unchecked');
                } else {
                    statusIcon.classList.remove('fa-square', 'far', 'status-unchecked');
                    statusIcon.classList.add('fas', 'fa-check', 'status-checked');
                }

             
                const badge = this.querySelector('.menu-item-badge');
                if (badge) {
                    if (statusIcon.classList.contains('fa-check')) {
                        badge.className = 'menu-item-badge badge-checked';
                    } else if (statusIcon.classList.contains('fa-times')) {
                        badge.className = 'menu-item-badge badge-partial';
                    } else {
                        badge.className = 'menu-item-badge badge-unchecked';
                    }
                }
            }
        });
    });
});

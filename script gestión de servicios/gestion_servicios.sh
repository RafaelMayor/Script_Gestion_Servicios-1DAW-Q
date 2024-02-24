#!/bin/bash

################################
#
# Nombre: gestion_servicios.sh
# Autor: Rafael Martín Mayor <rmarmay2004@gmail.com>
         Juan Luis García Jorge <juanluisgarciajorge@gmail.com>
#
# Objetivo: Gestionar servicios.
#
# Entradas: Nombre del servicio.
# Salidas: Gestionado de dicho servicio.
#
# Historial:
#   2024-02-22: versión final
#
################################


# Función para verificar si un servicio existe
verificar_servicio() {
    servicio=$1
    if ! systemctl list-unit-files --type=service | grep -q "$servicio.service"; then
        echo "Error: El servicio $servicio no existe."
        exit 10
    fi
}

# Función para obtener el estado del servicio
obtener_estado_servicio() {
    servicio=$1
    activo=$(systemctl is-active $servicio --quiet && echo 'NO' || echo 'SÍ')
    habilitado=$(systemctl is-enabled $servicio --quiet && echo 'NO' || echo 'SÍ')
    enmascarado=$(systemctl is-masked $servicio --quiet && echo 'NO' || echo 'SÍ')

    echo "Resumen del estado del servicio $servicio:"
    echo "Activo: $activo"
    echo "Habilitado: $habilitado"
    echo "Enmascarado: $enmascarado"
}

# Función para mostrar el menú
mostrar_menu() {
    echo "Menú:"
    echo "1. Activar/Desactivar servicio"
    echo "2. Habilitar/Deshabilitar servicio"
    echo "3. Enmascarar/Desenmascarar servicio"
    echo "4. Mostrar configuración del servicio"
    echo "5. Reiniciar servicio (dejando activo)"
    echo "6. Reiniciar servicio (manteniendo estado)"
    echo "7. Aplicar cambios en la configuración (dejando activo)"
    echo "8. Aplicar cambios en la configuración (manteniendo estado)"
    echo "9. Asignar configuración vendor preset"
    echo "10. Mostrar tiempo de carga total del sistema"
    echo "11. Mostrar tiempo de carga del servicio"
    echo "12. Mostrar nivel de ejecución actual"
    echo "13. Apagar equipo"
    echo "14. Reiniciar equipo"
    echo "15. SALIR"
}

# Verificar si se proporciona un servicio como argumento o pedir al usuario
if [ -z "$1" ]; then
    read -p "Introduce el nombre del servicio: " servicio
else
    servicio=$1
fi

# Verificar si el servicio existe
verificar_servicio $servicio

# Mostrar resumen del estado del servicio
obtener_estado_servicio $servicio

# Menú principal
while true; do
    mostrar_menu

    read -p "Selecciona una opción (1-15): " opcion

    case $opcion in
        1)
            if [ "$activo" == "active" ]; then
                systemctl stop $servicio
            else
                systemctl start $servicio
            fi
            ;;
        2)
            if [ "$habilitado" == "enabled" ]; then
                systemctl disable $servicio
            else
                systemctl enable $servicio
            fi
            ;;
        3)
            if [ "$enmascarado" == "masked" ]; then
                systemctl unmask $servicio
            else
                systemctl mask $servicio
            fi
            ;;
        4)
            systemctl show $servicio
            ;;
        5)
            systemctl restart $servicio
            ;;
        6)
            systemctl try-restart $servicio
            ;;
        7)
            systemctl reload $servicio
            ;;
        8)
            systemctl try-reload $servicio
            ;;
        9)
            systemctl preset $servicio
            ;;
        10)
            systemd-analyze
            ;;
        11)
            systemd-analyze critical-chain $servicio
            ;;
        12)
            systemctl list-units --type=target
            ;;
        13)
            systemctl poweroff
            ;;
        14)
            systemctl reboot
            ;;
        15)
            echo "Saliendo del script."
            exit 0
            ;;
        *)
            echo "Opción no válida. Por favor, elige una opción del 1 al 15."
            ;;
    esac
done

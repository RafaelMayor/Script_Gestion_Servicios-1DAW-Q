#!/bin/bash

################################
#
# Nombre: gestion_servicios.sh
# Autor: Rafael Martín Mayor <rmarmay2004@gmail.com>
#
# Objetivo: Gestionar servicios.
#
# Entradas: Nombre del servicio.
# Salidas: Gestionado de dicho servicio.
#
# Historial:
#   2024-04-10: versión final
#
################################



servicio=$1

while [ -z "$servicio" ]; do
    read -p "Indique el nombre del servicio: " servicio
done

verificar_servicio=$( systemctl list-unit-files --type=service | grep "$servicio.service" )


if [ -z "$verificar_servicio" ]; then
    echo "Error: El servicio $servicio no existe."
    exit 10
fi



mostrar_estado_servicio() {
    activo=$(systemctl is-active $servicio --quiet && echo 'SÍ' || echo 'NO')
    habilitado=$(systemctl is-enabled $servicio --quiet && echo 'SÍ' || echo 'NO')
    enmascarado=$(systemctl status $servicio | grep -q "masked" && echo 'SÍ' || echo 'NO')
    echo ""
    echo "Resumen del estado del servicio $servicio:"
    echo "Activo: $activo"
    echo "Habilitado: $habilitado"
    echo "Enmascarado: $enmascarado"
    echo ""
}

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


while true; do
    mostrar_estado_servicio
    mostrar_menu

    read -p "Selecciona una opción (1-15): " opcion

    case $opcion in
        1)
            if [ "$activo" == "SÍ" ]; then
                sudo systemctl stop $servicio
            else
                sudo systemctl start $servicio
            fi
            ;;
        2)
            if [ "$habilitado" == "SÍ" ]; then
                sudo systemctl disable $servicio
            else
                sudo systemctl enable $servicio
            fi
            ;;
        3)
            if [ "$enmascarado" == "SÍ" ]; then
                sudo systemctl unmask $servicio
            else
                sudo systemctl mask $servicio
            fi
            ;;
        4)
            systemctl show $servicio
            ;;
        5)
            sudo systemctl restart $servicio
            ;;
        6)
            sudo systemctl try-restart $servicio
            ;;
        7)
            sudo systemctl reload-or-restart $servicio
            ;;
        8)
            sudo systemctl try-reload-or-restart $servicio
            ;;
        9)
            sudo systemctl preset $servicio
            ;;
        10)
            systemd-analyze
            ;;
        11)
            systemd-analyze blame | grep "$servicio"
            ;;
        12)
            runlevel
            ;;
        13)
            sudo systemctl poweroff
            ;;
        14)
            sudo systemctl reboot
            ;;
        15)
            exit
            ;;
        *)
            echo "Opción no válida. Por favor, elige una opción del 1 al 15."
            ;;
    esac
done

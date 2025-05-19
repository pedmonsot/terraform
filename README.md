# 5.1

## Provisionar una máquina virtual Ubuntu 24.04 en Virtualbox mediante Terraform

Al principio, al ejecutar `terraform init`, surgió un problema al intentar usar el proveedor `virtualbox` desde el registro oficial de Terraform. El error indicaba que no existía dicho proveedor en el repositorio de HashiCorp, por lo que fue necesario replantear el enfoque utilizando Vagrant como intermediario.

![imagen 1](./imagenes/2025-05-16_18-52.png)

Una vez corregido el archivo `main.tf` para trabajar con `null_resource` y `local-exec`, la inicialización de Terraform se completó correctamente, permitiendo continuar con la planificación y despliegue de la máquina virtual.

![imagen 2](./imagenes/2025-05-16_19-02.png)

Después del despliegue, se verificó el correcto arranque de la máquina virtual utilizando el comando `vagrant ssh`. Esto permitió acceder al sistema Ubuntu 22.04.5 dentro de VirtualBox y confirmar que estaba activo y funcionando correctamente.

![imagen 3](./imagenes/2025-05-16_19-28.png)

Una vez todo listo, se ejecutó `terraform apply` para aplicar los cambios definidos en el archivo `main.tf`, lo que provocó que se ejecutara el comando `vagrant up` desde Terraform. Se puede ver el progreso del despliegue de la box `ubuntu/jammy64` y cómo se va creando la VM paso a paso.

![imagen 4](./imagenes/2025-05-16_19-28_1.png)

Durante el proceso apareció un problema con los plugins de Vagrant. Concretamente, uno de ellos (`vagrant-reload`) no estaba disponible o presentaba conflictos de versión. Este error interrumpió el proceso de despliegue.

![imagen 5](./imagenes/2025-05-16_19-29.png)

Para resolverlo, se ejecutó `vagrant plugin repair`, lo cual inició el proceso de reparación de los plugins instalados en el sistema. Sin embargo, esta reparación no logró solucionar el error por completo, y Vagrant recomendó hacer una reinstalación completa.

![imagen 6](./imagenes/2025-05-16_19-30.png)

Finalmente, se procedió a ejecutar `vagrant plugin expunge --reinstall` para forzar la eliminación y reinstalación de todos los plugins de Vagrant. Aunque al principio se rechazó la opción por defecto (`N`), al repetir el proceso, se logró completar la reinstalación correctamente.

![imagen 7](./imagenes/2025-05-16_19-30_1.png)

Después de todos los pasos anteriores, la máquina virtual apareció en VirtualBox en estado **"Corriendo"**, lo que confirmó que el despliegue fue exitoso y que el entorno estaba listo para ser configurado posteriormente con Ansible.

![imagen 8](./imagenes/2025-05-16_19-36.png)

# 5.2

## Configurar una máquina virtual Ubuntu 24.04 en Virtualbox mediante Ansible.
  -Realizar update & upgrade del sistema de forma automática.
  -Instalar el servicio apache.

Lo primero fue inicializar el entorno de Terraform en la nueva carpeta correspondiente.

![imagen 1](./imagenes/2025-05-19_11-50.png)

A continuación, ejecutamos `terraform apply` para lanzar la máquina virtual desde el `Vagrantfile` especificado. Terraform mostró el plan de ejecución y solicitó confirmación para continuar.

![imagen 2](./imagenes/2025-05-19_11-52.png)

Una vez aceptado el plan (`yes`), comenzó el proceso de despliegue. Tras unos segundos, Terraform informó que el recurso fue creado correctamente, confirmando que la máquina virtual fue puesta en marcha con éxito.

![imagen 3](./imagenes/2025-05-19_11-52_1.png)

Después de la creación, accedimos a la máquina mediante SSH usando la clave privada generada por Vagrant. Se pudo comprobar que el sistema estaba operativo.

![imagen 4](./imagenes/2025-05-19_11-56.png)

Antes de aplicar el playbook de Ansible, verificamos que Apache aún no estaba instalado. Al comprobar el estado del servicio `apache2`, el sistema respondió que no existía.

![imagen 5](./imagenes/2025-05-19_11-58.png)

Ejecutamos el `playbook.yml` con Ansible, el cual realizaba tres tareas, actualizar el sistema, realizar un upgrade y finalmente instalar Apache. El resultado mostró que todo se aplicó correctamente, y Apache fue marcado como cambiado (instalado).

![imagen 6](./imagenes/2025-05-19_12-02.png)

Volvimos a verificar el estado del servicio `apache2`, y ahora sí apareció como activo y corriendo, lo cual confirmó que la instalación se realizó correctamente.

![imagen 7](./imagenes/2025-05-19_12-03.png)

También realizamos una prueba desde el host usando `curl` para comprobar que el servidor web estaba funcionando y devolviendo la página por defecto de Apache.

![imagen 8](./imagenes/2025-05-19_12-04.png)

Por último, confirmamos desde VirtualBox que la máquina virtual `ubuntu24` seguía corriendo correctamente después de todas las configuraciones aplicadas.

![imagen 9](./imagenes/2025-05-19_12-04_1.png)

# 5.3

## Configurar una máquina virtual Ubuntu 24.04 en Virtualbox mediante Ansible.
  -Crear un index.html con el contenido: ‘Ansible rocks’ en el directorio del servidor web para poder ser mostrado y reiniciar el servicio.
  -Realizar un curl al servidor web y verificar el mensaje ‘Ansible rocks’.

En este apartado, se reutilizó el mismo procedimiento con Terraform explicado en el punto anterior para crear una nueva máquina virtual. Al igual que antes, se utilizaron los comandos `terraform init` y `terraform apply` para iniciar el entorno y lanzar la máquina desde el `Vagrantfile`.

Lo que cambia en este caso es la configuración realizada con Ansible. En esta ocasión, el objetivo era personalizar el contenido del servidor web, creando un archivo `index.html` con el mensaje “Ansible rocks”, reiniciar Apache y verificar que todo funcione correctamente.

Al ejecutar el playbook personalizado, Ansible realizó los siguientes pasos sobre la nueva máquina `ubuntu-web`:
- Instaló Apache.
- Escribió el contenido “Ansible rocks” en `/var/www/html/index.html`.
- Reinició el servicio de Apache.
- Ejecutó un `curl` para comprobar que el contenido era el esperado.

Todos los pasos se completaron correctamente, como se muestra en el resultado del playbook:

![imagen 1](./imagenes/2025-05-19_12-22.png)

Desde el host, se verificó el resultado ejecutando `curl` sobre la IP privada de la máquina `192.168.56.102`, y se devolvió el mensaje “Ansible rocks”, confirmando que el archivo se creó correctamente y Apache lo estaba sirviendo.

![imagen 2](./imagenes/2025-05-19_12-23.png)

Finalmente, se comprobó en VirtualBox que la máquina `ubuntu-web` seguía corriendo correctamente tras aplicar todos los cambios.

![imagen 3](./imagenes/2025-05-19_12-24.png)





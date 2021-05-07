# DevOps Pipeline App Example

En este mini proyecto vamos ilustrar de forma rapida y sencilla como proveernos de infraestructura como codigo, teniendo una aplicacion senmcilla en nodejs sencilla usaremos docker, kubernetes, teraform y azure cloud.

## Comenzando 🚀

Puedes obtener el codigo clonando el code este repositorio y ejecutando los pasos descritos a continuacion.


### Pre-requisitos 📋

Debemos tener en cuenta que este tutorial estaremos trabajnado en sistema operativo linux para este caso Ubuntu, asi como tener antes instalado nodejs(npm), docker entre otros.

```
npm -version
nodejs --version
```

### Comenzamos 🔧

Creaqmos una carperta con el nombre de nuestro proyecto para este caso la nombramos "code" 

```
mkdir code
```
Luego los vamos a esa carpeta 

```
cd code
```

bien, ahora creamos los archivos y generamos las dependencias necesrias de nodejs para correr nuestra app_

```
touch app.js
touch Dockerfile
touch .dockerignore
touch package.json
```
el contenido de cada archivo los podemos encontrar en el repositorio, ahora generamos dependencias y arrancamos la app
```
sudo npm install express -g
npm init -y
```
Si vas a un browser y miras la url http://localhost:3000 veras el contenido que hemos renderizado en el archivo app.js(para este ejemplo sencillo)


## Docker ⚙️

Una vez estemos en la carpeta raiz del proyecto, es decir, en la carpeta code vamos a crear la imagen nuestra aplicacion.
```
docker build -t getaclubapp .
```
Con esto hemos creado la imagen, ahora vamos correr nuestra app con base a esa imagen, para esto ejecutamos el siguiente comando:

```
docker run -it -p 3000:3000 getaclubapp
```
Con este comando mapeamos el puerto 3000 del docker al puerto de nuestro host para que la apliacion corre en el mismo púerto, con esto puedes ir al browser  y escribir la direccion url http://localhost:3000 y vemos que ha cargado nuestra app desde la imagen de docker.

Tambien puesdes ver los archivos de configuracion en la carpeta docker de este repositorio.



### Kubernetes ⚙️

Con lo anterior ya tenemos encapsulada en una img nuestra app ahora vamos a configurar los archivos necesrios para tener nuestro cluster listo para aplicacion.


Ahora bien, para entender un poco primero vamos a proveernos se nuestro cluster en local para que podamos tener un preview de nuetra infraestructura, para esto vamos a utilizar una  herramienta de línea de comandos de Kubernetes, kubectl, para desplegar y gestionar aplicaciones en Kubernetes. Usando kubectl, puedemos inspeccionar recursos del clúster; crear, eliminar, y actualizar componentes; explorar tu nuevo clúster y arrancar nuestra aplicacion, bien vamos:

primero instalamos minukube con el siguiente comando:

```
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
  && chmod +x minikube
# Arrancamos minikube
./minikube start
```
ahora, vamos a instalar el cliente de kubectl de la siguiente manera:
```
# Aca lo descargamos
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl

# Importante, le damos permisos de ejecución al archivo
chmod 777 ./kubectl

# Super!!!, ahora lo llevamos a la carpeta /usr/local/bin para que esté disponible en nuestra sesion, sin mas
sudo mv ./kubectl /usr/local/bin/kubectl

#Listo ahora para confirmar vemos la version que instalamos con el siguietne comando:
kubectl version

# o vemos que nodes que tenemos
ubectl get nodes
```

Como hemos visto con el ultimo comando auin nos lista ningun nodo aparte del de minikube que ya habiamos instalado con anterioridad.
Bien, ahora, vamos a desplegar nuestra imagen de docker que ya teniamos antes creada en la sesion de Docker, 

Importante: Recordemos que Kubernes se maneja arquitectura master/slave para los pods, el master distribuye los trabajos a ejecutar y los manda a los esclavos para que ejecuten la tarea, esto lo hace teniendo en cuenta CPU, memoria, etc, estas reglas tambien las podemos configurar, bien hagamos nuestro nuestro despliegue.

```
# despues de la sentencia deployment le damos un nombre a nuestra cluster "getaclubapp" y en --image le pasamos el nombre de nuestra imagen "getaclubapp" 
kubectl create deployment getaclubapp –image=getaclubapp
```

listo ahora si volvemos a ejecutar el comando:

```
# Para ver que nodes que tenemos
ubectl get nodes

# o si queremos ver mas detalles, incluso los eventos o secuencia que ha ejecutada(pulling, pulled, create, started)
kubectl describe nodes
```

Vamos que hemos creado de forma manual nuestra app, ahora vamos a crear el msimo proceso pero a partir de un archivo .yaml para automatizar un poco mas el proceso.

Vamos a crear la carpera kubernetes dentro del proyecto(para falicidad) en esa carpeta creamos el archivo deployment.getaclubapp.yml, aca definimos nuestra aplicacion dentro del cluster, lke damos el tipo Pod, los metadatos el nombre de nuestra app y las especificaciones, en estas especificaciones le decimos que despliegue un contenedor de nombre getaclubapp, que use nuestra imagen que tenemos en docker en este caso le pasamos el mismo nombre y que use el puerto 80, por ahora solo tendra 1 solo contenedor para neustro ejemplo o para nuestra app "getaclubapp" recordemos que cada pods queda en un contenedor(maquina aparte) por lo pronto no tendremos problema

Ahora ejecutamos kubectl y le pasamos el archivo, de la sigueitne manera:

```
kubectl apply -f deployment.getaclubapp.yml
```

Si volvemos a ejecutar
```
# Para ver que nodes que tenemos
ubectl get nodes

# o si queremos ver mas detalles, incluso los eventos o secuencia que ha ejecutada(pulling, pulled, create, started)
kubectl describe nodes
```

Vemos que nos muestra nuestra app desplegada y ademas nos mueysra el flujo completo que hemos hecho.

Pero, aun no podemos ver nuestra app,¿ pero por que? ya esta desplegada nuestra app aun no la hemos expuesto y tenemos que exponerla para que se pueda ver desde un browser, y esto lo hacemos ejecutando el siguietne comando:

```
kubectl expose deployment getaclubapp --type=LoadBalancer --port=80
```

Vale, como vemos despues del deployment le decimos que pods debemos exponer, el tipo de Balance que debe tener(que use round robin) automatico, y por ultimo le pasamos el puerto.

si ejecutamos ahora el siguietne comando:


```
kubectl get services
```

Vemos la descriocion pero ahora tiene una externa(pero ten en cuanta que como usamos minikube no tendremos una ip externa publica) pero ya demos nuestra app

Por ultimo para automarizar mas, vamos a escalar nuestra app hacia 3 replicas de pods con el siguietne comando:

```
kubectl scale deployment --replicas=2 getaclubapp
```
Si ejecutamos
```
kubectl get pods
```

Vemos que en la columna READY el escalamiento que le hemos pasado. tambien esta auto-escala la podemos hacer en cualquier instante para aumentar las replicas, simplemente cambiamos a cuantas replicas necesitamos para 4 seria --replicas=4 para 6 sera --replicas=6 y asi sucesivamente.

Tambien puesdes ver los archivos de configuracion en la carpeta kubernetes de este repositorio.


### Terraform 📦

Anteriormente lo que hemos hecho es en nuestro local establecer el cluster con escalamiento de Kubernetes, ahora vamos a utilizar Terraform para abastecernos de la infraestructura como codigo, es decir, vamos a tener un fichero de configuracion a partir de proveedores que infraestructura necesitamos, para este ejempo lo replicaremos para el cloud de Azure-Cloud de Microsoft

Bien vamos!!!

Para esto creamos la carpeta terraform en el proyecto(para mas faciliad) y en esta carpeta creamos el archivo main.tf, pero antes vamos instalar terraform

Importante: vamos  a la pagina de terraform y descargamos el fichero de instalacion, en este caso descargamos la versiond e Linux 64 que estamos usando, lo descomprimimos y nos da un script abrimos una terminalñ desde aca y  y ejecutamos

```
# Primero lo movemos a la carpeta /usr/local/bin para falicidad
sudo mv terraform /usr/local/bin

# Ahora vemos que version tenemos instalada con:
terraform -v
```
Importante: Recordemos que en terraform existen dos conceptos muy importante apra tener en cuenta, primero los proveedores quienes son los que nos van a dar en si la infraestructura, es decir, donde va estar virtualmente nuestro cluster y segundo los recursos o provisionador, estos son en si los servidores o maquines red etc.

Para este caso vamos consfigurar el proveedor de Azure

```
provider "azurerm" {
  features {}
}
```

Ahora configuramos el grupo de instancias o grupo de recursos

```
#Config resource group
resource "azurerm_resource_group" "getaclubapp" {
  name     = "${var.prefix}-k8s-resources"
  location = var.location
}
```

configuramos la red para beneficio o a conveniencia segun lo que requerido:

```
#Config resource network
resource "azurerm_virtual_network" "getaclubapp" {
  name                = "${var.prefix}-network"
  location            = azurerm_resource_group.getaclubapp.location
  resource_group_name = azurerm_resource_group.getaclubapp.name
  address_space       = ["10.1.0.0/166"]
}
```

Ahora configuramos nuestra app para el cluster de kubernetes:

```
#Config resource App (getaclubapp)
resource "azuread_application" "getaclubapp" {
  name                       = "${var.prefix}-k8s-app"
  homepage                   = "http://getaclubapp/"
  identifier_uris            = ["http://getaclubapp"]
  reply_urls                 = ["http://getaclubapp"]
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = true
}
```
configuramos nuestro servicio plan:

```
#Config resource  Azure plan service
resource "azuread_service_plan" "getaclubapp" {
  application_id               = "${azuread_application.getaclubapp.application_id}"
  app_role_assignment_required = false
  resource_group_name = azurerm_resource_group.getaclubapp.name
  sku{
    tier = "Free"
    size = "1"
  }
}
```

Ahora configuracmos nuestro app como servicio

```
#Config resource  Azure service to make
resource "azuread_service" "getaclubapp" {
  name     = "getaclubapp"
  location = azurerm_resource_group.getaclubapp.location
  resource_group_name = azurerm_resource_group.getaclubapp.name
  app_service_plan_id = azurerm_resource_group.getaclubapp.id
}
```

Bien, ahora viene la magia del kubernetes, porque vamos a provisionarnos de kubernetes para asegurara nuetsra app en cluster dentro de Azure

```
#Config resource  kubernetes cluster
resource "azurerm_kubernetes_cluster" "getaclubapp" {
  name                = "${var.prefix}-k8s"
  location            = azurerm_resource_group.getaclubapp.location
  resource_group_name = azurerm_resource_group.getaclubapp.name
  dns_prefix          = "${var.prefix}-k8s"

  default_node_pool {
    name           = "system"
    node_count     = 1
    vm_size        = "Standard_DS2_v2"
    vnet_subnet_id = azurerm_subnet.internal.id
    type           = "VirtualMachineScaleSets"
  }

  network_profile {
    network_plugin = "kubenet"
    load_balancer_sku = "standard"
    outbound_type = "userDefinedRouting"
  }

  service_principal {
    client_id = azuread_service_principal.getaclubapp.application_id
    client_secret = var.service_principal_pw
  }

  addon_profile {
		aci_connector_linux {
		enabled = false
		}
		azure_policy {
		enabled = false
		}

		http_application_routing {
		enabled = false
		}

		kube_dashboard {
		enabled = true
		} 
  }
}
```

Como vemos a este u8ltimo le indicamos que maquinas o tipo de pods vamos atener en nuestro cluster, configurandole el servicio principal antes declarado, la red, el pool de nodos la locacion etc, tambien tenmos que algunos datos se pasan por configuracion de variables las cuale sestan declaradas en el archivo variable.tf

Bueno, como bien sabemos terraform tiene como pipeline o ciclo de vida de inicializar, planificar, aplicar y destruir nuestra infraestructura, en ese orden de ideasa ahora vamos a incializar:

```
terraform init
```

Aca vemos que descargo automaticamente los plugin y dependencias necesarias para trabajar 

Ahora vamos a planificar, ejecutando:

```
terraform plan
```

Importante:: A este punto pueda que nos pida login, si es que aun no lo hemos configurado, para eso descargamos el CLI lo instalamos y ejecutamos el comando:
```
az login
```
Este comando te abrira el browser donde te pedira que te logues y que apruebas con tu cuenta dodne tienes la suscripcion del proyecto en azure.
para las salidas de operaciones tenemos el archivo outputs.tf, ahora bien primero planificamos para primero tener los recueros definidos y asi evitamos sobve costos y elimiar algo que debemos 😊

Ahora vamos a la siguiente step del clico de vida el cual es aplicar

```
terraform apply -auto-approve
```

Le pasamos el parametro -autoa-approve para forzar los cambios necesarios automaticamente, esto pueda que demore un rato.

Al terminar si vamos a la consola de nuestro proyecto o panel de Azure https:/portal.azure.com de nuestro proyecto en la sesion de Resources groups en la lista de items vemos nuestro recurso debe aprecer con el nombre gectacapp-k8s-app si le damos click nos miuestra mas detalles.

y eso es todo con esto vemos un sencillo ejemplo de como realizar DevOps infraestructura como codigo.😊 😊 😊


## Wiki 📖

A este material te puedes apoyar con las siguientes links:

https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt
https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
https://kubernetes.io/es/docs/tasks/tools/
https://www.docker.com/
https://nodejs.org/es/


## Autor ✒️

* **Juan Carlos Orozco N.** 😊

## Licencia 📄

Este proyecto está bajo la Licencia (Tu Licencia) - mira el archivo [LICENSE.md](LICENSE.md) para detalles

# Registry Setup On E2E

- create cluster
- install nginx with helm
    [kubernetes.github.io/ingress-nginx/deploy/](https://kubernetes.github.io/ingress-nginx/deploy/)
    ```sh
    helm upgrade --install ingress-nginx ingress-nginx \
        --repo https://kubernetes.github.io/ingress-nginx \
        --namespace ingress-nginx --create-namespace
    ````
- install redis with helm
    [bitnami.com/stack/redis/helm](https://bitnami.com/stack/redis/helm)
    ```yml
    # values.yml
    master:
    persistence:
        enabled: false

    replica:
    persistence:
        enabled: false
    ```

    ```sh
    helm install redis oci://registry-1.docker.io/bitnamicharts/redis -f values.yml --namespace=kl-core
    ```
- create vpn device on platform cluster

- install current chart [create .values.yaml file with credentials and configurations]
    ```sh
    helm upgrade --install registry -f .values.yaml --namespace kl-core .
    ```

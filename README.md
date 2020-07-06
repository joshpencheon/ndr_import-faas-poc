# OpenFaaS proof-of-concept

This project is to demonstrate a Ruby script running as an OpenFaaS function.

This was deployed on a Kubernetes (k3s) cluster, running on RPi4s.
Additionally, one of the RPis ran docker as a build environment.

## Setup

The assumption is that the OpenFaaS gateway is forwarded to 8080 using e.g.

```
$ kubectl port-forward -n openfaas svc/gateway 8080:8080
```

The Docker instance was used to provide an ephemeral registry to which OpenFaaS could push function images:

```
pi$ docker run -p 8080:8080 127.0.0.1:5000/ruby-demo
```

## Pushing a new function

Log in the `faas-cli` client to OpenFaaS that's running in Kubernetes:

```
$ PASSWORD=$(kubectl get secret -n openfaas basic-auth -o jsonpath="{.data.basic-auth-password}" | base64 --decode; echo)
$ echo -n $PASSWORD | faas-cli login --username admin --password-stdin
```

Build a new function, add to the registry, and deploy it:

```
# --build-option dev pulls in additional packages to allow e.g. nokogiri to compile
$ faas-cli up -f ruby-demo.yml --build-option dev
```

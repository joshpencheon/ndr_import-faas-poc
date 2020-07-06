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
pi$ docker run -d -p 5000:5000 --name registry registry:2
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

## Invoke a function!

Check that the deployment is ready:

```
$ kubectl get deployment -o wide -n openfaas-fn ruby-demo
NAME        READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES                            SELECTOR
ruby-demo   1/1     1            1           21h   ruby-demo    127.0.0.1:5000/ruby-demo:latest   faas_function=ruby-demo
```

Call the function API:

```
$ curl -s http://127.0.0.1:8080/function/ruby-demo --data $'1,2\n3,4' | jq
[
  {
    "field_one": "1",
    "field_two": "2",
    "rawtext": {
      "column_one": "1",
      "column_two": "2"
    }
  },
  {
    "field_one": "3",
    "field_two": "4",
    "rawtext": {
      "column_one": "3",
      "column_two": "4"
    }
  }
]
```

apiVersion: apps/v1
kind: Deployment
metadata:
  name: flask-app-deployment
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: flask-app
  template:
    metadata:
      labels:
        app: flask-app
    spec:
      containers:
        - name: flask-app
          image: ${IMAGE}
          ports:
            - containerPort: 80
apiVersion: v1
kind: Service
metadata:
  name: flask-app-service
  namespace: default
spec:
  type: ClusterIP
  ports:
    - port: 80
      targetPort: 80
  selector:
    app: flask-app
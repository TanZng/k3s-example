# Simple example

You need docker and kubectl==1.24.4 installed

```bash
docker build -t localhost:5000/go-hello-world .
docker compose up -d
docker push localhost:5000/go-hello-world
```
Check the local Repository

```bash
http://localhost:5000/v2/_catalog
```

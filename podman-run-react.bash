podman build --no-cache --rm -f Containerfile -t react:demo .
podman run --interactive --tty -p 9090:80 react:demo
echo "browse http://localhost:9090/?username=test"

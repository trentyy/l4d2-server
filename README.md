# l4d2-server
build image:
`DOCKER_BUILDKIT=1 docker build . -t l4d2_server`
run server:
`cd l4d2-server`
`docker run -it -u=steam -p 27015:27015/tcp -p 27015:27015/udp --mount type=bind,source=$PWD/workshop,target=/home/steam/l4d2_server/left4dead2/addons/workshop --name=l4d2_server l4d2_server`
or
`docker run -u=steam -p 27015:27015/tcp -p 27015:27015/udp --mount type=bind,source=$PWD/workshop,target=/home/steam/l4d2_server/left4dead2/addons/workshop --name=l4d2_server l4d2_server`

current problem:
* abm version:
crash when using command `/abm-mk 4 2`, `/abm-model` change model to zoy
* multislot:
when enter the safe house, change to random(?) map other than continue map

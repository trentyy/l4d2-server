FROM cm2network/steamcmd:root

EXPOSE 27015
EXPOSE 27015/udp
WORKDIR /home/steam/steamcmd

ENV L4D2_FOLDER_NAME=l4d2_server
ENV L4D2_FOLDER_PATH=/home/steam/${L4D2_FOLDER_NAME}
ENV COMPILE_PATH=/home/steam/${L4D2_FOLDER_NAME}/left4dead2/addons/sourcemod/scripting/

# download l4d2
RUN apt update && apt install unzip
USER steam
RUN /home/steam/steamcmd/steamcmd.sh +force_install_dir /home/steam/${L4D2_FOLDER_NAME} +login anonymous  +app_update 222860 validate +quit

ADD --chown=steam ./mods /home/steam/mods/
ADD --chown=steam ./cfg /home/steam/cfg/

# install mods and config
ENV SM_GAMEDATA=${L4D2_FOLDER_PATH}/left4dead2/addons/sourcemod/gamedata
WORKDIR /home/steam
RUN tar -C ./${L4D2_FOLDER_NAME}/left4dead2 -zxvf ./mods/mmsource-1.11.0-git1148-linux.tar.gz \
    && tar -C ./${L4D2_FOLDER_NAME}/left4dead2 -zxvf ./mods/sourcemod-1.11.0-git6917-linux.tar.gz
ADD --chown=steam https://forums.alliedmods.net/attachment.php?attachmentid=195507&d=1666297147 ./left4dhooks.zip
ADD --chown=steam https://forums.alliedmods.net/attachment.php?attachmentid=189617&d=1622900635 ${SM_GAMEDATA}/abm.txt
ADD --chown=steam https://forums.alliedmods.net/attachment.php?attachmentid=189616&d=1662444298 ${COMPILE_PATH}/abm.sp

RUN cp ./cfg/server.cfg ${L4D2_FOLDER_NAME}/left4dead2/server.cfg \
    && cp ./cfg/admins_simple.ini ${L4D2_FOLDER_PATH}/left4dead2/addons/sourcemod/configs/admins_simple.ini \
    && unzip ./left4dhooks.zip  -d ./l4d2_server/left4dead2/addons/ \
    && cd ${COMPILE_PATH} \
    && ./compile.sh ./abm.sp \ 
    && mv ./compiled/* ../plugins/ \
    && rm ./*.sp 
RUN unzip ./mods/l4d2_bugfixes.zip  -d ./${L4D2_FOLDER_NAME}/left4dead2/
RUN cd /home/steam/mods/Upgrade_packs_BUG_FIX \
    && cp ./upgradepackfix.txt ${SM_GAMEDATA} \
    && cp ./l4d2_upgradepackfix.sp ${COMPILE_PATH}/ \
    && cd ${COMPILE_PATH} \
    && ./compile.sh ./l4d2_upgradepackfix.sp \ 
    && mv ./compiled/* ../plugins/ \
    && rm ./*.sp
RUN cd /home/steam/mods/Infected_Spawn_API_v1.6.1 \
    && cp ./SampleInfectedAPI.sp ${COMPILE_PATH} \
    && cp ./l4d2_InfectedSpawnApi.inc ${COMPILE_PATH}/include \
    && cp ./InfectedAPI.txt ${SM_GAMEDATA} \
    && cd ${COMPILE_PATH} \
    && ./compile.sh ./SampleInfectedAPI.sp \
    && mv ./compiled/* ../plugins/ \
    && rm ./*.sp
# use same InfectedAPI.txt
RUN cd /home/steam/mods/Infected_Fix_Spawn_1.3.1 \
    && cp ./l4d2_InfectedFixSpawn.sp ${COMPILE_PATH} \
    && cd ${COMPILE_PATH} \
    && ./compile.sh ./l4d2_InfectedFixSpawn.sp \ 
    && mv ./compiled/* ../plugins/ \
    && rm ./*.sp
RUN unzip ./mods/l4d2_defibfix.zip -d ./${L4D2_FOLDER_NAME}/left4dead2


WORKDIR /home/steam/${L4D2_FOLDER_NAME}
# ENTRYPOINT ["/bin/bash"]
ENTRYPOINT ["./srcds_run", "-game", "left4dead2", "+exec", "server.cfg"]

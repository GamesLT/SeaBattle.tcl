FROM phusion/baseimage:latest

EXPOSE 6667/tcp

ARG SEABATTLE_BOT_PASS=botsky
ARG SEABATTLE_LANGUAGE=en
ARG SEABATTLE_GRID_HORIZONTAL_WORD=games
ARG SEABATTLE_GRID_VERTICAL_WORD=12345
ARG SEABATTLE_SHIPS_COUNT=5
ARG SEABATTLE_NICKSERV_AUTH_NEEDED=false
ARG SEABATTLE_NICKSERV_HOST=irc.data.lt
ARG SEABATTLE_NICKSERV_TIMEOUT=5
ARG SEABATTLE_LOG_QUERIES=no
ARG EGGDROP_BOTNET_NICK=Seabattle
ARG EGGDROP_PROTECT_TELNET=0
ARG EGGDROP_DCC_SANITY_CHECK=0
ARG EGGDROP_IDENT_TIMEOUT=5
ARG EGGDROP_REQUIRE_PARTY=0
ARG EGGDROP_OPEN_TELNETS=0
ARG EGGDROP_STEALTH_TELNETS=0
ARG EGGDROP_USE_TELNET_BANNER=0
ARG EGGDROP_CONNECTION_TIMEOUT=90
ARG EGGDROP_DCC_FLOOD_THR=3
ARG EGGDROP_TELNET_FLOOD=5:60
ARG EGGDROP_PARANOID_TELNET_FLOOD=1
ARG EGGDROP_RESOLVE_TIMEOUT=15
ARG EGGDROP_MAX_DCC=50
ARG EGGDROP_ALLOW_DK_CMDS=1
ARG EGGDROP_MODULES="dns channels server ctcp irc notes console transfer share"
ARG EGGDROP_CHECK_MODULES=blowfish
ARG EGGDROP_NICK=SeaBattle
ARG EGGDROP_ALTNICK=SeaBattleBot
ARG EGGDROP_ADMIN=owner
ARG EGGDROP_REAL="Bot for Games.lt"
ARG EGGDROP_SERVERS=irc.data.lt
ARG EGGDROP_CHANNELS="#seabattle"
ARG EGGDROP_NET_TYPE=5
ARG EGGDROP_LISTEN_USERS_PORT=3333
ARG EGGDROP_LISTEN_BOTS_PORT=3333
ARG EGGDROP_OWNERS=""
ARG EGGDROP_SYSTEM_SCRIPTS="alltools action.fix compat userinfo"
ARG EGGDROP_SYSTEM_HELPS=userinfo
ARG SEABATTLE_DB_USER
ARG SEABATTLE_DB_PASS
ARG SEABATTLE_DB_HOST
ARG SEABATTLE_DB_NAME

ENV SEABATTLE_BOT_PASS=${SEABATTLE_BOT_PASS} \
    SEABATTLE_DB_USER=${SEABATTLE_DB_USER} \
    SEABATTLE_DB_PASS=${SEABATTLE_DB_PASS} \
    SEABATTLE_DB_HOST=${SEABATTLE_DB_HOST} \
    SEABATTLE_DB_NAME=${SEABATTLE_DB_NAME} \
    SEABATTLE_LANGUAGE=${SEABATTLE_LANGUAGE} \
    SEABATTLE_GRID_HORIZONTAL_WORD=${SEABATTLE_GRID_HORIZONTAL_WORD} \
    SEABATTLE_GRID_VERTICAL_WORD=${SEABATTLE_GRID_VERTICAL_WORD} \
    SEABATTLE_SHIPS_COUNT=${SEABATTLE_SHIPS_COUNT} \
    SEABATTLE_NICKSERV_AUTH_NEEDED=${SEABATTLE_NICKSERV_AUTH_NEEDED} \
    SEABATTLE_NICKSERV_HOST=${SEABATTLE_NICKSERV_HOST} \
    SEABATTLE_NICKSERV_TIMEOUT=${SEABATTLE_NICKSERV_TIMEOUT} \
    SEABATTLE_LOG_QUERIES=${SEABATTLE_LOG_QUERIES} \
    EGGDROP_BOTNET_NICK=${EGGDROP_BOTNET_NICK} \
    EGGDROP_PROTECT_TELNET=${EGGDROP_PROTECT_TELNET} \
    EGGDROP_DCC_SANITY_CHECK=${EGGDROP_DCC_SANITY_CHECK} \
    EGGDROP_IDENT_TIMEOUT=${EGGDROP_IDENT_TIMEOUT} \
    EGGDROP_REQUIRE_PARTY=${EGGDROP_REQUIRE_PARTY} \
    EGGDROP_OPEN_TELNETS=${EGGDROP_OPEN_TELNETS} \
    EGGDROP_STEALTH_TELNETS=${EGGDROP_STEALTH_TELNETS} \
    EGGDROP_USE_TELNET_BANNER=${EGGDROP_USE_TELNET_BANNER} \
    EGGDROP_CONNECTION_TIMEOUT=${EGGDROP_CONNECTION_TIMEOUT} \
    EGGDROP_DCC_FLOOD_THR=${EGGDROP_DCC_FLOOD_THR} \
    EGGDROP_TELNET_FLOOD=${EGGDROP_TELNET_FLOOD} \
    EGGDROP_PARANOID_TELNET_FLOOD=${EGGDROP_PARANOID_TELNET_FLOOD} \
    EGGDROP_RESOLVE_TIMEOUT=${EGGDROP_RESOLVE_TIMEOUT} \
    EGGDROP_MAX_DCC=${EGGDROP_MAX_DCC} \
    EGGDROP_ALLOW_DK_CMDS=${EGGDROP_ALLOW_DK_CMDS} \
    EGGDROP_MODULES=${EGGDROP_MODULES} \
    EGGDROP_CHECK_MODULES=${EGGDROP_CHECK_MODULES} \
    EGGDROP_NICK=${EGGDROP_NICK} \
    EGGDROP_ALTNICK=${EGGDROP_ALTNICK} \
    EGGDROP_ADMIN=${EGGDROP_ADMIN} \
    EGGDROP_REAL=${EGGDROP_REAL} \
    EGGDROP_SERVERS=${EGGDROP_SERVERS} \
    EGGDROP_CHANNELS=${EGGDROP_CHANNELS} \
    EGGDROP_NET_TYPE=${EGGDROP_NET_TYPE} \
    EGGDROP_LISTEN_USERS_PORT=${EGGDROP_LISTEN_USERS_PORT} \
    EGGDROP_LISTEN_BOTS_PORT=${EGGDROP_LISTEN_BOTS_PORT} \
    EGGDROP_OWNERS=${EGGDROP_OWNERS} \
    EGGDROP_SYSTEM_SCRIPTS=${EGGDROP_SYSTEM_SCRIPTS} \
    EGGDROP_SYSTEM_HELPS=${EGGDROP_SYSTEM_HELPS} \
    DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y telnet sudo mysqltcl eggdrop mysql-client netcat && \
    mkdir -p /srv/eggdrop/data && \
    mkdir -p /srv/eggdrop/apps

COPY ./docker-data/configs/eggdrop.conf /etc/eggdrop.conf
COPY ./docker-data/scripts/entrypoint.sh /usr/bin/run.sh
COPY ./install.sql /srv/backups/install.sql
COPY ./src/ /srv/eggdrop/apps/seabattle/

RUN chmod +x /usr/bin/run.sh && \
    apt-get clean -y && \
    apt-get autoclean -y && \
    apt-get autoremove -y && \
    useradd -r -U -M -s /bin/false eggdrop && \
    chown -R eggdrop:eggdrop /srv/eggdrop && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENTRYPOINT ["/usr/bin/env", "bash", "/usr/bin/run.sh"]

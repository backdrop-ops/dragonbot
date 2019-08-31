#!/bin/bash

# Run Hubot with the Gitter adapter. Set up as documented at
# https://www.npmjs.com/package/hubot-gitter

# Define settings for the hubot script.
export PORT=8889;
#export HUBOT_GITTER2_TOKEN=729015f72a4f1fe84a4f9a026e4e57cbd7d18803;
export HUBOT_GITTER2_TOKEN=a37136d5e5a07de29598c34e724bdfc30b42e060;

# Temporary variables.
#export HUBOT_LOG_LEVEL=debug

cd /Users/davidradcliffe/dragonbot;
./bin/hubot -a gitter2 --name dragonbot > dragonbot.log 2>&1 &
# ./bin/hubot -a gitter2 --name dragonbot;

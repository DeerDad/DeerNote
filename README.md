#DeerNote is a solution for cross-platform rich editor 
###DeerNote contains parts as follows:
- db: mongodb
- server:  nodejs
- app: flutter

## launch mongdb service
- buy a cloud host，startup mongdb service

## launch nodejs server
- config mongodb address , /PROJECT/server/config/(defaut or release).json (depths your environment)
- config some network, /PROJECT/server/config/(defaut or release).json (depths your environment)

## launch app server
well，app builded with flutter, so it canbe cross-platform transfered quickly and easily.
- config server address, /PROJECT/app/assets/configs/*.yaml (depths your environment, notices all yaml will be parsed，but more priority file will override lower file, release > profile > debug > default)

enjoy it!!!



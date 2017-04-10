#!/bin/bash

echo "Getting access token..."

CLIENT_SECRET="c05426ab-4c8f-4a9f-8281-9d5eee3a84b6"
CLIENT_ID="test-client"
KEYCLOAK_TOKEN_URL="keycloak-keycloak-cluster-test.b6ff.rh-idev.openshiftapps.com/auth/realms/test/protocol/openid-connect/token"
USERNAME="testuser"
PASSWORD="password"
KEYCLOAK_RPT_URL="keycloak-keycloak-cluster-test.b6ff.rh-idev.openshiftapps.com/auth/realms/test/authz/entitlement/test-client"

#VEGETA_RATE=(10 50 100 150 200 250 300 350 400 450 500)
#VEGETA_DURATION=(30 30 30 30 30 30 30 30 30 30 30)

#echo "client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&username=$USERNAME&password=$PASSWORD&grant_type=password"
#TOKENS=$(curl -H "Content-Type:application/x-www-form-urlencoded" -XPOST http://$KEYCLOAK_TOKEN_URL --data "client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&username=$USERNAME&password=$PASSWORD&grant_type=password")

#echo "Tokens: $TOKENS"


#echo "POST http://$KEYCLOAK_TOKEN_URL" > targets
#echo "client_id=${CLIENT_ID}&client_secret=${CLIENT_SECRET}&username=${USERNAME}&password=${PASSWORD}&grant_type=password" > body.txt

#iter=0
#for i in "${VEGETA_RATE[@]}"
#do
#   echo $i
#   echo $VEGETA_DURATION[$iter]
#   vegeta -profile cpu attack -body=body.txt -header="Content-Type:application/x-www-form-urlencoded" -targets=targets -rate=$i -duration=30s > results_token_$i.bin
#   iter=$(expr ${iter} + 1 )
#   vegeta report -inputs results_token_$i.bin
#
#   sleep 300
#done


VEGETA_RATE=(10 50 100 150 200 250 300 350 400 450 500)
VEGETA_DURATION=(30 30 30 30 30 30 30 30 30 30 30)

iter=0
for i in "${VEGETA_RATE[@]}"
do

   echo "client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&username=$USERNAME&password=$PASSWORD&grant_type=password"
   TOKENS=$(curl -H "Content-Type:application/x-www-form-urlencoded" -XPOST http://$KEYCLOAK_TOKEN_URL --data "client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&username=$USERNAME&password=$PASSWORD&grant_type=password")

   echo "Tokens: $TOKENS"

   ACCESS_TOKEN=$(echo $TOKENS | jq .access_token | tr -d '"')

   echo "Access token: $ACCESS_TOKEN"

   curl -H "Content-Type:application/json;charset=UTF-8" -XPOST http://$KEYCLOAK_RPT_URL --data '{"permissions":[{"resource_set_name":"MySpace"}]}' -H "Authorization: Bearer $ACCESS_TOKEN"

   exit 1

   echo "POST http://$KEYCLOAK_RPT_URL" > targets
   echo '{"permissions":[{"resource_set_name":"MySpace"}]}' > body.json

   echo $i
   vegeta -profile cpu attack -body=body.json -header="Authorization: Bearer $ACCESS_TOKEN" -header="Content-Type:application/json" -targets=targets -rate=$i -duration=30s > results_rpt_$i.bin
   iter=$(expr ${iter} + 1 )
   vegeta report -inputs results_rpt_$i.bin

   sleep 300
done

#hey -m POST -T application/x-www-form-urlencoded -d "client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&username=$USERNAME&password=$PASSWORD&grant_type=password" -n 10000 -c 200  http://$KEYCLOAK_TOKEN_URL

#hey -H "Authorization: Bearer $ACCESS_TOKEN" -m POST -T application/json -d '{"permissions":[{"resource_set_name":"MySpace"}]}' -n 10000 -c 200 -more http://$KEYCLOAK_RPT_URL

#!/bin/bash

echo "Getting access token..."

CLIENT_SECRET="c05426ab-4c8f-4a9f-8281-9d5eee3a84b6"
CLIENT_ID="test-client"
KEYCLOAK_TOKEN_URL="keycloak-keycloak-cluster-test.b6ff.rh-idev.openshiftapps.com/auth/realms/test/protocol/openid-connect/token"
USERNAME="testuser"
PASSWORD="password"
KEYCLOAK_RPT_URL="keycloak-keycloak-cluster-test.b6ff.rh-idev.openshiftapps.com/auth/realms/test/authz/entitlement/test-client"


HEY_REQUESTS_TOKEN=(10 100 1000)
HEY_CONCURRENT_REQS_TOKEN=(1 10 100)
iter=0
for i in "${HEY_REQUESTS_TOKEN[@]}"
do
   echo $i
   hey -m POST -T application/x-www-form-urlencoded -more -d "client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&username=$USERNAME&password=$PASSWORD&grant_type=password" -n $i -c ${HEY_CONCURRENT_REQS_TOKEN[$iter]}  http://$KEYCLOAK_TOKEN_URL

   sleep 300
done


HEY_REQUESTS=(100 1000 10000)
HEY_CONCURRENT_REQS=(10 100 1000)

iter=0
for i in "${HEY_REQUESTS[@]}"
do

   echo "client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&username=$USERNAME&password=$PASSWORD&grant_type=password"
   TOKENS=$(curl -H "Content-Type:application/x-www-form-urlencoded" -XPOST http://$KEYCLOAK_TOKEN_URL --data "client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&username=$USERNAME&password=$PASSWORD&grant_type=password")

   echo "Tokens: $TOKENS"

   ACCESS_TOKEN=$(echo $TOKENS | jq .access_token | tr -d '"')

   echo "Access token: $ACCESS_TOKEN"

   curl -H "Content-Type:application/json;charset=UTF-8" -XPOST http://$KEYCLOAK_RPT_URL --data '{"permissions":[{"resource_set_name":"MySpace"}]}' -H "Authorization: Bearer $ACCESS_TOKEN"

   echo $i
   hey -H "Authorization: Bearer $ACCESS_TOKEN" -m POST -T application/json -d '{"permissions":[{"resource_set_name":"MySpace"}]}' -n $i -c ${HEY_CONCURRENT_REQS[$iter]} -more http://$KEYCLOAK_RPT_URL
   iter=$(expr ${iter} + 1 )

   sleep 300
done
#hey -H "Authorization: Bearer $ACCESS_TOKEN" -m POST -T application/json -d '{"permissions":[{"resource_set_name":"MySpace"}]}' -n 10000 -c 200 -more http://$KEYCLOAK_RPT_URL

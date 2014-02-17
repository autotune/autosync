#!/bin/bash
autoScale()
{
curl -i -s https://$DATACENTER.autoscale.api.rackspacecloud.com/v1.0/$ACCOUNT/groups \
       -X POST \
       -H  'Content-Type: application/json' \
       -H  'Accept: application/json' \
       -H  "X-Auth-Token: $TOKEN" \
       -d \ "{
        \"launchConfiguration\": {
                \"args\": {
                        \"server\":{
                           \"name\": \"$GROUP\",
                           \"imageRef\": \"$AUTOSLAVEID\",
                           \"flavorRef\": \"performance1-1\"
                        },
                        \"loadBalancers\":[
                        {
                           \"port\": 80,
                           \"loadBalancerId\": $LBID
                        }
                        ]
                },
          \"type\": \"launch_server\"
        },

        \"groupConfiguration\": {
                \"maxEntities\": 10,
                \"cooldown\": 5,
                \"name\": \"$GROUP\",
                \"minEntities\": 1,
                \"metadata\": {
                        \"gc_meta_key_2\": \"gc_meta_value_2\",
                        \"gc_meta_key_1\": \"gc_meta_value_1\"
                }
        }
}"
}


questions can be separated tag wise
answers can be vector instead of smartvector


 aptos move run --function-id 'default::guide_me::register_user' --args 'string:sourabh' --local

 aptos move run --function-id 'default::guide_me::register_user' --args 'string:sourabh' --profile-gas

 aptos move compile --package-dir aptos-move/move-examples/hello_blockchain/ --named-addresses hello_blockchain=default

  aptos move test --named-addresses guide_me_addr=bob


  curl --request POST \
  --url https://api.devnet.aptoslabs.com/v1/tables/table_handle/item \
  --header 'Accept: application/json, application/x-bcs' \
  --header 'Content-Type: application/json' \
  --data '{
  "key_type": "string",
  "value_type": "string",
  "key": null
}'
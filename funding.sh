#!/bin/bash

echo "Kiem tra vi funding"
funding=$(allorad keys show fundingWl -a --keyring-backend test 2>/dev/null)
if [ -z "$funding" ]; then
    echo "Import vi funding:"
    allorad keys add fundingWl --recover --keyring-backend test
    wait
else
    echo "Vi funding da ton tai: $funding"
fi


while IFS="|" read -r wallet mnemonic
do
    echo "========Checking $wallet========="
    NODE_URL="https://rpc.ankr.com/allora_testnet"
    echo "Using $NODE_URL"

    BAL=$(allorad q bank balances $wallet --node $NODE_URL -o json | jq -r '.balances[] | select(.denom=="uallo") | .amount')
    sleep 1
    echo "Balance: $BAL"
    if [ -z "$BAL" ]; then
        echo "Sending..."
        allorad tx bank send fundingWl $wallet 1000000000000000uallo --chain-id allora-testnet-1 --keyring-backend test --node $NODE_URL --gas-prices 1000000uallo --gas 100000 -y
        sleep 5
    else
        echo "No need to send"
    fi

done < "$HOME/wl_formated.txt"

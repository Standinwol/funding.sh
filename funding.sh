#!/bin/bash

urls=("https://allora-rpc.testnet.allora.network/"
    "https://allora-testnet-rpc.itrocket.net/"
    "https://rpc.ankr.com/allora_testnet"
    "http://66.70.177.125:27657/")

num_urls=${#urls[@]}

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
    echo "================="
    echo "Checking wallet: $wallet"
    random_index=$(( RANDOM % num_urls ))
    NODE_URL=${urls[$random_index]}
    
    BAL=$(allorad q bank balances "$wallet" --node $NODE_URL -o json | jq -r '.balances[] | select(.denom=="uallo") | .amount')
    echo "Balance: $BAL"
    
    if [ -z "$BAL" ]; then
        echo "Balance is empty. Sending 1000000000000000uallo to $wallet..."
        allorad tx bank send fundingWl $wallet 1000000000000000uallo --chain-id allora-testnet-1 --keyring-backend test --node $NODE_URL --gas-prices 1000000uallo --gas 100000 -y
        sleep 5
    else
        echo "Wallet $wallet already has balance. No need to send."
    fi

done < "$HOME/wl_formated.txt"

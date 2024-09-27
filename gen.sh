#!/bin/bash

urls=("https://rpc.ankr.com/allora_testnet")

num_urls=${#urls[@]}

# Fixed variable assignments (removed $)
read -p "Nhap stt vi dau tien muon tao: " start
read -p "Nhap stt vi cuoi cung muon tao: " end

# Assuming NODE_URL is defined; you may need to define it
NODE_URL=${urls[0]}  # Example: select the first URL

for i in $(seq $start $end)  # Use seq to generate a sequence of numbers
do
  while true
  do
    echo "=====Config Wallet $i======"
    echo "Xoa vi cu neu co"
    echo y | allorad keys delete wl$i --keyring-backend test 2>/dev/null
    wallet_info=$(allorad keys add wl$i --keyring-backend test --output json | jq)
    name=$(echo "$wallet_info" | jq -r '.name')
    address=$(echo "$wallet_info" | jq -r '.address')
    mnemonic=$(echo "$wallet_info" | jq -r '.mnemonic')
    
    # Store wallet information
    echo "$address|$mnemonic" >> "$HOME/wl_formated.txt"
    echo "WalletName: $name"
    echo "Address: $address"

    # Check balance for the wallet address
    BAL=$(allorad query bank balance $address --node $NODE_URL --keyring-backend test --output json | jq -r '.amount')
    
    if [ -z "$BAL" ] || [ "$BAL" -eq 0 ]; then  # Check if BAL is empty or zero
        echo "Balance is empty. Sending 1000000000000000uallo to $address..."
        allorad tx bank send fundingWl $address 1000000000000000uallo --chain-id allora-testnet-1 --keyring-backend test --node $NODE_URL --gas-prices 1000000uallo --gas 100000 -y
        sleep 5
    else
        echo "Wallet $address already has balance. No need to send."
    fi
    
    break  # Exit the while loop after processing each wallet
  done
done < "$HOME/wl_formated.txt"

#!/bin/bash

convert_currency() {
  local amount="$1"
  local from_currency="$2"
  local to_currency="$3"

  conversion_rate=$(curl -s "http://data.fixer.io/api/latest?access_key=c9f091d642af6a120e2f021141c98efd&base=$from_currency&symbols=$to_currency" | jq -r ".rates.$to_currency")

  if [[ -z "$conversion_rate" || "$conversion_rate" == "null" ]]; then
    echo "Conversion rate not available for $from_currency to $to_currency"
    return
  fi

  converted_amount=$(bc <<< "$amount * $conversion_rate")

  echo "$amount $from_currency = $converted_amount $to_currency"
}

get_currency_symbol() {
  local currency_code="$1"

  case "$currency_code" in
    USD)
      echo "$";;
    EUR)
      echo "€";;
    GBP)
      echo "£";;
    BDT)
      echo "৳";;
    *)
      echo "$currency_code";;
  esac
}

currency_pairs=("USD-EUR" "USD-BDT" "USD-GBP" "EUR-USD" "EUR-BDT" "EUR-GBP")

for pair in "${currency_pairs[@]}"; do
  from_currency="${pair%-*}"
  to_currency="${pair#*-}"
  convert_currency 1 "$from_currency" "$to_currency"
done

read -p "Enter the amount to convert: " amount
read -p "Enter the currency to convert from: " from_currency
read -p "Enter the currency to convert to: " to_currency

convert_currency "$amount" "$from_currency" "$to_currency"


read -p "Enter a list of currency pairs to convert (comma-separated): " currency_pairs_input
IFS=',' read -ra conversion_list <<< "$currency_pairs_input"

for conversion in "${conversion_list[@]}"; do
  from_currency="${conversion%-*}"
  to_currency="${conversion#*-}"
  convert_currency "$amount" "$from_currency" "$to_currency"
done

read -p "Enter a currency code to get the symbol: " currency_code
currency_symbol=$(get_currency_symbol "$currency_code")
echo "Currency symbol for $currency_code is $currency_symbol"


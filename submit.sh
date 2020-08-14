#!/bin/bash

cd ..

zip G1-3_HousingPrices.zip va-housing \
    -r \
    -x "va-housing/draft*" \
    -x "va-housing/notebook/*.nb.html" \
    -x "va-housing/R" \
    -x "va-housing/*.R*"
    -x "va-housing/rsconnect*" \
    -x "va-housing/*.git*" \

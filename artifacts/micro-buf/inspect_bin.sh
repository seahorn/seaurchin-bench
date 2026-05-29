#!/bin/bash

# get the binary name from the first argument
BINARY_NAME="$1"

# check if the binary path is provided
if [[ -z "$BINARY_NAME" ]]; then
    echo "Usage: $0 <binary_name>"
    exit 1
fi
BINARY_PATH="target/release/$BINARY_NAME"
cargo clean
TMP_OWNSEM_FILE=$(mktemp)
RUSTFLAGS="-Zprint_codegen_stats -C opt-level=3 -Cllvm-args=-licm-uses-ownsem=true -Cllvm-args=-licm-ownsem-safeset-ignores-throw -Cllvm-args=-licm-ownsem-safeset-store-threadsafe" cargo build --release > $TMP_OWNSEM_FILE
if [[ ! -f "$BINARY_PATH" ]]; then
    echo "Binary not built: $BINARY_PATH"
    exit 1
fi
echo -e 'Inspecting ownsem binary: '"$BINARY_PATH"'\n'

stack_transfers_ownsem=$(llvm-objdump-18 -d ${BINARY_PATH} --demangle | grep -E 'mov.*\(%rsp\)' | wc -l)
TMP_DEFAULT_FILE=$(mktemp)
RUSTFLAGS="-Zprint_codegen_stats -C opt-level=3" cargo build --release > $TMP_DEFAULT_FILE
if [[ ! -f "$BINARY_PATH" ]]; then
    echo "Binary not built: $BINARY_PATH"
    exit 1
fi
echo -e 'Inspecting default binary: '"$BINARY_PATH"'\n'

stack_transfers_default=$(llvm-objdump-18 -d ${BINARY_PATH} --demangle | grep -E 'mov.*\(%rsp\)' | wc -l)

echo -e "Stack transfers with ownsem: $stack_transfers_ownsem"
echo -e "Stack transfers without ownsem: $stack_transfers_default"
if [[ $stack_transfers_ownsem -gt $stack_transfers_default ]]; then
    echo -e "Ownsem binary has more stack transfers than default binary."
else
    echo -e "Ownsem binary has fewer or equal stack transfers than default binary."
fi
ownsem_promo=$(grep -E 'licm.*Number of load and store promotions' $TMP_OWNSEM_FILE | awk '{sum += $1} END {print sum}')
default_promo=$(grep -E 'licm.*Number of load and store promotions' $TMP_DEFAULT_FILE | awk '{sum += $1} END {print sum}')
ownsem_reg_spills=$(grep -E 'regalloc.*Number of spills inserted' $TMP_OWNSEM_FILE | awk '{sum += $1} END {print sum}')
default_reg_spills=$(grep -E 'regalloc.*Number of spills inserted' $TMP_DEFAULT_FILE | awk '{sum += $1} END {print sum}')
echo -e "Load/store promotions with ownsem: $ownsem_promo"
echo -e "Load/store promotions without ownsem: $default_promo"
if [[ $ownsem_promo -gt $default_promo ]]; then
    echo -e "Ownsem binary has more load/store promotions than default binary."
else
    echo -e "Ownsem binary has fewer or equal load/store promotions than default binary."
fi
echo -e "Register spills with ownsem: $ownsem_reg_spills"
echo -e "Register spills without ownsem: $default_reg_spills"
if [[ $ownsem_reg_spills -gt $default_reg_spills ]]; then
    echo -e "Ownsem binary has more register spills than default binary."
else  
    echo -e "Ownsem binary has fewer or equal register spills than default binary."
fi
rm -f $TMP_OWNSEM_FILE $TMP_DEFAULT_FILE